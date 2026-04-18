'use client';

import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { dashboardApi } from '@/lib/api';
import { useAuth } from '@/lib/auth-context';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { TrendingUp, Users, ShoppingCart, DollarSign, Activity, Package, Trophy, Medal, Award, ArrowUpRight } from 'lucide-react';
import { GenerativeAvatar } from '@/components/ui/generative-avatar';
import { HeaderWidget } from '@/components/layout/header-widget';
import {
  AreaChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer
} from 'recharts';

const CustomTooltip = ({ active, payload, label }: any) => {
  if (active && payload && payload.length) {
    const isRevenue = payload[0].dataKey === 'revenue';
    const valueStr = isRevenue 
      ? new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(payload[0].value) 
      : `${new Intl.NumberFormat('vi-VN').format(payload[0].value)} đơn`;
    const dotColor = 'oklch(0.40 0.06 45)';

    return (
      <div className="flex items-center gap-2 bg-background/95 backdrop-blur-md border border-border/50 py-1.5 px-3.5 rounded-full shadow-md">
        <span className="w-1.5 h-1.5 rounded-full" style={{ backgroundColor: dotColor }}></span>
        <span className="text-[11px] text-muted-foreground font-medium whitespace-nowrap">{label}</span>
        <span className="text-[10px] text-muted-foreground/40 font-light mx-0.5">—</span>
        <span className="text-[13px] font-semibold text-foreground tabular-nums tracking-tight whitespace-nowrap">{valueStr}</span>
      </div>
    );
  }
  return null;
};

const CustomActiveDot = (props: any) => {
  const { cx, cy, brandColor } = props;
  return (
    <svg x={cx - 12} y={cy - 12} width={24} height={24} viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" style={{ pointerEvents: 'none' }}>
      {/* Vành Pulse nhịp tim */}
      <circle cx="12" cy="12" r="10" fill={brandColor} className="animate-pulse" opacity="0.25" />
      {/* Lõi gốc theo màu Brand */}
      <circle cx="12" cy="12" r="5.5" fill={brandColor} />
      {/* Lõi tâm trắng siêu nhỏ bắt sáng */}
      <circle cx="12" cy="12" r="2" fill="#ffffff" />
    </svg>
  );
};

