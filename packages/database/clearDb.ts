import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

async function main() {
  console.log('Bắt đầu dọn dẹp toàn bộ dữ liệu mẫu (seed data)...');
  
  // Xoá theo thứ tự phụ thuộc (từ con đến cha)
  await prisma.auditLog.deleteMany();
  await prisma.orderItem.deleteMany();
  await prisma.order.deleteMany();
  await prisma.productGroupPrice.deleteMany();
  await prisma.customerSpecialPrice.deleteMany();
  await prisma.product.deleteMany();
  await prisma.customer.deleteMany();
  await prisma.customerGroup.deleteMany();
  
  // Xóa tài khoản, CHỈ giữ lại poka@poka.us và phuongvi@poka.us
  const deletedUsers = await prisma.user.deleteMany({
    where: {
      email: {
        notIn: ['poka@poka.us', 'phuongvi@poka.us']
      }
    }
  });

  console.log(`Đã dọn sạch Orders, Products, Customers.`);
  console.log(`Đã xoá ${deletedUsers.count} Users rác. Giữ lại poka@poka.us và phuongvi@poka.us`);
}

main()
  .catch(e => {
    console.error('Lỗi trong quá trình dọn dẹp:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
