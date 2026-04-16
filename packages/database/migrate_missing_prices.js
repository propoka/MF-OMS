const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

async function run() {
  console.log('Bắt đầu cập nhật giá nhóm cho các sản phẩm cũ...');
  
  const products = await prisma.product.findMany({
    include: { groupPrices: true }
  });
  
  const groups = await prisma.customerGroup.findMany({
    where: { priceType: 'FIXED' }
  });
  
  let addedCount = 0;

  for (const product of products) {
    for (const group of groups) {
      const hasPrice = product.groupPrices.some(gp => gp.groupId === group.id);
      if (!hasPrice) {
        await prisma.productGroupPrice.create({
          data: {
            productId: product.id,
            groupId: group.id,
            fixedPrice: 0
          }
        });
        addedCount++;
      }
    }
  }

  console.log(`Đã cập nhật hoàn tất. Đã thêm ${addedCount} bản ghi với giá = 0 cho các sản phẩm.`);
}

run()
  .catch(e => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
