import { createTestApp } from './helpers/create-test-app';

describe('QA Minimal E2E Flows', () => {
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

  it('e2e flow: staff login -> create customer -> create order -> change status -> read detail', async () => {
    const staff = await loginAs('STAFF');

    const customerResponse = await agent
      .post('/api/customers')
      .set('Authorization', staff.authHeader)
      .send({
        phone: '0912345699',
        fullName: 'Flow Customer',
        addressDetail: 'Flow Address',
      })
      .expect(201);

    const orderResponse = await agent
      .post('/api/orders')
      .set('Authorization', staff.authHeader)
      .send({
        customerId: customerResponse.body.id,
        items: [{ productId: 'product_retail', quantity: 3 }],
        shippingFee: 10000,
      })
      .expect(201);

    await agent
      .patch(`/api/orders/${orderResponse.body.id}/status`)
      .set('Authorization', staff.authHeader)
      .send({ deliveryStatus: 'PROCESSING' })
      .expect(200);

    const detailResponse = await agent
      .get(`/api/orders/${orderResponse.body.id}`)
      .set('Authorization', staff.authHeader)
      .expect(200);

    expect(detailResponse.body.snapshotCustomerName).toBe('Flow Customer');
    expect(detailResponse.body.items).toHaveLength(1);
  });

  it('e2e flow: admin import customer/product/order payloads end-to-end', async () => {
    const admin = await loginAs('ADMIN');

    await agent
      .post('/api/customers/import')
      .set('Authorization', admin.authHeader)
      .send([
        {
          phone: '0912345700',
          fullName: 'Flow Import Customer',
          notes: 'batch import',
        },
      ])
      .expect(201);

    await agent
      .post('/api/products/import')
      .set('Authorization', admin.authHeader)
      .send([
        {
          name: 'Flow Import Product',
          categoryCode: 'NSK',
          unit: 'Gói',
          retailPrice: 88000,
        },
      ])
      .expect(201);

    const importOrderResponse = await agent
      .post('/api/orders/import')
      .set('Authorization', admin.authHeader)
      .send([
        {
          customerPhone: '0912345700',
          customerName: 'Flow Import Customer',
          productSkus: 'NSK01',
          quantities: '1',
          shippingFee: 5000,
          discountAmount: 0,
          notes: 'flow import order',
        },
      ])
      .expect(201);

    expect(importOrderResponse.body.successCount).toBe(1);

    const ordersResponse = await agent
      .get('/api/orders?search=Flow Import Customer')
      .set('Authorization', admin.authHeader)
      .expect(200);

    expect(ordersResponse.body.total).toBeGreaterThanOrEqual(1);
  });
});
