import { PrismaClient, Role } from '@prisma/client';
import * as bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Starting database seed with mock data...');

  // ============================================================
  // 1. Admin User
  // ============================================================
  const passwordHash = await bcrypt.hash('Admin2026@', 12);

  const admin = await prisma.user.upsert({
    where: { email: 'poka@poka.us' },
    update: {},
    create: {
      email: 'poka@poka.us',
      passwordHash,
      fullName: 'Administrator',
      role: Role.ADMIN,
      isActive: true,
    },
  });
  console.log(`✅ Admin user: ${admin.email}`);

  // ============================================================
  // 2. Customer Groups (5+ Groups)
  // ============================================================
  const groupNames = ['Khách lẻ', 'Sỉ cấp 1', 'KHOADL', 'VITA', 'VYQN', 'NAMAN'];
  const groupsToUse: any[] = [];
  
  for (const name of groupNames) {
    const isDefault = name === 'Khách lẻ';
    const group = await prisma.customerGroup.upsert({
      where: { name: name },
      update: {},
      create: {
        name: name,
        description: isDefault ? 'Nhóm khách hàng mặc định' : `Nhóm ${name}`,
        priceType: isDefault ? 'PERCENTAGE' : 'FIXED',
        discountPercent: isDefault ? 0 : 0,
        isDefault: isDefault,
      },
    });
    groupsToUse.push(group);
  }
  console.log(`✅ Customer groups: ${groupNames.length} groups created`);

  // ============================================================
  // 3. Products (20 Products)
  // ============================================================
  const productNames = [
    'Bí xanh khô (100gr)', 'Hạt ngũ cốc thanh xuân', 'Bột mè đen cửu chưng cửu sái', 
    'Hành tây trắng củ nhỏ', 'Xích tiểu đậu', 'Cà chua baby', 'Cao sâm 100gr', 
    'Nước chuối lên men', 'Trà xích tiểu đậu', 'Cải Bó xôi', 'Bột khoai lang chín', 
    'Bắp cải thảo', 'Tiêu hạt sấy khô', 'Gói xông nhà', 'Bắp cải sú', 
    'Dưa leo giống Nhật', 'Đậu ve', 'Hành lá sấy', 'Tỏi Lý Sơn', 'Ớt hiểm sấy khô'
  ];

  const productsToUse: any[] = [];

  for (let i = 0; i < productNames.length; i++) {
    const pName = productNames[i];
    const basePrice = Math.floor(Math.random() * 80 + 20) * 1000; // 20k -> 100k
    
    const p = await prisma.product.upsert({
      where: { sku: `MF-${1000 + i}` },
      update: {},
      create: {
        name: pName,
        sku: `MF-${1000 + i}`,
        retailPrice: basePrice,
        costPrice: basePrice * 0.6,
        stock: Math.floor(Math.random() * 500) + 50,
        unit: 'Gói',
        isActive: true,
      },
    });
    productsToUse.push(p);

    // Seed group prices for this product
    for (const g of groupsToUse) {
      if (g.isDefault) continue;
      await prisma.productGroupPrice.upsert({
        where: { productId_groupId: { productId: p.id, groupId: g.id } },
        update: {},
        create: {
          productId: p.id,
          groupId: g.id,
          fixedPrice: basePrice * 0.8 // Nhóm khác giảm 20% dạng fixed price
        }
      });
    }
  }
  console.log(`✅ Products: ${productNames.length} products with matrix pricing created`);

  // ============================================================
  // 4. Customers (10 Customers)
  // ============================================================
  const customerNames = [
    'Nguyễn Văn An', 'Trần Thị Bình', 'Lê Văn Cường', 'Phạm Thị Dung', 'Hoàng Văn Em', 
    'Đặng Thị Phương', 'Bùi Văn Giàu', 'Đỗ Thị Hạnh', 'Ngô Văn Ích', 'Lý Thị Kim'
  ];

  for (let i = 0; i < customerNames.length; i++) {
    const phone = `090${Math.floor(Math.random() * 9000000) + 1000000}`; // 10 digits
    const group = groupsToUse[i % groupsToUse.length]; // evenly distribute
    
    await prisma.customer.upsert({
      where: { phone: phone },
      update: {},
      create: {
        fullName: customerNames[i],
        phone: phone,
        groupId: group.id,
        isActive: true,
      },
    });
  }
  console.log(`✅ Customers: ${customerNames.length} sample customers created`);

  // ============================================================
  // 5. Cancel Reasons
  // ============================================================
  const cancelReasons = [
    { label: 'Sai số điện thoại', sortOrder: 1 },
    { label: 'Khách đổi ý', sortOrder: 2 },
    { label: 'Hết hàng', sortOrder: 3 },
    { label: 'Lý do khác', sortOrder: 99 },
  ];

  for (const reason of cancelReasons) {
    await prisma.cancelReason.upsert({
      where: { label: reason.label },
      update: {},
      create: { label: reason.label, sortOrder: reason.sortOrder },
    });
  }

  // ============================================================
  // 6. Company Settings
  // ============================================================
  const existingSettings = await prisma.companySettings.findFirst();
  if (!existingSettings) {
    await prisma.companySettings.create({
      data: {
        name: 'Công ty TNHH Mountain Farmers',
        address: 'Việt Nam',
        invoiceFooter: 'Cảm ơn quý khách đã tin tưởng!',
      },
    });
  }

  console.log('\n🎉 Seed completed successfully!');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
}

main()
  .catch((e) => {
    console.error('❌ Seed failed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
