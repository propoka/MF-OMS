import { createTestApp } from './helpers/create-test-app';

describe('QA Smoke Suite', () => {
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

  it('smoke auth: admin can login, read profile, and logout', async () => {
    const session = await loginAs('ADMIN');

    const meResponse = await agent
      .get('/api/auth/me')
      .set('Authorization', session.authHeader)
      .expect(200);

    expect(meResponse.body.email).toBe('admin@mf.local');
    expect(meResponse.body.role).toBe('ADMIN');

    await agent
      .post('/api/auth/logout')
      .set('Authorization', session.authHeader)
      .expect(200);
  });

  it('smoke customers: staff can create, list, get detail, and update customer', async () => {
    const staff = await loginAs('STAFF');

    const createResponse = await agent
      .post('/api/customers')
      .set('Authorization', staff.authHeader)
      .send({
        phone: '0912345688',
        fullName: 'Smoke Customer',
        addressDetail: '123 Test Street',
      })
      .expect(201);

    const customerId = createResponse.body.id as string;

    const listResponse = await agent
      .get('/api/customers')
      .set('Authorization', staff.authHeader)
      .expect(200);

    expect(listResponse.body.total).toBeGreaterThanOrEqual(1);
    expect(listResponse.body.data.some((item: any) => item.id === customerId)).toBe(true);

    const detailResponse = await agent
      .get(`/api/customers/${customerId}`)
      .set('Authorization', staff.authHeader)
      .expect(200);

    expect(detailResponse.body.fullName).toBe('Smoke Customer');

    await agent
      .patch(`/api/customers/${customerId}`)
      .set('Authorization', staff.authHeader)
      .send({
        fullName: 'Smoke Customer Updated',
      })
      .expect(200);
  });

  it('smoke products: admin can create, list, and update product', async () => {
    const admin = await loginAs('ADMIN');

    const createResponse = await agent
      .post('/api/products')
      .set('Authorization', admin.authHeader)
      .send({
        name: 'Smoke Product',
        categoryId: 'category_nsk',
        unit: 'Gói',
        retailPrice: 210000,
        groupPrices: [{ groupId: 'group_wholesale', fixedPrice: 180000 }],
      })
      .expect(201);

    const productId = createResponse.body.id as string;

    const listResponse = await agent
      .get('/api/products')
      .set('Authorization', admin.authHeader)
      .expect(200);

    expect(listResponse.body.data.some((item: any) => item.id === productId)).toBe(true);

    await agent
      .patch(`/api/products/${productId}`)
      .set('Authorization', admin.authHeader)
      .send({
        name: 'Smoke Product Updated',
        categoryId: 'category_nsk',
        unit: 'Gói',
        retailPrice: 215000,
        groupPrices: [{ groupId: 'group_wholesale', fixedPrice: 185000 }],
      })
      .expect(200);
  });

  it('smoke orders: staff can preview pricing, create order, read order, and update status', async () => {
    const staff = await loginAs('STAFF');

    const previewResponse = await agent
      .post('/api/orders/preview-pricing')
      .set('Authorization', staff.authHeader)
      .send({
        customerId: 'customer_wholesale',
        items: [{ productId: 'product_group', quantity: 2 }],
      })
      .expect(201);

    expect(previewResponse.body.subtotal).toBe(180000);

    const createResponse = await agent
      .post('/api/orders')
      .set('Authorization', staff.authHeader)
      .send({
        customerId: 'customer_wholesale',
        items: [{ productId: 'product_group', quantity: 2 }],
        shippingFee: 15000,
      })
      .expect(201);

    const orderId = createResponse.body.id as string;

    await agent
      .get(`/api/orders/${orderId}`)
      .set('Authorization', staff.authHeader)
      .expect(200);

    await agent
      .patch(`/api/orders/${orderId}/status`)
      .set('Authorization', staff.authHeader)
      .send({ deliveryStatus: 'PROCESSING' })
      .expect(200);
  });

  it('smoke settings: admin can read users/company/cancel reasons and update settings', async () => {
    const admin = await loginAs('ADMIN');

    const usersResponse = await agent
      .get('/api/users')
      .set('Authorization', admin.authHeader)
      .expect(200);

    expect(usersResponse.body.length).toBeGreaterThanOrEqual(2);

    const companyResponse = await agent
      .get('/api/settings/company')
      .set('Authorization', admin.authHeader)
      .expect(200);

    expect(companyResponse.body.name).toContain('Mountain Farmers');

    await agent
      .patch('/api/settings/company')
      .set('Authorization', admin.authHeader)
      .send({
        name: 'Mountain Farmers QA Updated',
        treatBlankAsZero: true,
      })
      .expect(200);

    const reasonsResponse = await agent
      .get('/api/settings/cancel-reasons')
      .set('Authorization', admin.authHeader)
      .expect(200);

    expect(reasonsResponse.body.length).toBeGreaterThanOrEqual(1);
  });
});
