import { ValidationPipe } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import { AppModule } from '../../src/app.module';
import { PrismaService } from '../../src/prisma/prisma.service';
import { createInMemoryPrisma } from './in-memory-prisma';

type HttpMethod = 'GET' | 'POST' | 'PATCH' | 'DELETE';

function createAgent(baseUrl: string) {
  const createRequest = (method: HttpMethod, path: string) => {
    const headers: Record<string, string> = {};
    let payload: unknown;

    return {
      set(name: string, value: string) {
        headers[name] = value;
        return this;
      },
      send(body: unknown) {
        payload = body;
        if (!headers['Content-Type']) {
          headers['Content-Type'] = 'application/json';
        }
        return this;
      },
      async expect(expectedStatus: number) {
        const response = await fetch(`${baseUrl}${path}`, {
          method,
          headers,
          body: payload !== undefined ? JSON.stringify(payload) : undefined,
        });

        const body = await response.json().catch(() => ({}));
        if (response.status !== expectedStatus) {
          throw new Error(
            `Expected ${expectedStatus} but received ${response.status}: ${JSON.stringify(body)}`,
          );
        }

        return {
          status: response.status,
          body,
          headers: Object.fromEntries(response.headers.entries()),
        };
      },
    };
  };

  return {
    get: (path: string) => createRequest('GET', path),
    post: (path: string) => createRequest('POST', path),
    patch: (path: string) => createRequest('PATCH', path),
    delete: (path: string) => createRequest('DELETE', path),
  };
}

export async function createTestApp() {
  process.env.JWT_ACCESS_SECRET = 'qa-access-secret';
  process.env.JWT_REFRESH_SECRET = 'qa-refresh-secret';
  process.env.JWT_ACCESS_EXPIRES_IN = '15m';
  process.env.JWT_REFRESH_EXPIRES_IN = '7d';
  process.env.NODE_ENV = 'test';

  const prisma = await createInMemoryPrisma();

  const moduleRef = await Test.createTestingModule({
    imports: [AppModule],
  })
    .overrideProvider(PrismaService)
    .useValue(prisma)
    .compile();

  const app = moduleRef.createNestApplication();
  app.setGlobalPrefix('api');
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: {
        enableImplicitConversion: true,
      },
    }),
  );

  await app.init();
  await app.listen(0);
  const baseUrl = await app.getUrl();
  const agent = createAgent(baseUrl);

  async function loginAs(role: 'ADMIN' | 'STAFF') {
    const credentials =
      role === 'ADMIN'
        ? { email: 'admin@mf.local', password: 'Admin2026@' }
        : { email: 'staff@mf.local', password: 'Staff2026@' };

    const response = await agent.post('/api/auth/login').send(credentials).expect(200);

    return {
      ...response.body,
      authHeader: `Bearer ${response.body.accessToken}`,
    };
  }

  return {
    app,
    agent,
    prisma,
    loginAs,
  };
}
