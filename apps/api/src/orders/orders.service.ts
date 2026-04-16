import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { PricingEngineService } from './pricing.service';
import { CreateOrderDto, UpdateOrderStatusDto, UpdateOrderDto } from './dto/order.dto';
import { Prisma } from '@prisma/client';

// ─── Status Transition Rules (State Machine) ─────────────────────
const VALID_TRANSITIONS: Record<string, string[]> = {
  PENDING:    ['PROCESSING', 'CANCELLED'],
  PROCESSING: ['SHIPPING', 'CANCELLED'],
  SHIPPING:   ['COMPLETED', 'RETURNED'],
  COMPLETED:  ['RETURNED'],
  RETURNED:   [],
  CANCELLED:  [],
};

@Injectable()
export class OrdersService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly pricingEngine: PricingEngineService
  ) {}

  async create(userId: string, data: CreateOrderDto) {
    if (!data.items || data.items.length === 0) {
      throw new BadRequestException('Đơn hàng phải có ít nhất 1 sản phẩm');
    }

    // 1. Dùng PricingEngine để tính giá và lấy snapshot
    const pricingResult = await this.pricingEngine.calculatePricing(data.customerId, data.items);

    const subtotal = pricingResult.subtotal;
    const discountAmount = new Prisma.Decimal(data.discountAmount || 0);
    const shippingFee = new Prisma.Decimal(data.shippingFee || 0);
    const totalAmount = subtotal.minus(discountAmount).plus(shippingFee);

    const today = new Date();
    const dateStr = today.toISOString().slice(0, 10).replace(/-/g, ''); // YYYYMMDD
    let lastError;

    // Retry loop bao bọc TOÀN BỘ quá trình tạo Order (#3)
    for (let attempt = 0; attempt < 5; attempt++) {
      try {
        const count = await this.prisma.order.count({
          where: { orderNumber: { startsWith: `ORD-${dateStr}` } }
        });
        const seq = (count + 1 + attempt).toString().padStart(4, '0');
        const orderNumber = `ORD-${dateStr}-${seq}`;

        return await this.prisma.$transaction(async (tx) => {
          return await tx.order.create({
            data: {
              orderNumber,
              customerId: data.customerId,
              snapshotCustomerName: pricingResult.customerSnapshot.snapshotCustomerName,
              snapshotCustomerPhone: pricingResult.customerSnapshot.snapshotCustomerPhone,
              createdById: userId,
              deliveryStatus: 'PENDING',
              subtotal,
              discountAmount,
              shippingFee,
              totalAmount,
              notes: data.notes,
              items: {
                create: pricingResult.orderItemsData
              }
            },
            include: { items: true, customer: true }
          });
        });
      } catch (e: any) {
        if (e.code === 'P2002') { // Trùng orderNumber
          lastError = e;
          continue;
        }
        throw e;
      }
    }

    // Fallback nếu 5 lần vẫn trùng (do hệ thống quá tải cực đỉnh)
    const fallbackSeq = Date.now().toString().slice(-6);
    return await this.prisma.order.create({
      data: {
        orderNumber: `ORD-${dateStr}-${fallbackSeq}`,
        customerId: data.customerId,
        snapshotCustomerName: pricingResult.customerSnapshot.snapshotCustomerName,
        snapshotCustomerPhone: pricingResult.customerSnapshot.snapshotCustomerPhone,
        createdById: userId,
        deliveryStatus: 'PENDING',
        subtotal,
        discountAmount,
        shippingFee,
        totalAmount,
        notes: data.notes,
        items: {
          create: pricingResult.orderItemsData
        }
      },
      include: { items: true, customer: true }
    });
  }

  async update(id: string, userId: string, data: UpdateOrderDto) {
    if (!data.items || data.items.length === 0) {
      throw new BadRequestException('Đơn hàng phải có ít nhất 1 sản phẩm');
    }

    const order = await this.prisma.order.findUnique({
      where: { id },
      include: { items: true }
    });

    if (!order) {
      throw new NotFoundException('Không tìm thấy đơn hàng');
    }

    if (order.deliveryStatus !== 'PENDING') {
      throw new BadRequestException('Chỉ cho phép chỉnh sửa các đơn hàng đang ở trạng thái xử lý!');
    }

    // 1. Dùng PricingEngine để tính giá và lấy snapshot
    const pricingResult = await this.pricingEngine.calculatePricing(data.customerId, data.items);

    const subtotal = pricingResult.subtotal;
    const discountAmount = new Prisma.Decimal(data.discountAmount || 0);
    const shippingFee = new Prisma.Decimal(data.shippingFee || 0);
    const totalAmount = subtotal.minus(discountAmount).plus(shippingFee);

    return this.prisma.$transaction(async (tx) => {
      // 2. Xoá các hạng mục cũ
      await tx.orderItem.deleteMany({
        where: { orderId: id }
      });

      // 3. Cập nhật Order & OrderItems Snapshot mới
      const updatedOrder = await tx.order.update({
        where: { id },
        data: {
          customerId: data.customerId,
          snapshotCustomerName: pricingResult.customerSnapshot.snapshotCustomerName,
          snapshotCustomerPhone: pricingResult.customerSnapshot.snapshotCustomerPhone,
          subtotal,
          discountAmount,
          shippingFee,
          totalAmount,
          notes: data.notes,
          items: {
            create: pricingResult.orderItemsData
          }
        },
        include: { items: true, customer: true }
      });

      return updatedOrder;
    });
  }

  async findAll(query: { skip?: number; take?: number; search?: string; status?: string }) {
    const { skip = 0, take = 50, search, status } = query;
    const where: Prisma.OrderWhereInput = {};

    if (search) {
      where.OR = [
        { orderNumber: { contains: search, mode: 'insensitive' } },
        { snapshotCustomerName: { contains: search, mode: 'insensitive' } },
        { snapshotCustomerPhone: { contains: search } },
      ];
    }
    
    if (status) {
      where.deliveryStatus = status as any;
    }

    const [total, data] = await Promise.all([
      this.prisma.order.count({ where }),
      this.prisma.order.findMany({
        where,
        skip: Number(skip),
        take: Number(take),
        include: {
          createdBy: { select: { fullName: true } }
        },
        orderBy: { createdAt: 'desc' },
      }),
    ]);

    return { total, data };
  }

  async findOne(id: string) {
    const order = await this.prisma.order.findUnique({
      where: { id },
      include: {
        items: true,
        createdBy: true,
        customer: { include: { group: true } },
        cancelReason: true,
      }
    });
    if (!order) throw new NotFoundException('Không tìm thấy đơn hàng');

    const auditLogs = await this.prisma.auditLog.findMany({
      where: { entityType: 'Order', entityId: id },
      include: { user: { select: { fullName: true } } },
      orderBy: { createdAt: 'desc' }
    });

    return { ...order, auditLogs };
  }

  async updateStatus(id: string, data: UpdateOrderStatusDto) {
    const order = await this.prisma.order.findUnique({
      where: { id },
      include: { items: true }
    });
    
    if (!order) throw new NotFoundException('Không tìm thấy đơn hàng');

    // Validate status transition (State Machine)
    if (data.deliveryStatus) {
      const allowedTransitions = VALID_TRANSITIONS[order.deliveryStatus];
      if (!allowedTransitions || !allowedTransitions.includes(data.deliveryStatus)) {
        throw new BadRequestException(
          `Không thể chuyển trạng thái từ "${order.deliveryStatus}" sang "${data.deliveryStatus}". ` +
          `Trạng thái hợp lệ: ${allowedTransitions?.join(', ') || 'Không có'}`
        );
      }
    }

    return this.prisma.$transaction(async (tx) => {
      // Inventory updates have been completely removed.
      return tx.order.update({
        where: { id },
        data: {
          deliveryStatus: data.deliveryStatus,
          cancelReasonId: data.cancelReasonId,
          cancelNotes: data.cancelNotes,
        }
      });
    });
  }

  async remove(id: string) {
    const order = await this.prisma.order.findUnique({ where: { id }, include: { items: true } });
    if (!order) throw new NotFoundException('Không tìm thấy đơn');

    return this.prisma.$transaction(async (tx) => {
      // Inventory return has been completely removed.
      return tx.order.delete({ where: { id } });
    });
  }

  async import(userId: string, orders: any[]) {
    let successCount = 0;
    
    // Find default group
    let defaultGroup = await this.prisma.customerGroup.findFirst({ where: { isDefault: true } });
    if (!defaultGroup) {
      defaultGroup = await this.prisma.customerGroup.findFirst();
    }

    for (const o of orders) {
      try {
        // Find or create customer
        let customerId = '';
        if (o.customerPhone) {
          const existingCust = await this.prisma.customer.findUnique({ where: { phone: String(o.customerPhone).trim() } });
          if (existingCust) {
            customerId = existingCust.id;
          }
        }
        
        if (!customerId) {
          const newCust = await this.prisma.customer.create({
            data: {
              fullName: o.customerName || 'Khách vãng lai',
              phone: o.customerPhone ? String(o.customerPhone).trim() : null,
              groupId: defaultGroup?.id as string,
            }
          });
          customerId = newCust.id;
        }

        // Parse items
        const skus = o.productSkus.split(',').map((s: string) => s.trim());
        const qtys = o.quantities.split(',').map((q: string) => parseFloat(q.trim()));
        
        const items = [];
        for (let i = 0; i < skus.length; i++) {
          const sku = skus[i];
          const qty = qtys[i];
          if (!sku || isNaN(qty)) continue;
          
          const product = await this.prisma.product.findUnique({ where: { sku } });
          if (product) {
            items.push({ productId: product.id, quantity: qty });
          }
        }

        if (items.length > 0) {
          await this.create(userId, {
            customerId,
            items,
            shippingFee: Number(o.shippingFee) || 0,
            discountAmount: Number(o.discountAmount) || 0,
            notes: o.notes || 'Imported from Excel',
          });
          successCount++;
        }
      } catch (e: any) {
        // Skip invalid order row
      }
    }
    
    return { successCount, totalTried: orders.length };
  }
}

