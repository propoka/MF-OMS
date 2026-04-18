# ---- Builder stage ----
FROM node:22-alpine AS builder
RUN apk add --no-cache openssl && npm install -g pnpm@9

WORKDIR /app

# Copy root workspace files
COPY package.json pnpm-workspace.yaml pnpm-lock.yaml ./
COPY turbo.json ./

# Copy packages/database
COPY packages/database/package.json packages/database/
COPY packages/database/prisma packages/database/prisma/
COPY packages/database/tsconfig.json packages/database/
COPY packages/database/index.ts packages/database/

# Copy apps/api
COPY apps/api/package.json apps/api/
COPY apps/api/tsconfig.json apps/api/
COPY apps/api/tsconfig.build.json apps/api/
COPY apps/api/nest-cli.json apps/api/
COPY apps/api/src apps/api/src/
COPY apps/api/test apps/api/test/

RUN pnpm install --frozen-lockfile

# Generate Prisma client
RUN pnpm db:generate

# Build
RUN pnpm build

# ---- Production stage ----
FROM node:22-alpine AS runner
RUN apk add --no-cache openssl && npm install -g pnpm@9

WORKDIR /app

# Thiết lập môi trường production
ENV NODE_ENV=production

# Copy only production artifacts
COPY --from=builder /app/package.json /app/pnpm-workspace.yaml /app/pnpm-lock.yaml ./
COPY --from=builder /app/packages/database/package.json packages/database/
COPY --from=builder /app/packages/database/prisma packages/database/prisma/
COPY --from=builder /app/packages/database/index.ts packages/database/
COPY --from=builder /app/apps/api/package.json apps/api/
COPY --from=builder /app/apps/api/dist apps/api/dist
COPY --from=builder /app/apps/api/node_modules apps/api/node_modules
COPY --from=builder /app/node_modules node_modules
COPY --from=builder /app/packages/database/node_modules packages/database/node_modules

# Generate Prisma client in production (needed for runtime)
RUN pnpm db:generate

# Copy entrypoint script
COPY apps/api/entrypoint.sh /app/apps/api/entrypoint.sh
RUN chmod +x /app/apps/api/entrypoint.sh

WORKDIR /app/apps/api

EXPOSE 3001

# Entrypoint chạy migrate deploy trước khi start server
CMD ["sh", "entrypoint.sh"]
