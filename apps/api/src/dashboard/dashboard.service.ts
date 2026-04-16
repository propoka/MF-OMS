import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class DashboardService {
  constructor(private prisma: PrismaService) {}

  async getKpis() {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const firstDayOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);

    // Fix #13: Batch queries vào một Promise.all duy nhất thay vì chạy tuần tự
    const [
      revenueResult,
      revenueMonthResult,
      revenueTodayResult,
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
        where: { deliveryStatus: 'COMPLETED' },
        _sum: { totalAmount: true },
      }),
      this.prisma.order.aggregate({
        where: { 
          deliveryStatus: 'COMPLETED',
          createdAt: { gte: firstDayOfMonth }
        },
        _sum: { totalAmount: true },
      }),
      this.prisma.order.aggregate({
        where: { 
          deliveryStatus: 'COMPLETED',
          createdAt: { gte: today }
        },
        _sum: { totalAmount: true },
      }),
      // 2. Tổng đơn hàng
      this.prisma.order.count(),
      this.prisma.order.count({
        where: { deliveryStatus: { in: ['PENDING', 'PROCESSING', 'SHIPPING'] } }
      }),
      this.prisma.order.count({
        where: { createdAt: { gte: today } }
      }),
      // 3. Khách hàng
      this.prisma.customer.count(),
      this.prisma.customer.count({
        where: { createdAt: { gte: firstDayOfMonth } }
      }),
      // 6. Top 10 sản phẩm
      this.prisma.orderItem.groupBy({
        by: ['snapshotProductSku', 'snapshotProductName'],
        _sum: { lineTotal: true, quantity: true },
        orderBy: { _sum: { lineTotal: 'desc' } },
        take: 10,
        where: {
          order: { deliveryStatus: 'COMPLETED' }
        }
      }),
      // 7. Top 10 đại lý / khách hàng
      this.prisma.order.groupBy({
        by: ['snapshotCustomerPhone', 'snapshotCustomerName'],
        _sum: { totalAmount: true },
        orderBy: { _sum: { totalAmount: 'desc' } },
        take: 10,
        where: { deliveryStatus: 'COMPLETED' }
      }),
    ]);

    // 5. Biểu đồ doanh thu 7 ngày gần nhất
    const last7Days = new Date();
    last7Days.setDate(last7Days.getDate() - 6);
    last7Days.setHours(0,0,0,0);

    // Batch chart queries
    const [orders7Days, allOrders7Days] = await Promise.all([
      this.prisma.order.findMany({
        where: {
          deliveryStatus: 'COMPLETED',
          createdAt: { gte: last7Days }
        },
        select: { createdAt: true, totalAmount: true }
      }),
      this.prisma.order.findMany({
        where: { createdAt: { gte: last7Days } },
        select: { createdAt: true }
      }),
    ]);

    // Gom nhóm theo ngày
    const chartDataMap: Record<string, { revenue: number; orders: number }> = {};
    for (let i = 0; i < 7; i++) {
        const d = new Date(last7Days);
        d.setDate(d.getDate() + i);
        const dayStr = d.toLocaleDateString('vi-VN', { day: '2-digit', month: '2-digit' });
        chartDataMap[dayStr] = { revenue: 0, orders: 0 };
    }

    // Tính doanh thu
    orders7Days.forEach(o => {
        const dayStr = o.createdAt.toLocaleDateString('vi-VN', { day: '2-digit', month: '2-digit' });
        if (chartDataMap[dayStr] !== undefined) {
            chartDataMap[dayStr].revenue += Number(o.totalAmount);
        }
    });

    // Đếm lượng đơn (Toàn bộ)
    allOrders7Days.forEach(o => {
        const dayStr = o.createdAt.toLocaleDateString('vi-VN', { day: '2-digit', month: '2-digit' });
        if (chartDataMap[dayStr] !== undefined) {
            chartDataMap[dayStr].orders += 1;
        }
    });

    const revenueChart = Object.keys(chartDataMap).map(key => ({
        date: key,
        revenue: chartDataMap[key].revenue,
        orders: chartDataMap[key].orders
    }));

    return {
      revenue: {
        total: Number(revenueResult._sum.totalAmount || 0),
        thisMonth: Number(revenueMonthResult._sum.totalAmount || 0),
        today: Number(revenueTodayResult._sum.totalAmount || 0),
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
      topProducts: topProductsRaw.map(p => ({
        name: p.snapshotProductName,
        sku: p.snapshotProductSku,
        totalRevenue: Number(p._sum.lineTotal || 0),
        totalSold: Number(p._sum.quantity || 0)
      })),
      topCustomers: topCustomersRaw.map(c => ({
        name: c.snapshotCustomerName,
        phone: c.snapshotCustomerPhone,
        totalRevenue: Number(c._sum.totalAmount || 0)
      }))
    };
  }

  async getReport(startDateStr?: string, endDateStr?: string) {
    const whereClause: any = {};
    if (startDateStr || endDateStr) {
      whereClause.createdAt = {};
      if (startDateStr) whereClause.createdAt.gte = new Date(startDateStr);
      if (endDateStr) {
        const end = new Date(endDateStr);
        end.setHours(23, 59, 59, 999);
        whereClause.createdAt.lte = end;
      }
    }

    const orders = await this.prisma.order.findMany({
      where: whereClause,
      include: {
        items: true,
        customer: {
          include: { group: true }
        },
        createdBy: true
      },
      orderBy: { createdAt: 'desc' }
    });

    let totalOrders = orders.length;
    let completedOrdersCount = 0;
    
    let grossRevenue = 0; // tổng thu ko tính huỷ/hoàn
    let netRevenue = 0;   // tổng thu chỉ đơn COMPLETED
    let totalShippingFee = 0;
    let totalDiscount = 0;
    let cancelledOrReturnedCount = 0;

    const statusBreakdown: Record<string, { count: number; revenue: number }> = {
      'PENDING': { count: 0, revenue: 0 },
      'PROCESSING': { count: 0, revenue: 0 },
      'SHIPPING': { count: 0, revenue: 0 },
      'COMPLETED': { count: 0, revenue: 0 },
      'RETURNED': { count: 0, revenue: 0 },
      'CANCELLED': { count: 0, revenue: 0 },
    };

    const customerMap: Record<string, { name: string, phone: string | null, revenue: number, orderCount: number }> = {};
    const productMap: Record<string, { name: string, sku: string, revenue: number, sold: number }> = {};

    orders.forEach(o => {
      const orderLevelDiscount = Number(o.discountAmount || 0);
      let itemsLevelDiscount = 0;
      if (o.items) {
        o.items.forEach(i => itemsLevelDiscount += Number(i.lineDiscount || 0));
      }
      const combinedDiscount = orderLevelDiscount + itemsLevelDiscount;
      const orderTotal = Number(o.totalAmount || 0);

      // Status breakdown
      if (statusBreakdown[o.deliveryStatus] !== undefined) {
        statusBreakdown[o.deliveryStatus].count += 1;
        statusBreakdown[o.deliveryStatus].revenue += orderTotal;
      }

      // Net revenue (only COMPLETED)
      if (o.deliveryStatus === 'COMPLETED') {
        completedOrdersCount++;
        netRevenue += orderTotal;

        // Top KH và Top SP chỉ tính trên đơn hoàn thành để đảm bảo số liệu thực tế
        if (!customerMap[o.customerId]) {
          customerMap[o.customerId] = { name: o.snapshotCustomerName, phone: o.snapshotCustomerPhone, revenue: 0, orderCount: 0 };
        }
        customerMap[o.customerId].revenue += orderTotal;
        customerMap[o.customerId].orderCount += 1;

        if (o.items) {
          o.items.forEach(i => {
            if (!productMap[i.productId]) {
              productMap[i.productId] = { name: i.snapshotProductName, sku: i.snapshotProductSku, revenue: 0, sold: 0 };
            }
            productMap[i.productId].revenue += Number(i.lineTotal || 0);
            productMap[i.productId].sold += Number(i.quantity || 0);
          });
        }
      }

      if (o.deliveryStatus === 'CANCELLED' || o.deliveryStatus === 'RETURNED') {
        cancelledOrReturnedCount++;
      }
      
      if (o.deliveryStatus !== 'CANCELLED' && o.deliveryStatus !== 'RETURNED') {
        grossRevenue += orderTotal;
        totalShippingFee += Number(o.shippingFee || 0);
        totalDiscount += combinedDiscount;
      }
    });

    const aov = completedOrdersCount > 0 ? (netRevenue / completedOrdersCount) : 0;
    const cancelRate = totalOrders > 0 ? (cancelledOrReturnedCount / totalOrders) * 100 : 0;

    const topCustomers = Object.values(customerMap).sort((a, b) => b.revenue - a.revenue).slice(0, 10);
    const topProducts = Object.values(productMap).sort((a, b) => b.sold - a.sold).slice(0, 10);

    return {
      summary: {
        totalOrders,
        completedOrdersCount,
        grossRevenue,
        netRevenue,
        totalShippingFee,
        totalDiscount,
        aov,
        cancelRate
      },
      overview: {
        statusBreakdown,
        topCustomers,
        topProducts
      },
      orders
    };
  }
}
