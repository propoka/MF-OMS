import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  const topProducts = await prisma.orderItem.groupBy({
    by: ['snapshotProductName', 'snapshotProductSku'],
    _sum: { quantity: true, lineTotal: true },
    orderBy: { _sum: { lineTotal: 'desc' } },
    take: 10,
    where: {
      order: { deliveryStatus: 'COMPLETED' }
    }
  });

  console.log('Top Products:', topProducts);

  const topCustomers = await prisma.order.groupBy({
    by: ['snapshotCustomerName', 'snapshotCustomerPhone'],
    _sum: { totalAmount: true },
    orderBy: { _sum: { totalAmount: 'desc' } },
    take: 10,
    where: { deliveryStatus: 'COMPLETED' }
  });

  console.log('Top Customers:', topCustomers);
}

main()
  .catch(e => console.error(e))
  .finally(() => prisma.$disconnect());
