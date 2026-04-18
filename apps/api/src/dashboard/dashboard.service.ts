import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class DashboardService {
  constructor(private prisma: PrismaService) {}

  async getKpis(days: number = 7) {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const firstDayOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);

    const yesterday = new Date(today);
    yesterday.setDate(yesterday.getDate() - 1);

    // Fix #13: Batch queries vào một Promise.all duy nhất thay vì chạy tuần tự
    const [
      revenueResult,
      revenueMonthResult,
      revenueTodayResult,
      revenueYesterdayResult,
      totalOrders,
      activeOrders,
      ordersTodayCount,
      totalCustomers,
      newCustomersThisMonth,
      topProductsRaw,
      topCustomersRaw,
    ] = await Promise.all([
      // 1. Tổng doanh thu (Chỉ tính đơn Completed)
      this.prisma.order.aggregate({
        where: { deliveryStatus: 'COMPLETED', deletedAt: null },
        _sum: { totalAmount: true },
      }),
      this.prisma.order.aggregate({
        where: {
          deliveryStatus: 'COMPLETED',
          createdAt: { gte: firstDayOfMonth },
          deletedAt: null,
        },
        _sum: { totalAmount: true },
      }),
      this.prisma.order.aggregate({
        where: {
          deliveryStatus: 'COMPLETED',
          createdAt: { gte: today },
          deletedAt: null,
        },
        _sum: { totalAmount: true },
      }),
      this.prisma.order.aggregate({
        where: {
          deliveryStatus: 'COMPLETED',
          createdAt: { gte: yesterday, lt: today },
          deletedAt: null,
        },
        _sum: { totalAmount: true },
      }),
      // 2. Tổng đơn hàng
      this.prisma.order.count({ where: { deletedAt: null } }),
      this.prisma.order.count({
        where: {
          deliveryStatus: { in: ['PENDING', 'PROCESSING', 'SHIPPING'] },
          deletedAt: null,
        },
      }),
      this.prisma.order.count({
        where: { createdAt: { gte: today }, deletedAt: null },
      }),
      // 3. Khách hàng
      this.prisma.customer.count(),
      this.prisma.customer.count({
        where: { createdAt: { gte: firstDayOfMonth } },
      }),
      // 6. Top 10 sản phẩm
      this.prisma.orderItem.groupBy({
        by: ['snapshotProductSku', 'snapshotProductName'],
        _sum: { lineTotal: true, quantity: true },
        orderBy: { _sum: { lineTotal: 'desc' } },
        take: 10,
        where: {
          order: { deliveryStatus: 'COMPLETED', deletedAt: null },
        },
      }),
      // 7. Top 10 đại lý / khách hàng
      this.prisma.order.groupBy({
        by: ['snapshotCustomerPhone', 'snapshotCustomerName'],
        _sum: { totalAmount: true },
        _count: { _all: true },
        orderBy: { _sum: { totalAmount: 'desc' } },
        take: 10,
        where: { deliveryStatus: 'COMPLETED', deletedAt: null },
      }),
    ]);

    // 5. Biểu đồ doanh thu X ngày gần nhất
    const lastXDays = new Date();
    lastXDays.setDate(lastXDays.getDate() - (days - 1));
    lastXDays.setHours(0, 0, 0, 0);

    // Batch chart queries
    const [ordersXDays, allOrdersXDays] = await Promise.all([
      this.prisma.order.findMany({
        where: {
          deliveryStatus: 'COMPLETED',
          createdAt: { gte: lastXDays },
          deletedAt: null,
        },
        select: { createdAt: true, totalAmount: true },
      }),
      this.prisma.order.findMany({
        where: { createdAt: { gte: lastXDays }, deletedAt: null },
        select: { createdAt: true },
      }),
    ]);

    // Gom nhóm theo ngày
    const chartDataMap: Record<string, { revenue: number; orders: number }> =
      {};
    for (let i = 0; i < days; i++) {
      const d = new Date(lastXDays);
      d.setDate(d.getDate() + i);
      const dayStr = d.toLocaleDateString('vi-VN', {
        day: '2-digit',
        month: '2-digit',
      });
      chartDataMap[dayStr] = { revenue: 0, orders: 0 };
    }

    // Tính doanh thu
    ordersXDays.forEach((o) => {
      const dayStr = o.createdAt.toLocaleDateString('vi-VN', {
        day: '2-digit',
        month: '2-digit',
      });
      if (chartDataMap[dayStr] !== undefined) {
        chartDataMap[dayStr].revenue += Number(o.totalAmount);
      }
    });

    // Đếm lượng đơn (Toàn bộ)
    allOrdersXDays.forEach((o) => {
      const dayStr = o.createdAt.toLocaleDateString('vi-VN', {
        day: '2-digit',
        month: '2-digit',
      });
      if (chartDataMap[dayStr] !== undefined) {
        chartDataMap[dayStr].orders += 1;
      }
    });

    const revenueChart = Object.keys(chartDataMap).map((key) => ({
      date: key,
      revenue: chartDataMap[key].revenue,
      orders: chartDataMap[key].orders,
    }));

    const todayRev = Number(revenueTodayResult._sum.totalAmount || 0);
    const yesterdayRev = Number(revenueYesterdayResult._sum.totalAmount || 0);
    let growthRate = 0;
    if (yesterdayRev === 0) {
      growthRate = todayRev > 0 ? 100 : 0;
    } else {
      growthRate = ((todayRev - yesterdayRev) / yesterdayRev) * 100;
    }

    return {
      revenue: {
        total: Number(revenueResult._sum.totalAmount || 0),
        thisMonth: Number(revenueMonthResult._sum.totalAmount || 0),
        today: todayRev,
        growthRate: growthRate,
      },
      orders: {
        total: totalOrders,
        active: activeOrders,
        today: ordersTodayCount,
      },
      customers: {
        total: totalCustomers,
        newThisMonth: newCustomersThisMonth,
      },
      revenueChart,
      topProducts: topProductsRaw.map((p) => ({
        name: p.snapshotProductName,
        sku: p.snapshotProductSku,
        totalRevenue: Number(p._sum.lineTotal || 0),
        totalSold: Number(p._sum.quantity || 0),
      })),
      topCustomers: topCustomersRaw.map((c) => ({
        name: c.snapshotCustomerName,
        phone: c.snapshotCustomerPhone,
        totalRevenue: Number(c._sum.totalAmount || 0),
        totalOrders: c._count ? c._count._all : 0,
      })),
    };
  }

  async getReport(startDateStr?: string, endDateStr?: string) {
    const whereClause: any = { deletedAt: null };
    if (startDateStr || endDateStr) {
      whereClause.createdAt = {};
      if (startDateStr) whereClause.createdAt.gte = new Date(`${startDateStr}T00:00:00.000+07:00`);
      if (endDateStr) {
        whereClause.createdAt.lte = new Date(`${endDateStr}T23:59:59.999+07:00`);
      }
    }

    // ── Dùng SQL aggregate thay vì load toàn bộ đơn hàng vào RAM ──

    // 1. Tổng số đơn
    const totalOrders = await this.prisma.order.count({ where: whereClause });

    // 2. Status breakdown — dùng groupBy thay vì forEach
    const statusGroupRaw = await this.prisma.order.groupBy({
      by: ['deliveryStatus'],
      where: whereClause,
      _count: { _all: true },
      _sum: { totalAmount: true },
    });

    const statusBreakdown: Record<string, { count: number; revenue: number }> = {
      PENDING: { count: 0, revenue: 0 },
      PROCESSING: { count: 0, revenue: 0 },
      SHIPPING: { count: 0, revenue: 0 },
      COMPLETED: { count: 0, revenue: 0 },
      RETURNED: { count: 0, revenue: 0 },
      CANCELLED: { count: 0, revenue: 0 },
    };

    statusGroupRaw.forEach((s) => {
      if (statusBreakdown[s.deliveryStatus] !== undefined) {
        statusBreakdown[s.deliveryStatus].count = s._count._all;
        statusBreakdown[s.deliveryStatus].revenue = Number(s._sum.totalAmount || 0);
      }
    });

    // 3. Aggregate financials — chỉ đơn hoàn thành (COMPLETED)
    const completedWhere = { ...whereClause, deliveryStatus: 'COMPLETED' as const };
    const activeWhere = {
      ...whereClause,
      deliveryStatus: { notIn: ['CANCELLED', 'RETURNED'] as const },
    };

    const [completedAgg, activeAgg, cancelledCount, completedDiscountAgg] = await Promise.all([
      // Net revenue (chỉ COMPLETED)
      this.prisma.order.aggregate({
        where: completedWhere,
        _sum: { totalAmount: true },
        _count: { _all: true },
      }),
      // Gross revenue (không tính huỷ/hoàn)
      this.prisma.order.aggregate({
        where: activeWhere,
        _sum: { totalAmount: true, shippingFee: true, discountAmount: true },
      }),
      // Đếm huỷ/hoàn
      this.prisma.order.count({
        where: { ...whereClause, deliveryStatus: { in: ['CANCELLED', 'RETURNED'] } },
      }),
      // Tổng discount ở mức line items (cho đơn active)
      this.prisma.orderItem.aggregate({
        where: { order: activeWhere },
        _sum: { lineDiscount: true },
      }),
    ]);

    const completedOrdersCount = completedAgg._count._all;
    const netRevenue = Number(completedAgg._sum.totalAmount || 0);
    const grossRevenue = Number(activeAgg._sum.totalAmount || 0);
    const totalShippingFee = Number(activeAgg._sum.shippingFee || 0);
    const totalDiscount = Number(activeAgg._sum.discountAmount || 0) + Number(completedDiscountAgg._sum.lineDiscount || 0);
    const aov = completedOrdersCount > 0 ? netRevenue / completedOrdersCount : 0;
    const cancelRate = totalOrders > 0 ? (cancelledCount / totalOrders) * 100 : 0;

    // 4. Top 10 khách hàng — dùng groupBy (chỉ đơn COMPLETED)
    const topCustomersRaw = await this.prisma.order.groupBy({
      by: ['snapshotCustomerPhone', 'snapshotCustomerName'],
      where: completedWhere,
      _sum: { totalAmount: true },
      _count: { _all: true },
      orderBy: { _sum: { totalAmount: 'desc' } },
      take: 10,
    });

    const topCustomers = topCustomersRaw.map((c) => ({
      name: c.snapshotCustomerName,
      phone: c.snapshotCustomerPhone,
      revenue: Number(c._sum.totalAmount || 0),
      orderCount: c._count._all,
    }));

    // 5. Top 10 sản phẩm — dùng groupBy (chỉ đơn COMPLETED)
    const topProductsRaw = await this.prisma.orderItem.groupBy({
      by: ['snapshotProductSku', 'snapshotProductName'],
      where: { order: completedWhere },
      _sum: { lineTotal: true, quantity: true },
      orderBy: { _sum: { lineTotal: 'desc' } },
      take: 10,
    });

    const topProducts = topProductsRaw.map((p) => ({
      name: p.snapshotProductName,
      sku: p.snapshotProductSku,
      revenue: Number(p._sum.lineTotal || 0),
      sold: Number(p._sum.quantity || 0),
    }));

    // 6. Load đơn hàng cho bảng chi tiết — CHỈ lấy các field cần thiết, có limit
    const orders = await this.prisma.order.findMany({
      where: whereClause,
      select: {
        id: true,
        orderNumber: true,
        customerId: true,
        snapshotCustomerName: true,
        snapshotCustomerPhone: true,
        deliveryStatus: true,
        subtotal: true,
        discountAmount: true,
        shippingFee: true,
        totalAmount: true,
        notes: true,
        createdAt: true,
        createdBy: { select: { fullName: true } },
      },
      orderBy: { createdAt: 'desc' },
      take: 500, // Giới hạn để tránh nạp hàng chục nghìn đơn
    });

    return {
      summary: {
        totalOrders,
        completedOrdersCount,
        grossRevenue,
        netRevenue,
        totalShippingFee,
        totalDiscount,
        aov,
        cancelRate,
      },
      overview: {
        statusBreakdown,
        topCustomers,
        topProducts,
      },
      orders,
    };
  }
}