export default function DashboardPage() {
  const { getToken } = useAuth();
  const [data, setData] = useState<any>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [chartDays, setChartDays] = useState<number>(7);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const token = getToken();
        if (!token) return;
        const res = await dashboardApi.getKpis(token, chartDays);
        setData(res);
      } catch {
        // KPI load failed silently
      } finally {
        setIsLoading(false);
      }
    };
    fetchData();
  }, [getToken, chartDays]);

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
          </h1>
        </div>
        <HeaderWidget growthRate={data.revenue.growthRate} />
      </div>

      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <Card className="transition-all duration-300 hover:shadow-md hover:-translate-y-1 border-none shadow-sm rounded-2xl">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">Doanh thu hôm nay</CardTitle>
            <div className="p-2.5 bg-muted/30 rounded-xl">
              <DollarSign className="h-5 w-5 text-foreground/70" />
            </div>
          </CardHeader>
          <CardContent className="pb-4">
            <div className="text-3xl font-bold text-foreground tabular-nums tracking-tight">{formatMoney(data.revenue.today || 0)}</div>
            <p className="text-xs text-muted-foreground mt-2 flex items-center gap-1">
              <ArrowUpRight className="h-3.5 w-3.5 text-foreground/60" /> Đã thu từ các đơn hoàn thành
            </p>
          </CardContent>
        </Card>
        
        <Card className="transition-all duration-300 hover:shadow-md hover:-translate-y-1 border-none shadow-sm rounded-2xl">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">Đơn hàng hôm nay</CardTitle>
            <div className="p-2.5 bg-muted/30 rounded-xl">
              <ShoppingCart className="h-5 w-5 text-foreground/70" />
            </div>
          </CardHeader>
          <CardContent className="pb-4">
            <div className="text-3xl font-bold text-foreground tabular-nums tracking-tight">{data.orders.today || 0} đơn</div>
            <p className="text-xs text-muted-foreground mt-2 flex items-center gap-1">
              <ArrowUpRight className="h-3.5 w-3.5 text-foreground/60" /> Đơn hàng được tạo trong ngày
            </p>
          </CardContent>
        </Card>

        <Card className="transition-all duration-300 hover:shadow-md hover:-translate-y-1 border-none shadow-sm rounded-2xl">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">Doanh thu tháng này</CardTitle>
            <div className="p-2.5 bg-primary/10 rounded-xl">
              <TrendingUp className="h-5 w-5 text-primary" />
            </div>
          </CardHeader>
          <CardContent className="pb-4">
            <div className="text-3xl font-bold text-foreground tabular-nums tracking-tight">{formatMoney(data.revenue.thisMonth)}</div>
            <p className="text-xs text-muted-foreground mt-2 flex items-center gap-1">
               Tổng tích luỹ: {formatMoney(data.revenue.total)}
            </p>
          </CardContent>
        </Card>

        <Card className="transition-all duration-300 hover:shadow-md hover:-translate-y-1 border-none shadow-sm rounded-2xl">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">Khách hàng</CardTitle>
            <div className="p-2.5 bg-muted/30 rounded-xl">
              <Users className="h-5 w-5 text-foreground/70" />
            </div>
          </CardHeader>
          <CardContent className="pb-4">
            <div className="text-3xl font-bold text-foreground tabular-nums tracking-tight">+{data.customers.newThisMonth} <span className="text-base font-normal text-muted-foreground">mới</span></div>
            <p className="text-xs text-muted-foreground mt-2 flex items-center gap-1">
              Tổng số hồ sơ: <span className="tabular-nums font-medium text-foreground">{data.customers.total}</span>
            </p>
          </CardContent>
        </Card>
      </div>

      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <div className="col-span-2 lg:col-span-3 flex flex-col gap-4">
          {/* Biểu đồ Doanh thu */}
          <Card className="flex-1 border border-border/40 shadow-sm rounded-2xl overflow-hidden bg-white/40 backdrop-blur-lg">
            <CardHeader className="flex flex-row items-center justify-between pb-6 pt-6 px-6 border-b border-border/30">
              <div className="space-y-1">
                <CardTitle className="text-base font-semibold text-foreground">Doanh thu {chartDays} ngày gần nhất</CardTitle>
                <p className="text-xs text-muted-foreground mt-1">Bộ đếm hiệu suất giao dịch hoàn thành</p>
              </div>
              <div className="hidden sm:flex bg-muted/60 p-1 rounded-lg relative">
                {[7, 30].map((d) => (
                  <button 
                    key={d}
                    onClick={() => setChartDays(d)}
                    className={`relative text-[11px] font-semibold px-4 py-1.5 rounded-md transition-colors z-10 ${chartDays === d ? 'text-foreground' : 'text-muted-foreground hover:text-foreground/80'}`}
                  >
                    {chartDays === d && (
                      <motion.div 
                        layoutId="activeChartTabRevenue" 
                        className="absolute inset-0 bg-background shadow-sm rounded-md -z-10"
                        transition={{ type: "spring", stiffness: 400, damping: 30 }}
                      />
                    )}
                    {d} Ngày
                  </button>
                ))}
              </div>
            </CardHeader>
            <CardContent className="px-2 pt-6 pb-6">
              <ResponsiveContainer width="100%" height={280}>
                <AreaChart data={data.revenueChart} margin={{ top: 10, right: 30, left: 10, bottom: 0 }}>
                  <defs>
                    <linearGradient id="colorRevenue" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="oklch(0.40 0.06 45)" stopOpacity={0.25} />
                      <stop offset="95%" stopColor="oklch(0.40 0.06 45)" stopOpacity={0} />
                    </linearGradient>
                  </defs>
                  <CartesianGrid strokeDasharray="3 4" vertical={false} stroke="hsl(var(--border))" opacity={0.6} />
                  <XAxis
                    dataKey="date"
                    stroke="hsl(var(--muted-foreground))"
                    fontSize={11}
                    tickLine={false}
                    axisLine={false}
                    tickMargin={12}
                    opacity={0.7}
                  />
                  <YAxis hide={true} />
                  <Tooltip
                    content={<CustomTooltip />}
                    cursor={{ stroke: 'hsl(var(--muted-foreground))', strokeWidth: 1, strokeDasharray: '4 4', opacity: 0.3 }}
                  />
                  <Area
                    type="monotone"
                    dataKey="revenue"
                    stroke="oklch(0.40 0.06 45)"
                    strokeWidth={2.5}
                    fillOpacity={1}
                    fill="url(#colorRevenue)"
                    activeDot={<CustomActiveDot brandColor="oklch(0.40 0.06 45)" />}
                    isAnimationActive={true}
                    animationDuration={1500}
                    animationEasing="ease-in-out"
                  />
                </AreaChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>

          {/* Biểu đồ Số lượng đơn hàng */}
          <Card className="flex-1 border border-border/40 shadow-sm rounded-2xl overflow-hidden bg-white/40 backdrop-blur-lg">
            <CardHeader className="flex flex-row items-center justify-between pb-6 pt-6 px-6 border-b border-border/30">
              <div className="space-y-1">
                <CardTitle className="text-base font-semibold text-foreground">Lưu lượng đơn hàng {chartDays} ngày</CardTitle>
                <p className="text-xs text-muted-foreground mt-1">Biến động số lượng phát sinh</p>
              </div>
              <div className="hidden sm:flex bg-muted/60 p-1 rounded-lg relative">
                {[7, 30].map((d) => (
                  <button 
                    key={d}
                    onClick={() => setChartDays(d)}
                    className={`relative text-[11px] font-semibold px-4 py-1.5 rounded-md transition-colors z-10 ${chartDays === d ? 'text-foreground' : 'text-muted-foreground hover:text-foreground/80'}`}
                  >
                    {chartDays === d && (
                      <motion.div 
                        layoutId="activeChartTabOrders" 
                        className="absolute inset-0 bg-background shadow-sm rounded-md -z-10"
                        transition={{ type: "spring", stiffness: 400, damping: 30 }}
                      />
                    )}
                    {d} Ngày
                  </button>
                ))}
              </div>
            </CardHeader>
            <CardContent className="px-2 pt-6 pb-6">
              <ResponsiveContainer width="100%" height={280}>
                <AreaChart data={data.revenueChart} margin={{ top: 10, right: 30, left: 10, bottom: 0 }}>
                  <defs>
                    <linearGradient id="colorOrders" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="oklch(0.40 0.06 45)" stopOpacity={0.25} />
                      <stop offset="95%" stopColor="oklch(0.40 0.06 45)" stopOpacity={0} />
                    </linearGradient>
                  </defs>
                  <CartesianGrid strokeDasharray="3 4" vertical={false} stroke="hsl(var(--border))" opacity={0.6} />
                  <XAxis
                    dataKey="date"
                    stroke="hsl(var(--muted-foreground))"
                    fontSize={11}
                    tickLine={false}
                    axisLine={false}
                    tickMargin={12}
                    opacity={0.7}
                  />
                  <YAxis hide={true} />
                  <Tooltip
                    content={<CustomTooltip />}
                    cursor={{ stroke: 'hsl(var(--muted-foreground))', strokeWidth: 1, strokeDasharray: '4 4', opacity: 0.3 }}
                  />
                  <Area
                    type="monotone"
                    dataKey="orders"
                    stroke="oklch(0.40 0.06 45)"
                    strokeWidth={2.5}
                    fillOpacity={1}
                    fill="url(#colorOrders)"
                    activeDot={<CustomActiveDot brandColor="oklch(0.40 0.06 45)" />}
                    isAnimationActive={true}
                    animationDuration={1500}
                    animationEasing="ease-in-out"
                  />
                </AreaChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>
        </div>

        {/* Cột phải: Top 10 Sản phẩm */}
        <div className="col-span-1 lg:col-span-1 flex flex-col gap-6">
          <Card className="flex-1 overflow-hidden flex flex-col items-stretch transition-all duration-300 hover:shadow-md border border-border/40 shadow-sm rounded-2xl bg-white/40 backdrop-blur-lg">
            <CardHeader className="pb-4 pt-6 px-6">
              <div className="space-y-1">
                <CardTitle className="text-base font-semibold text-foreground">
                  Top 5 sản phẩm bán chạy
                </CardTitle>
                <p className="text-xs text-muted-foreground mt-1">Dẫn đầu doanh thu hệ thống</p>
              </div>
            </CardHeader>
            <CardContent className="px-4 pb-6 flex-1 overflow-y-auto custom-scrollbar">
             {data.topProducts?.length === 0 ? (
               <div className="text-center p-6 text-muted-foreground text-sm">Chưa có dữ liệu</div>
             ) : (
               <ul className="flex flex-col gap-1">
                 {data.topProducts?.slice(0, 5).map((p: any, idx: number) => {
                   const maxVal = Math.max(...data.topProducts.slice(0, 5).map((x:any)=>x.totalRevenue), 1);
                   const pct = (p.totalRevenue / maxVal) * 100;
                   return (
                   <li key={p.sku + idx} className="p-3 rounded-xl flex gap-4 items-center">
                     <div className="relative shrink-0">
                       <GenerativeAvatar name={p.name} size={42} />
                       <div className="absolute -left-2 -top-2 w-5 h-5 bg-background font-medium text-[10px] rounded-full flex items-center justify-center border border-border/80 shadow-sm text-muted-foreground">
                         #{idx + 1}
                       </div>
                     </div>
                     <div className="flex flex-col flex-1 min-w-0">
                       <div className="flex justify-between items-center mb-1">
                         <span className="font-medium text-sm text-foreground truncate pr-2">{p.name}</span>
                         <span className="font-semibold text-[oklch(0.40_0.06_45)] tabular-nums tracking-tight whitespace-nowrap">{formatMoney(p.totalRevenue)}</span>
                       </div>
                       <div className="flex items-center gap-2">
                         <span className="px-1.5 py-0.5 bg-muted/60 text-muted-foreground rounded text-[10px] font-medium">{p.totalSold} đã bán</span>
                         <div className="flex-1 h-1.5 bg-muted/60 rounded-full overflow-hidden">
                           <div className="h-full bg-[oklch(0.40_0.06_45)]/80 rounded-full" style={{ width: `${pct}%` }} />
                         </div>
                       </div>
                     </div>
                   </li>
                 )})}
               </ul>
             )}
          </CardContent>
        </Card>

        {/* Cột phải: Top 5 Khách hàng */}
        <Card className="flex-1 overflow-hidden flex flex-col items-stretch transition-all duration-300 hover:shadow-md border border-border/40 shadow-sm rounded-2xl bg-white/40 backdrop-blur-lg">
          <CardHeader className="pb-4 pt-6 px-6">
            <div className="space-y-1">
              <CardTitle className="text-base font-semibold text-foreground">
                Top 5 đại lý
              </CardTitle>
              <p className="text-xs text-muted-foreground mt-1">Đối tác doanh thu cao nhất</p>
            </div>
          </CardHeader>
          <CardContent className="px-4 pb-6 flex-1 overflow-y-auto custom-scrollbar">
             {data.topCustomers?.length === 0 ? (
               <div className="text-center p-6 text-muted-foreground text-sm">Chưa có dữ liệu</div>
             ) : (
               <ul className="flex flex-col gap-1">
                 {data.topCustomers?.slice(0, 5).map((c: any, idx: number) => {
                   const maxVal = Math.max(...data.topCustomers.slice(0, 5).map((x:any)=>x.totalRevenue), 1);
                   const pct = (c.totalRevenue / maxVal) * 100;
                   return (
                   <li key={c.phone + idx} className="p-3 rounded-xl flex gap-4 items-center">
                     <div className="relative shrink-0">
                       <GenerativeAvatar name={c.name || 'User'} size={42} />
                       <div className="absolute -left-2 -top-2 w-5 h-5 bg-background font-medium text-[10px] rounded-full flex items-center justify-center border border-border/80 shadow-sm text-muted-foreground">
                         #{idx + 1}
                       </div>
                     </div>
                     <div className="flex flex-col flex-1 min-w-0">
                       <div className="flex justify-between items-center mb-1">
                         <span className="font-medium text-sm text-foreground truncate pr-2">{c.name}</span>
                         <span className="font-semibold text-[oklch(0.40_0.06_45)] tabular-nums tracking-tight whitespace-nowrap">{formatMoney(c.totalRevenue)}</span>
                       </div>
                       <div className="flex items-center gap-2">
                         <span className="px-1.5 py-0.5 bg-muted/60 text-muted-foreground rounded text-[10px] font-medium">{c.totalOrders ? `${c.totalOrders} đơn` : (c.phone || '')}</span>
                         <div className="flex-1 h-1.5 bg-muted/60 rounded-full overflow-hidden">
                           <div className="h-full bg-[oklch(0.40_0.06_45)]/80 rounded-full" style={{ width: `${pct}%` }} />
                         </div>
                       </div>
                     </div>
                   </li>
                 )})}
               </ul>
             )}
          </CardContent>
        </Card>
        </div>
      </div>
    </div>
  );
}
