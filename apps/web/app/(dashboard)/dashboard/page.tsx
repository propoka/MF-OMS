'use client';

import { useState, useEffect } from 'react';
import { dashboardApi } from '@/lib/api';
import { useAuth } from '@/lib/auth-context';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { TrendingUp, Users, ShoppingCart, DollarSign, Activity, Package, Trophy, Medal, Award } from 'lucide-react';
import {
  AreaChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer
} from 'recharts';

export default function DashboardPage() {
  const { getToken } = useAuth();
  const [data, setData] = useState<any>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const token = getToken();
        if (!token) return;
        const res = await dashboardApi.getKpis(token);
        setData(res);
      } catch {
        // KPI load failed silently
      } finally {
        setIsLoading(false);
      }
    };
    fetchData();
  }, [getToken]);

  const formatMoney = (amount: number) => {
    return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(amount);
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-full">
        <Activity className="h-10 w-10 animate-pulse text-muted-foreground" />
      </div>
    );
  }

  if (!data) return null;

  return (
    <div className="flex flex-col gap-8">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold tracking-tight text-foreground flex items-center gap-2">
            Tổng quan
            <div className="hidden sm:block h-2.5 w-2.5 bg-green-500 rounded-full animate-pulse ml-2" title="Live data"></div>
          </h1>
        </div>
        <div className="text-sm text-muted-foreground bg-muted/30 px-4 py-1.5 rounded-full border font-medium hidden md:block">
          {new Date().toLocaleDateString('vi-VN', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}
        </div>
      </div>

      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <Card className="transition-all duration-300 hover:shadow-md hover:-translate-y-1 border-muted/60">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">Doanh thu hôm nay</CardTitle>
            <div className="p-2 bg-green-100 rounded-full">
              <DollarSign className="h-4 w-4 text-green-600" />
            </div>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-foreground">{formatMoney(data.revenue.today || 0)}</div>
            <p className="text-xs text-muted-foreground mt-1">
              Đã thu từ các đơn hoàn thành
            </p>
          </CardContent>
        </Card>
        
        <Card className="transition-all duration-300 hover:shadow-md hover:-translate-y-1 border-muted/60">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">Đơn hàng hôm nay</CardTitle>
            <div className="p-2 bg-blue-100 rounded-full">
              <ShoppingCart className="h-4 w-4 text-blue-600" />
            </div>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{data.orders.today || 0} đơn</div>
            <p className="text-xs text-muted-foreground mt-1">
              Đơn hàng được tạo trong ngày
            </p>
          </CardContent>
        </Card>

        <Card className="transition-all duration-300 hover:shadow-md hover:-translate-y-1 border-muted/60">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">Doanh thu tháng này</CardTitle>
            <div className="p-2 bg-emerald-100 rounded-full">
              <TrendingUp className="h-4 w-4 text-emerald-600" />
            </div>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-primary">{formatMoney(data.revenue.thisMonth)}</div>
            <p className="text-xs text-muted-foreground mt-1">
              Tổng tích luỹ: {formatMoney(data.revenue.total)}
            </p>
          </CardContent>
        </Card>

        <Card className="transition-all duration-300 hover:shadow-md hover:-translate-y-1 border-muted/60">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">Khách hàng</CardTitle>
            <div className="p-2 bg-violet-100 rounded-full">
              <Users className="h-4 w-4 text-violet-600" />
            </div>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">+{data.customers.newThisMonth} <span className="text-sm font-normal text-muted-foreground">mới</span></div>
            <p className="text-xs text-muted-foreground mt-1">
              Tổng số hồ sơ: {data.customers.total}
            </p>
          </CardContent>
        </Card>
      </div>

      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        {/* Cột trái: Biểu đồ */}
        <div className="col-span-2 flex flex-col gap-4">
          {/* Biểu đồ Doanh thu */}
          <Card className="flex-1">
            <CardHeader>
              <CardTitle>Doanh thu 7 ngày gần nhất</CardTitle>
            </CardHeader>
            <CardContent className="pl-2 pt-4">
              <ResponsiveContainer width="100%" height={250}>
                <AreaChart data={data.revenueChart} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                  <defs>
                    <linearGradient id="colorRevenue" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="oklch(0.40 0.06 45)" stopOpacity={0.3} />
                      <stop offset="95%" stopColor="oklch(0.40 0.06 45)" stopOpacity={0} />
                    </linearGradient>
                  </defs>
                  <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="hsl(var(--border))" />
                  <XAxis
                    dataKey="date"
                    stroke="hsl(var(--muted-foreground))"
                    fontSize={11}
                    tickLine={false}
                    axisLine={false}
                    tickMargin={8}
                  />
                  <YAxis
                    stroke="hsl(var(--muted-foreground))"
                    fontSize={11}
                    tickLine={false}
                    axisLine={false}
                    width={40}
                    tickFormatter={(value) => `${(value / 1000000).toFixed(0)}Tr`}
                  />
                  <Tooltip
                    formatter={(value) => [formatMoney(Number(value ?? 0)), 'Doanh thu']}
                    contentStyle={{ backgroundColor: 'hsl(var(--card))', borderRadius: '8px', border: '1px solid hsl(var(--border))' }}
                  />
                  <Area
                    type="monotone"
                    dataKey="revenue"
                    stroke="oklch(0.40 0.06 45)"
                    strokeWidth={2}
                    fillOpacity={1}
                    fill="url(#colorRevenue)"
                  />
                </AreaChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>

          {/* Biểu đồ Số lượng đơn hàng */}
          <Card className="flex-1">
            <CardHeader>
              <CardTitle>Lưu lượng đơn hàng 7 ngày</CardTitle>
            </CardHeader>
            <CardContent className="pl-2 pt-4">
              <ResponsiveContainer width="100%" height={250}>
                <AreaChart data={data.revenueChart} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                  <defs>
                    <linearGradient id="colorOrders" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="oklch(0.50 0.06 50)" stopOpacity={0.3} />
                      <stop offset="95%" stopColor="oklch(0.50 0.06 50)" stopOpacity={0} />
                    </linearGradient>
                  </defs>
                  <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="hsl(var(--border))" />
                  <XAxis
                    dataKey="date"
                    stroke="hsl(var(--muted-foreground))"
                    fontSize={11}
                    tickLine={false}
                    axisLine={false}
                    tickMargin={8}
                  />
                  <YAxis
                    stroke="hsl(var(--muted-foreground))"
                    fontSize={11}
                    tickLine={false}
                    axisLine={false}
                    width={40}
                  />
                  <Tooltip
                    formatter={(value) => [`${value} đơn`, 'Số lượng']}
                    contentStyle={{ backgroundColor: 'hsl(var(--card))', borderRadius: '8px', border: '1px solid hsl(var(--border))' }}
                  />
                  <Area
                    type="monotone"
                    dataKey="orders"
                    stroke="oklch(0.50 0.06 50)"
                    strokeWidth={2}
                    fillOpacity={1}
                    fill="url(#colorOrders)"
                  />
                </AreaChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>
        </div>

        {/* Cột phải: Top 10 Sản phẩm */}
        <Card className="col-span-1 overflow-hidden flex flex-col items-stretch h-full min-h-[500px] transition-all duration-300 hover:shadow-md border-muted/60">
          <CardHeader className="bg-muted/10 pb-3 border-b">
            <CardTitle className="text-base flex justify-between items-center text-foreground font-semibold">
              Top 10 sản phẩm bán chạy
            </CardTitle>
          </CardHeader>
          <CardContent className="p-0 flex-1 overflow-y-auto">
             {data.topProducts?.length === 0 ? (
               <div className="text-center p-6 text-muted-foreground text-sm">Chưa có dữ liệu</div>
             ) : (
               <ul className="divide-y divide-border/50">
                 {data.topProducts?.map((p: any, idx: number) => (
                   <li key={p.sku + idx} className="p-4 py-3 hover:bg-muted/30 transition-all flex gap-3 items-center group">
                     <div className="h-10 w-10 shrink-0 rounded-lg bg-muted flex flex-col items-center justify-center border text-muted-foreground group-hover:bg-primary/10 group-hover:text-primary group-hover:border-primary/20 transition-colors">
                        <Package className="h-5 w-5" />
                     </div>
                     <div className="flex flex-col flex-1 gap-1">
                       <span className="font-semibold text-sm line-clamp-1">{p.name}</span>
                       <div className="flex justify-between items-center text-xs text-muted-foreground">
                         <span>Đã bán: <b className="text-foreground">{p.totalSold}</b></span>
                         <span className="text-primary font-medium">{formatMoney(p.totalRevenue)}</span>
                       </div>
                     </div>
                   </li>
                 ))}
               </ul>
             )}
          </CardContent>
        </Card>

        {/* Cột phải: Top 10 Khách hàng */}
        <Card className="col-span-1 overflow-hidden flex flex-col items-stretch h-full min-h-[500px] transition-all duration-300 hover:shadow-md border-muted/60">
          <CardHeader className="bg-muted/10 pb-3 border-b">
            <CardTitle className="text-base flex justify-between items-center text-foreground font-semibold">
              Top 10 đại lý
            </CardTitle>
          </CardHeader>
          <CardContent className="p-0 flex-1 overflow-y-auto">
             {data.topCustomers?.length === 0 ? (
               <div className="text-center p-6 text-muted-foreground text-sm">Chưa có dữ liệu</div>
             ) : (
               <ul className="divide-y divide-border/50">
                 {data.topCustomers?.map((c: any, idx: number) => (
                   <li key={c.phone + idx} className="p-4 py-3 hover:bg-muted/30 transition-all flex gap-3 items-center group">
                     <div className="relative">
                       <div className="h-10 w-10 shrink-0 rounded-full bg-primary/10 flex items-center justify-center text-primary font-bold border border-primary/20 group-hover:bg-primary/20 transition-colors">
                          {c.name.charAt(0).toUpperCase()}
                       </div>
                       {idx === 0 && <div className="absolute -bottom-1 -right-1 bg-yellow-100 rounded-full p-0.5 border border-white shadow-sm"><Trophy className="h-3.5 w-3.5 text-yellow-600" /></div>}
                       {idx === 1 && <div className="absolute -bottom-1 -right-1 bg-gray-100 rounded-full p-0.5 border border-white shadow-sm"><Medal className="h-3.5 w-3.5 text-gray-500" /></div>}
                       {idx === 2 && <div className="absolute -bottom-1 -right-1 bg-orange-100 rounded-full p-0.5 border border-white shadow-sm"><Award className="h-3.5 w-3.5 text-orange-600" /></div>}
                     </div>
                     <div className="flex flex-col flex-1 gap-1">
                       <span className="font-semibold text-sm line-clamp-1">{c.name}</span>
                       <div className="flex justify-between items-center text-xs text-muted-foreground">
                         <span>{c.phone}</span>
                         <span className="text-primary font-medium">{formatMoney(c.totalRevenue)}</span>
                       </div>
                     </div>
                   </li>
                 ))}
               </ul>
             )}
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
