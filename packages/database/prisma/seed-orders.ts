import { PrismaClient, OrderDeliveryStatus, PriceSource } from '@prisma/client';

const prisma = new PrismaClient();

function getRandomInt(min: number, max: number) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

function generateOrderNumber(index: number) {
  const date = new Date();
  const yyyy = date.getFullYear();
  const mm = String(date.getMonth() + 1).padStart(2, '0');
  const dd = String(date.getDate()).padStart(2, '0');
  const randNum = String(getRandomInt(1000, 9999));
  return `ORD-${yyyy}${mm}${dd}-${randNum}-${index}`;
}

async function main() {
  console.log('🌱 Starting seed 20 sample orders...');

  const users = await prisma.user.findMany();
  const customers = await prisma.customer.findMany();
  const products = await prisma.product.findMany({
    include: { groupPrices: true }
  });

  if (!users.length || !customers.length || !products.length) {
    console.error('❌ Missing master data. Please run db:seed first.');
    process.exit(1);
  }

  const staff = users[0];
  const statuses = [
    OrderDeliveryStatus.PENDING,
    OrderDeliveryStatus.PROCESSING,
    OrderDeliveryStatus.SHIPPING,
    OrderDeliveryStatus.COMPLETED,
    OrderDeliveryStatus.RETURNED,
    OrderDeliveryStatus.CANCELLED
  ];

  let added = 0;

  for (let i = 1; i <= 20; i++) {
    const customer = customers[getRandomInt(0, customers.length - 1)];
    const status = statuses[getRandomInt(0, statuses.length - 1)];
    
    // Choose 1 to 4 distinct products
    const numOfItems = getRandomInt(1, 4);
    const shuffledProducts = [...products].sort(() => 0.5 - Math.random());
    const selectedProducts = shuffledProducts.slice(0, numOfItems);

    let subtotal = 0;
    const itemsData = selectedProducts.map(p => {
      // Basic pricing logic for mock
      let unitPrice: number;
      let priceSource: PriceSource;
      let pricingNote: string;
      const groupPrice = p.groupPrices.find(gp => gp.groupId === customer.groupId);

      if (groupPrice && groupPrice.fixedPrice) {
        unitPrice = Number(groupPrice.fixedPrice);
        priceSource = PriceSource.GROUP;
        pricingNote = 'Áp dụng giá nhóm';
      } else {
        unitPrice = Number(p.retailPrice);
        priceSource = PriceSource.RETAIL;
        pricingNote = 'Giá bán lẻ';
      }

      const qty = getRandomInt(1, 5);
      const lineTotal = unitPrice * qty;
      subtotal += lineTotal;

      return {
        productId: p.id,
        snapshotProductName: p.name,
        snapshotProductSku: p.sku,
        snapshotProductUnit: p.unit,
        snapshotUnitPrice: unitPrice,
        priceSource: priceSource,
        pricingNote: pricingNote,
        quantity: qty,
        lineDiscount: 0,
        lineTotal: lineTotal
      };
    });

    const discountAmount = getRandomInt(0, 1) === 1 ? getRandomInt(10, 50) * 1000 : 0;
    const shippingFee = getRandomInt(15, 30) * 1000;
    const totalAmount = Math.max(0, subtotal - discountAmount) + shippingFee;

    const orderNumber = generateOrderNumber(i);

    await prisma.order.create({
      data: {
        orderNumber,
        customerId: customer.id,
        snapshotCustomerName: customer.fullName,
        snapshotCustomerPhone: customer.phone,
        createdById: staff.id,
        deliveryStatus: status,
        subtotal,
        discountAmount,
        shippingFee,
        totalAmount,
        items: {
          create: itemsData
        }
      }
    });

    added++;
  }

  console.log(`✅ successfully seeded ${added} orders!`);
}

main()
  .catch((e) => {
    console.error('❌ Failed to seed orders:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
