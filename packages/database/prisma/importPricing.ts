import { PrismaClient, GroupPriceType } from '@prisma/client';
import * as fs from 'fs';

const prisma = new PrismaClient();

function parseCSVRow(row: string): string[] {
  const arr: string[] = [];
  let cur = '';
  let inQuote = false;
  for (let i = 0; i < row.length; i++) {
    const c = row[i];
    if (c === '"') {
      inQuote = !inQuote;
    } else if (c === ',' && !inQuote) {
      arr.push(cur);
      cur = '';
    } else {
      cur += c;
    }
  }
  arr.push(cur);
  return arr.map(s => s.trim());
}

async function main() {
  console.log('🌱 Starting import of CRM Pricing data...');

  const csvPath = 'e:\\Project\\MF-quanlydon\\Bản sao của MF - CRM Sheet - Bảng giá.csv';
  if (!fs.existsSync(csvPath)) {
    console.error('Không tìm thấy file CSV tại đường dẫn:', csvPath);
    return;
  }

  const csvData = fs.readFileSync(csvPath, 'utf-8');
  const lines = csvData.split('\n').filter(line => line.trim().length > 0);
  
  if (lines.length === 0) {
    console.log('No data found in CSV.');
    return;
  }
  
  const headers = parseCSVRow(lines[0]);
  
  const groupsToCreate = [
    { name: 'Khách lẻ', isDefault: true, priceType: GroupPriceType.PERCENTAGE, discountPercent: 0 },
    { name: 'Khách sỉ', isDefault: false, priceType: GroupPriceType.FIXED, discountPercent: 0 },
    ...headers.slice(5).map(h => ({ name: h, isDefault: false, priceType: GroupPriceType.FIXED, discountPercent: 0 }))
  ];

  console.log(`Creating/Ensuring ${groupsToCreate.length} Customer Groups...`);
  const groupMap: Record<string, string> = {}; 
  
  for (const g of groupsToCreate) {
    if (!g.name) continue;
    const dbGroup = await prisma.customerGroup.upsert({
      where: { name: g.name },
      create: {
        name: g.name,
        description: `Imported group from CRM`,
        priceType: g.priceType,
        isDefault: g.isDefault,
        discountPercent: g.discountPercent
      },
      update: {
        priceType: g.priceType,
        isDefault: g.isDefault,
      }
    });
    groupMap[g.name] = dbGroup.id;
  }
  console.log('✅ Customer Groups ensured.');

  let skipCount = 0;
  let successCount = 0;

  for (let i = 1; i < lines.length; i++) {
    const row = parseCSVRow(lines[i]);
    if (row.length < 4) {
      skipCount++;
      continue;
    }

    const productName = row[0];
    const sku = row[1];
    const unit = row[2];
    const rawRetail = row[3];
    
    if (!sku) {
      skipCount++;
      continue;
    }

    const retailPrice = Number(rawRetail.replace(/\D/g, '')) || 0;

    // UPSERT Product
    const product = await prisma.product.upsert({
      where: { sku: sku },
      create: {
        name: productName,
        sku: sku,
        unit: unit || 'Cái',
        retailPrice: retailPrice,
        isActive: true,
      },
      update: {
        name: productName,
        unit: unit || undefined,
        retailPrice: retailPrice,
        isActive: true,
      }
    });

    // MAP GROUP PRICES
    const rawWholesale = row[4];
    await processGroupPrice(product.id, groupMap['Khách sỉ'], rawWholesale, retailPrice);

    for (let col = 5; col < row.length; col++) {
      const groupName = headers[col];
      const rawPrice = row[col];
      if (groupName && groupMap[groupName]) {
        await processGroupPrice(product.id, groupMap[groupName], rawPrice, retailPrice);
      }
    }
    
    successCount++;
    if (successCount % 50 === 0) {
      console.log(`...Processed ${successCount} products...`);
    }
  }

  console.log(`✅ Import finished. Processed ${successCount} products. Skipped ${skipCount} lines.`);
}

async function processGroupPrice(productId: string, groupId: string, rawPrice: string | undefined, retailPrice: number) {
  if (!groupId) return;
  
  if (!rawPrice || rawPrice.trim() === '') {
    await prisma.productGroupPrice.deleteMany({
      where: { productId, groupId }
    });
    return;
  }
  
  const price = Number(rawPrice.replace(/\D/g, ''));
  if (isNaN(price)) return;
  
  // Dọn dẹp số 0 hoặc bằng số giá bán lẻ
  if (price === 0 || price === retailPrice) {
    await prisma.productGroupPrice.deleteMany({
      where: { productId, groupId }
    });
    return;
  }

  await prisma.productGroupPrice.upsert({
    where: { productId_groupId: { productId, groupId } },
    create: {
      productId,
      groupId,
      fixedPrice: price
    },
    update: {
      fixedPrice: price
    }
  });
}

main()
  .catch((e) => {
    console.error('❌ Import failed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
