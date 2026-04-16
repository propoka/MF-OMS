import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('Bắt đầu dọn dẹp các giá nhóm ảo (fixedPrice = 0)...');
  const result = await prisma.productGroupPrice.deleteMany({
    where: { fixedPrice: 0 }
  });
  console.log(`✅ Đã xoá thành công ${result.count} bản ghi giá nhóm bị set thành 0đ do lỗi form cũ.`);
}

main()
  .catch((e) => {
    console.error('Lỗi khi cleanup:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
