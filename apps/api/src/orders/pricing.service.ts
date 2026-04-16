import { Injectable, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { Prisma, PriceSource } from '@prisma/client';

export interface OrderItemInput {
  productId: string;
  quantity: number;
  manualDiscount?: number;
}

@Injectable()
export class PricingEngineService {
  constructor(private prisma: PrismaService) {}

  async calculatePricing(customerId: string, items: OrderItemInput[]) {
    // 1. Fetch Customer with Group and SpecialPrices for these items
    const customer = await this.prisma.customer.findUnique({
      where: { id: customerId },
      include: {
        group: true,
        specialPrices: {
          where: { productId: { in: items.map(i => i.productId) } },
        },
      },
    });

    if (!customer) {
      throw new BadRequestException('Không tìm thấy khách hàng');
    }

    // 2. Fetch Products with GroupPrices for customer's group
    const products = await this.prisma.product.findMany({
      where: { id: { in: items.map(i => i.productId) } },
      include: {
        groupPrices: {
          where: { groupId: customer.groupId },
        },
      },
    });

    // 3. Process each item to find the best price
    const orderItemsData: any[] = [];
    let subtotal = new Prisma.Decimal(0);

    for (const itemInput of items) {
      const product = products.find(p => p.id === itemInput.productId);
      if (!product) {
        throw new BadRequestException(`Không tìm thấy sản phẩm ID ${itemInput.productId}`);
      }
      if (!product.isActive) {
        throw new BadRequestException(`Sản phẩm ${product.name} đang ngừng kinh doanh`);
      }

      let finalPrice = new Prisma.Decimal(product.retailPrice);
      let source: PriceSource = 'RETAIL';
      let note = 'Áp dụng giá bán lẻ';

      // Rules: SPECIAL > GROUP > RETAIL
      const specialPriceDoc = customer.specialPrices.find(sp => sp.productId === product.id);
      
      if (specialPriceDoc) {
        // Có giá đặc biệt
        finalPrice = specialPriceDoc.price;
        source = 'SPECIAL';
        note = specialPriceDoc.notes ? `Giá Đặc Biệt: ${specialPriceDoc.notes}` : 'Lấy từ Bảng giá Đặc biệt của Khách hàng';
      } else {
        // Không có giá đặc biệt, xét giá Nhóm
        if (customer.group) {
          if (customer.group.priceType === 'FIXED') {
            const groupPriceDoc = product.groupPrices?.find(
              (gp) => gp.groupId === customer.groupId,
            );
            if (groupPriceDoc && groupPriceDoc.fixedPrice != null) {
              finalPrice = groupPriceDoc.fixedPrice;
              source = 'GROUP';
              note = `Áp dụng bảng giá tĩnh nhóm: ${customer.group.name}`;
            }
          } else if (customer.group.priceType === 'PERCENTAGE' && customer.group.discountPercent != null) {
            // Giảm theo phần trăm
            const discount = new Prisma.Decimal(customer.group.discountPercent).dividedBy(100);
            finalPrice = new Prisma.Decimal(product.retailPrice).times(new Prisma.Decimal(1).minus(discount));
            source = 'GROUP';
            note = `Áp dụng chiết khấu nhóm ${customer.group.name} (-${customer.group.discountPercent}%)`;
          }
        }
      }

      const discount = new Prisma.Decimal(itemInput.manualDiscount || 0);
      let lineTotal = finalPrice.times(itemInput.quantity).minus(discount);
      if (lineTotal.lessThan(0)) {
        lineTotal = new Prisma.Decimal(0);
      }
      subtotal = subtotal.add(lineTotal);

      orderItemsData.push({
        productId: product.id,
        snapshotProductName: product.name,
        snapshotProductSku: product.sku,
        snapshotProductUnit: product.unit,
        snapshotUnitPrice: finalPrice,
        priceSource: source,
        pricingNote: note,
        quantity: itemInput.quantity,
        lineDiscount: discount,
        lineTotal: lineTotal,
      });
    }

    return {
      customerSnapshot: {
        snapshotCustomerName: customer.fullName,
        snapshotCustomerPhone: customer.phone,
      },
      orderItemsData,
      subtotal,
    };
  }
}
