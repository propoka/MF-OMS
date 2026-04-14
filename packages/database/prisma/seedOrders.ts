import { PrismaClient, OrderDeliveryStatus, PriceSource } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Starting to seed mock ORDERS for dashboard testing...');

  const admin = await prisma.user.findFirst({ where: { email: 'poka@poka.us' } });
  if (!admin) {
    console.error('Admin user not found. Please run regular seed first.');
    return;
  }

  const customers = await prisma.customer.findMany();
  const products = await prisma.product.findMany();

  if (!customers.length || !products.length) {
    console.error('No customers or products found. Please run regular seed first.');
    return;
  }

  // Delete all existing orders & items so we start fresh for chart testing
  console.log('Cleaning up existing orders...');
  await prisma.auditLog.deleteMany({ where: { entityType: 'Order' } });
  await prisma.orderItem.deleteMany();
  await prisma.order.deleteMany();

  // Create 50 random orders over the last 7 days
  const today = new Date();
  let createdCount = 0;

  for (let i = 0; i < 50; i++) {
    const randomCustomer = customers[Math.floor(Math.random() * customers.length)];
    
    // Pick 1 to 4 random products
    const itemsCount = Math.floor(Math.random() * 4) + 1;
    const orderItemsConfig: any[] = [];
    let subtotal = 0;

    for (let j = 0; j < itemsCount; j++) {
      const product = products[Math.floor(Math.random() * products.length)];
      const qty = Math.floor(Math.random() * 5) + 1;
      const unitPrice = Number(product.retailPrice);
      const lineTotal = unitPrice * qty;

      if (!orderItemsConfig.find(item => item.productId === product.id)) {
        orderItemsConfig.push({
          productId: product.id,
          snapshotProductName: product.name,
          snapshotProductSku: product.sku,
          snapshotProductUnit: product.unit,
          snapshotUnitPrice: unitPrice,
          priceSource: PriceSource.RETAIL,
          quantity: qty,
          lineDiscount: 0,
          lineTotal: lineTotal
        });
        subtotal += lineTotal;
      }
    }

    // Assign a random date in the last 7 days
    const daysAgo = Math.floor(Math.random() * 7); // 0 to 6
    const createdAt = new Date(today);
    createdAt.setDate(today.getDate() - daysAgo);

    // Randomize status (70% COMPLETED, 10% PENDING, 10% SHIPPING, 10% CANCELLED)
    const rand = Math.random();
    let status: OrderDeliveryStatus;
    if (rand < 0.7) status = OrderDeliveryStatus.COMPLETED;
    else if (rand < 0.8) status = OrderDeliveryStatus.PENDING;
    else if (rand < 0.9) status = OrderDeliveryStatus.SHIPPING;
    else status = OrderDeliveryStatus.CANCELLED;

    // Formatting order number
    const dateStr = createdAt.toISOString().slice(0, 10).replace(/-/g, '');
    const orderNumber = `ORD-${dateStr}-${(1000 + i).toString().padStart(4, '0')}`;

    const totalAmount = subtotal;

    await prisma.order.create({
      data: {
        orderNumber,
        customerId: randomCustomer.id,
        snapshotCustomerName: randomCustomer.fullName,
        snapshotCustomerPhone: randomCustomer.phone,
        createdById: admin.id,
        deliveryStatus: status,
        subtotal,
        discountAmount: 0,
        shippingFee: 0,
        totalAmount,
        createdAt,
        items: {
          create: orderItemsConfig
        }
      }
    });

    createdCount++;
  }

  console.log(`✅ Successfully seeded ${createdCount} orders over the last 7 days.`);
  console.log('🎉 Seed completed!');
}

main()
  .catch((e) => {
    console.error('❌ Seed failed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
