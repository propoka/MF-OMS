import {
  Injectable,
  NotFoundException,
  BadRequestException,
  OnModuleInit,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { PricingEngineService } from './pricing.service';
import {
  CreateOrderDto,
  UpdateOrderStatusDto,
  UpdateOrderDto,
} from './dto/order.dto';
import { Prisma } from '@prisma/client';

// ─── Status Transition Rules (State Machine) ─────────────────────
const VALID_TRANSITIONS: Record<string, string[]> = {
  PENDING: ['PROCESSING', 'CANCELLED'],
  PROCESSING: ['SHIPPING', 'CANCELLED'],
  SHIPPING: ['COMPLETED', 'RETURNED'],
  COMPLETED: ['RETURNED'],
  RETURNED: [],
  CANCELLED: [],
};

@Injectable()
export class OrdersService implements OnModuleInit {
  constructor(
    private readonly prisma: PrismaService,
    private readonly pricingEngine: PricingEngineService,
  ) {}

  async onModuleInit() {
    await this.prisma.$executeRawUnsafe(
      `CREATE SEQUENCE IF NOT EXISTS order_seq START 1;`,
    );
  }

  async create(userId: string, data: CreateOrderDto) {
    if (!data.items || data.items.length === 0) {
      throw new BadRequestException('Đơn hàng phải có ít nhất 1 sản phẩm');
    }

    // 1. Dùng PricingEngine để tính giá và lấy snapshot
    const pricingResult = await this.pricingEngine.calculatePricing(
      data.customerId,
      data.items,
    );

    const subtotal = pricingResult.subtotal;
    const discountAmount = new Prisma.Decimal(data.discountAmount || 0);
    const shippingFee = new Prisma.Decimal(data.shippingFee || 0);
    const totalAmount = subtotal.minus(discountAmount).plus(shippingFee);

    if (totalAmount.lessThan(0)) {
      throw new BadRequestException(
        'Tổng tiền đơn hàng không thể là số âm. Vui lòng kiểm tra lại Giảm giá.',
      );
    }

    const today = new Date();
    const dateStr = today.toISOString().slice(0, 10).replace(/-/g, ''); // YYYYMMDD

    // ── Atomic sequence generation to avoid race condition ──
    const nextValResult = await this.prisma.$queryRawUnsafe<any[]>(
      `SELECT nextval('order_seq');`,
    );
    const seqNum = Number(nextValResult[0].nextval);
    const orderNumber = `ORD-${dateStr}-${seqNum.toString().padStart(4, '0')}`;

    return await this.prisma.$transaction(async (tx) => {
      return await tx.order.create({
        data: {
          orderNumber,
          customerId: data.customerId,
          snapshotCustomerName:
            pricingResult.customerSnapshot.snapshotCustomerName,
          snapshotCustomerPhone:
            pricingResult.customerSnapshot.snapshotCustomerPhone,
          createdById: userId,
          deliveryStatus: 'PENDING',
          subtotal,
          discountAmount,
          shippingFee,
          totalAmount,
          notes: data.notes,
          items: {
            create: pricingResult.orderItemsData,
          },
        },
        include: { items: { orderBy: { id: 'asc' } }, customer: true },
      });
    });
  }

  async update(id: string, userId: string, data: UpdateOrderDto) {
    if (!data.items || data.items.length === 0) {
      throw new BadRequestException('Đơn hàng phải có ít nhất 1 sản phẩm');
    }

    const order = await this.prisma.order.findUnique({
      where: { id },
      include: { items: { orderBy: { id: 'asc' } } },
    });

    if (!order) {
      throw new NotFoundException('Không tìm thấy đơn hàng');
    }

    if (order.deliveryStatus !== 'PENDING') {
      throw new BadRequestException(
        'Chỉ cho phép chỉnh sửa các đơn hàng đang ở trạng thái chờ xử lý (PENDING)!',
      );
    }

    // 1. Dùng PricingEngine để tính giá và lấy snapshot
    const pricingResult = await this.pricingEngine.calculatePricing(
      data.customerId,
      data.items,
    );

    const subtotal = pricingResult.subtotal;
    const discountAmount = new Prisma.Decimal(data.discountAmount || 0);
    const shippingFee = new Prisma.Decimal(data.shippingFee || 0);
    const totalAmount = subtotal.minus(discountAmount).plus(shippingFee);

    if (totalAmount.lessThan(0)) {
      throw new BadRequestException(
        'Tổng tiền đơn hàng không thể là số âm. Vui lòng kiểm tra lại Giảm giá.',
      );
    }

    return this.prisma.$transaction(async (tx) => {
      const existingItems = await tx.orderItem.findMany({ where: { orderId: id } });
      const newItemsData = pricingResult.orderItemsData;
      
      const opsData: any[] = [];
      const usedExistingIds = new Set<string>();

      for (const newItem of newItemsData) {
        const existing = existingItems.find(e => e.productId === newItem.productId && !usedExistingIds.has(e.id));
        if (existing) {
          usedExistingIds.add(existing.id);
          opsData.push(tx.orderItem.update({
            where: { id: existing.id },
            data: newItem,
          }));
        } else {
          opsData.push(tx.orderItem.create({
            data: { ...newItem, orderId: id },
          }));
        }
      }

      const toDeleteIds = existingItems.filter(e => !usedExistingIds.has(e.id)).map(e => e.id);
      if (toDeleteIds.length > 0) {
        opsData.push(tx.orderItem.deleteMany({
          where: { id: { in: toDeleteIds } },
        }));
      }

      await Promise.all(opsData);

      // Cập nhật Order và trả về cùng thông tin Snapshot mới
      return tx.order.update({
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
        },
        include: { items: { orderBy: { id: 'asc' } }, customer: true },
      });
    });
  }

  async findAll(query: {
    skip?: number;
    take?: number;
    search?: string;
    status?: string;
  }) {
    const { skip = 0, take = 50, search, status } = query;
    const safeTake = Math.min(Number(take) || 50, 200);
    const where: Prisma.OrderWhereInput = { deletedAt: null };

    if (search) {
      where.OR = [
        { orderNumber: { contains: search, mode: 'insensitive' } },
        { snapshotCustomerName: { contains: search, mode: 'insensitive' } },
        { snapshotCustomerPhone: { contains: search } },
      ];
    }

    if (status) {
      const validStatuses = [
        'PENDING',
        'PROCESSING',
        'SHIPPING',
        'COMPLETED',
        'RETURNED',
        'CANCELLED',
      ];
      if (!validStatuses.includes(status.toUpperCase())) {
        throw new BadRequestException('Trạng thái đơn hàng không hợp lệ');
      }
      where.deliveryStatus = status.toUpperCase() as any;
    }

    const [total, data] = await Promise.all([
      this.prisma.order.count({ where }),
      this.prisma.order.findMany({
        where,
        skip: Number(skip),
        take: safeTake,
        include: {
          createdBy: { select: { fullName: true } },
          items: { orderBy: { id: 'asc' } },
          customer: { include: { group: true } },
        },
        orderBy: { createdAt: 'desc' },
      }),
    ]);

    return { total, data };
  }

  async findOne(id: string) {
    const order = await this.prisma.order.findFirst({
      where: { id, deletedAt: null },
      include: {
        items: { orderBy: { id: 'asc' } },
        createdBy: true,
        customer: { include: { group: true } },
        cancelReason: true,
      },
    });
    if (!order) throw new NotFoundException('Không tìm thấy đơn hàng');

    const auditLogs = await this.prisma.auditLog.findMany({
      where: { entityType: 'Order', entityId: id },
      include: { user: { select: { fullName: true } } },
      orderBy: { createdAt: 'desc' },
    });

    return { ...order, auditLogs };
  }

  async updateStatus(id: string, data: UpdateOrderStatusDto) {
    const order = await this.prisma.order.findUnique({
      where: { id },
      include: { items: true },
    });

    if (!order) throw new NotFoundException('Không tìm thấy đơn hàng');

    // Validate status transition (State Machine)
    if (data.deliveryStatus) {
      const allowedTransitions = VALID_TRANSITIONS[order.deliveryStatus];
      if (
        !allowedTransitions ||
        !allowedTransitions.includes(data.deliveryStatus)
      ) {
        throw new BadRequestException(
          `Không thể chuyển trạng thái từ "${order.deliveryStatus}" sang "${data.deliveryStatus}". ` +
            `Trạng thái hợp lệ: ${allowedTransitions?.join(', ') || 'Không có'}`,
        );
      }
    }

    if (data.deliveryStatus === 'CANCELLED' && !data.cancelReasonId) {
      throw new BadRequestException('Vui lòng chọn lý do huỷ đơn hàng');
    }

    return this.prisma.$transaction(async (tx) => {
      // Optimistic Locking Control để ngăn ngừa Race Condition
      const updateResult = await tx.order.updateMany({
        where: { id, deliveryStatus: order.deliveryStatus },
        data: {
          deliveryStatus: data.deliveryStatus,
          cancelReasonId: data.cancelReasonId,
          cancelNotes: data.cancelNotes,
        },
      });

      if (updateResult.count === 0) {
        throw new BadRequestException('Trạng thái đơn hàng đã bị đối tượng khác cập nhật. Vui lòng tải lại trang.');
      }

      return tx.order.findUnique({
        where: { id },
      });
    });
  }

  async remove(id: string) {
    const order = await this.prisma.order.findFirst({
      where: { id, deletedAt: null },
      include: { items: true },
    });
    if (!order) throw new NotFoundException('Không tìm thấy đơn');

    if (order.deliveryStatus !== 'PENDING' && order.deliveryStatus !== 'CANCELLED') {
      throw new BadRequestException(
        'Cảnh báo: Chỉ cho phép xóa đơn hàng đang ở trạng thái Chờ xử lý hoặc Đã Huỷ.',
      );
    }

    return this.prisma.$transaction(async (tx) => {
      return tx.order.update({
        where: { id },
        data: { deletedAt: new Date() },
      });
    });
  }

  async import(userId: string, orders: any[]) {
    let successCount = 0;
    const errors: { row: number; reason: string }[] = [];

    // Find default group
    let defaultGroup = await this.prisma.customerGroup.findFirst({
      where: { isDefault: true },
    });
    if (!defaultGroup) {
      defaultGroup = await this.prisma.customerGroup.findFirst();
    }

    // ── Batch pre-fetch: 1 query cho tất cả customers, 1 query cho tất cả products ──

    // Thu thập tất cả SĐT và SKU cần tra cứu
    const allPhones = new Set<string>();
    const allSkus = new Set<string>();
    for (const o of orders) {
      if (o.customerPhone) allPhones.add(String(o.customerPhone).trim());
      if (o.productSkus) {
        o.productSkus.split(',').forEach((s: string) => {
          const sku = s.trim();
          if (sku) allSkus.add(sku);
        });
      }
    }

    // Batch lookup customers — 1 query thay vì N query
    const existingCustomers = allPhones.size > 0
      ? await this.prisma.customer.findMany({
          where: { phone: { in: [...allPhones] } },
          select: { id: true, phone: true },
        })
      : [];
    const customerPhoneMap = new Map(
      existingCustomers.map((c) => [c.phone!, c.id]),
    );

    // Batch lookup products — 1 query thay vì N query
    const existingProducts = allSkus.size > 0
      ? await this.prisma.product.findMany({
          where: { sku: { in: [...allSkus] } },
          select: { id: true, sku: true },
        })
      : [];
    const productSkuMap = new Map(
      existingProducts.map((p) => [p.sku, p.id]),
    );

    // ── Xử lý từng đơn hàng (chỉ create khi cần) ──
    for (const o of orders) {
      try {
        // Find or create customer — dùng cache thay vì query
        let customerId = '';
        const phone = o.customerPhone ? String(o.customerPhone).trim() : null;

        if (phone && customerPhoneMap.has(phone)) {
          customerId = customerPhoneMap.get(phone)!;
        }

        if (!customerId) {
          const newCust = await this.prisma.customer.create({
            data: {
              fullName: o.customerName || 'Khách vãng lai',
              phone: phone,
              groupId: defaultGroup?.id as string,
            },
          });
          customerId = newCust.id;
          // Cập nhật cache cho các dòng sau có thể dùng cùng SĐT
          if (phone) customerPhoneMap.set(phone, newCust.id);
        }

        // Parse items — dùng cache thay vì query từng SKU
        const skus = o.productSkus.split(',').map((s: string) => s.trim());
        const qtys = o.quantities
          .split(',')
          .map((q: string) => parseFloat(q.trim()));

        const items: { productId: string; quantity: number }[] = [];
        for (let i = 0; i < skus.length; i++) {
          const sku = skus[i];
          const qty = qtys[i];
          if (!sku || isNaN(qty)) continue;

          const productId = productSkuMap.get(sku);
          if (productId) {
            items.push({ productId, quantity: qty });
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
        errors.push({
          row: Number(o.row) || successCount + errors.length + 1,
          reason: e.message || 'Lỗi dữ liệu đơn hàng (SKU thiếu/Sai cú pháp)',
        });
      }
    }

    return { successCount, totalTried: orders.length, errors };
  }
}
