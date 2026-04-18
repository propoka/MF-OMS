import { createTestApp } from './helpers/create-test-app';

describe('QA API Integration Suite', () => {
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

  it('integrates login and refresh token rotation', async () => {
    const loginResponse = await agent
      .post('/api/auth/login')
      .send({
        email: 'admin@mf.local',
        password: 'Admin2026@',
      })
      .expect(200);

    expect(loginResponse.body.accessToken).toBeTruthy();
    expect(loginResponse.body.refreshToken).toBeTruthy();

    const refreshResponse = await agent
      .post('/api/auth/refresh')
      .send({
        refreshToken: loginResponse.body.refreshToken,
      })
      .expect(200);

    expect(refreshResponse.body.accessToken).not.toBe(loginResponse.body.accessToken);
    expect(refreshResponse.body.refreshToken).not.toBe(loginResponse.body.refreshToken);
  });

  it('integrates pricing preview with retail, group, and special price sources', async () => {
    const staff = await loginAs('STAFF');

    const retailResponse = await agent
      .post('/api/orders/preview-pricing')
      .set('Authorization', staff.authHeader)
      .send({
        customerId: 'customer_wholesale',
        items: [{ productId: 'product_retail', quantity: 1 }],
      })
      .expect(201);

    expect(retailResponse.body.items[0].priceSource).toBe('RETAIL');
    expect(retailResponse.body.items[0].snapshotUnitPrice).toBe(100000);

    const groupResponse = await agent
      .post('/api/orders/preview-pricing')
      .set('Authorization', staff.authHeader)
      .send({
        customerId: 'customer_wholesale',
        items: [{ productId: 'product_group', quantity: 1 }],
      })
      .expect(201);

    expect(groupResponse.body.items[0].priceSource).toBe('GROUP');
    expect(groupResponse.body.items[0].snapshotUnitPrice).toBe(90000);

    const specialResponse = await agent
      .post('/api/orders/preview-pricing')
      .set('Authorization', staff.authHeader)
      .send({
        customerId: 'customer_special',
        items: [{ productId: 'product_special', quantity: 1 }],
      })
      .expect(201);

    expect(specialResponse.body.items[0].priceSource).toBe('SPECIAL');
    expect(specialResponse.body.items[0].snapshotUnitPrice).toBe(70000);
  });

  it('integrates create order and update status flow', async () => {
    const staff = await loginAs('STAFF');

    const createResponse = await agent
      .post('/api/orders')
      .set('Authorization', staff.authHeader)
      .send({
        customerId: 'customer_special',
        items: [{ productId: 'product_special', quantity: 2, manualDiscount: 5000 }],
        shippingFee: 10000,
        discountAmount: 0,
      })
      .expect(201);

    expect(createResponse.body.orderNumber).toMatch(/^ORD-\d{8}-\d{4,6}$/);
    expect(createResponse.body.totalAmount).toBe(145000);

    const processingResponse = await agent
      .patch(`/api/orders/${createResponse.body.id}/status`)
      .set('Authorization', staff.authHeader)
      .send({ deliveryStatus: 'PROCESSING' })
      .expect(200);

    expect(processingResponse.body.deliveryStatus).toBe('PROCESSING');
  });

  it('integrates customer, product, and order import endpoints', async () => {
    const admin = await loginAs('ADMIN');

    const importCustomersResponse = await agent
      .post('/api/customers/import')
      .set('Authorization', admin.authHeader)
      .send([
        {
          phone: '0912345690',
          fullName: 'Import Customer One',
          provinceName: 'Kon Tum',
          wardName: 'Trần Hưng Đạo',
          notes: 'from import',
        },
      ])
      .expect(201);

    expect(importCustomersResponse.body.importedCount).toBe(1);

    const importProductsResponse = await agent
      .post('/api/products/import')
      .set('Authorization', admin.authHeader)
      .send([
        {
          name: 'Import Product One',
          categoryCode: 'NSK',
          unit: 'Gói',
          retailPrice: 99000,
        },
      ])
      .expect(201);

    expect(importProductsResponse.body.successCount).toBe(1);

    const importOrdersResponse = await agent
      .post('/api/orders/import')
      .set('Authorization', admin.authHeader)
      .send([
        {
          customerPhone: '0912345690',
          customerName: 'Import Customer One',
          productSkus: 'NSK01',
          quantities: '2',
          shippingFee: 5000,
          discountAmount: 0,
          notes: 'Imported order',
        },
      ])
      .expect(201);

    expect(importOrdersResponse.body.successCount).toBe(1);
  });
});
