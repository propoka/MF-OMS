import { createTestApp } from './helpers/create-test-app';

describe('QA Regression Suite', () => {
  let app: Awaited<ReturnType<typeof createTestApp>>['app'];
  let agent: Awaited<ReturnType<typeof createTestApp>>['agent'];
  let loginAs: Awaited<ReturnType<typeof createTestApp>>['loginAs'];

  beforeAll(async () => {
    const testApp = await createTestApp();
    app = testApp.app;
    agent = testApp.agent;
    loginAs = testApp.loginAs;
  });

  afterAll(async () => {
    await app.close();
  });

  it('regression: pricing priority stays SPECIAL > GROUP > RETAIL', async () => {
    const staff = await loginAs('STAFF');

    const response = await agent
      .post('/api/orders/preview-pricing')
      .set('Authorization', staff.authHeader)
      .send({
        customerId: 'customer_special',
        items: [
          { productId: 'product_special', quantity: 1 },
          { productId: 'product_group', quantity: 1 },
          { productId: 'product_retail', quantity: 1 },
        ],
      })
      .expect(201);

    expect(response.body.items.map((item: any) => item.priceSource)).toEqual([
      'SPECIAL',
      'GROUP',
      'RETAIL',
    ]);

    expect(response.body.items.map((item: any) => item.snapshotUnitPrice)).toEqual([
      70000,
      90000,
      100000,
    ]);
  });

  it('regression: order status transition enforces state machine', async () => {
    const staff = await loginAs('STAFF');

    const createResponse = await agent
      .post('/api/orders')
      .set('Authorization', staff.authHeader)
      .send({
        customerId: 'customer_retail',
        items: [{ productId: 'product_retail', quantity: 1 }],
      })
      .expect(201);

    const orderId = createResponse.body.id as string;

    await agent
      .patch(`/api/orders/${orderId}/status`)
      .set('Authorization', staff.authHeader)
      .send({ deliveryStatus: 'COMPLETED' })
      .expect(400);

    await agent
      .patch(`/api/orders/${orderId}/status`)
      .set('Authorization', staff.authHeader)
      .send({ deliveryStatus: 'PROCESSING' })
      .expect(200);

    await agent
      .patch(`/api/orders/${orderId}/status`)
      .set('Authorization', staff.authHeader)
      .send({ deliveryStatus: 'SHIPPING' })
      .expect(200);

    await agent
      .patch(`/api/orders/${orderId}/status`)
      .set('Authorization', staff.authHeader)
      .send({ deliveryStatus: 'COMPLETED' })
      .expect(200);
  });

  it('regression: ADMIN/STAFF permission boundary remains intact', async () => {
    const admin = await loginAs('ADMIN');
    const staff = await loginAs('STAFF');

    await agent
      .get('/api/users')
      .set('Authorization', admin.authHeader)
      .expect(200);

    await agent
      .get('/api/users')
      .set('Authorization', staff.authHeader)
      .expect(403);

    await agent
      .patch('/api/settings/company')
      .set('Authorization', staff.authHeader)
      .send({ name: 'Should Be Forbidden' })
      .expect(403);

    await agent
      .patch('/api/settings/company')
      .set('Authorization', admin.authHeader)
      .send({ name: 'Allowed For Admin' })
      .expect(200);
  });
});
