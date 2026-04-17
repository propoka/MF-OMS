'use client';

import { useState, useEffect, useCallback } from 'react';
import { ordersApi, Order, crmApi } from '@/lib/api';
import { useAuth } from '@/lib/auth-context';
import OrderCreateSheet from '@/components/orders/OrderCreateSheet';
import { 
  Table, 
  TableBody, 
  TableCell, 
  TableHead, 
  TableHeader, 
  TableRow 
} from '@/components/ui/table';
import { Card, CardContent } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { OrderStatusBadge } from '@/components/ui/order-status-badge';
import { ORDER_STATUS_CONFIG } from '@/lib/constants';
import { GlassCard } from '@/components/ui/glass-card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Search, Plus, ShoppingCart, Eye, Filter, ChevronLeft, ChevronRight, Trash2, AlertCircle, CalendarIcon, ArrowRight, Loader2 } from 'lucide-react';
import Link from 'next/link';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { toast } from 'sonner';
import { 
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle 
} from '@/components/ui/alert-dialog';

export default function OrdersPage() {
  const { getToken, user } = useAuth();
  const [orders, setOrders] = useState<Order[]>([]);
  const [total, setTotal] = useState(0);
  const [isLoading, setIsLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState<string>('ALL');
  const [isSheetOpen, setIsSheetOpen] = useState(false);
  const [orderToDelete, setOrderToDelete] = useState<string | null>(null);
  const [isDeleting, setIsDeleting] = useState(false);

  const [page, setPage] = useState(1);
  const [limit, setLimit] = useState(50);

  const fetchOrders = useCallback(async () => {
    try {
      setIsLoading(true);
      const token = getToken();
      if (!token) return;

      const skip = (page - 1) * limit;
      const res = await ordersApi.getOrders(token, { 
        search, 
        skip,
        take: limit,
        status: statusFilter === 'ALL' ? undefined : statusFilter 
      });
      setOrders(res.data);
      setTotal(res.total);
    } catch (err) {
      console.error(err);
    } finally {
      setIsLoading(false);
    }
  }, [getToken, search, statusFilter, page, limit]);

  useEffect(() => {
    setPage(1);
  }, [search, statusFilter, limit]);

  useEffect(() => {
    const timer = setTimeout(() => {
      fetchOrders();
    }, 400);
    return () => clearTimeout(timer);
  }, [fetchOrders]);

  useEffect(() => {
    const handleOrderCreated = () => fetchOrders();
    window.addEventListener('order-created', handleOrderCreated);
    return () => window.removeEventListener('order-created', handleOrderCreated);
  }, [fetchOrders]);

  const formatMoney = (amount: number) => {
    return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(amount);
  };

  const handleDeleteOrder = async () => {
    if (!orderToDelete) return;
    try {
      setIsDeleting(true);
      await ordersApi.deleteOrder(getToken()!, orderToDelete);
      toast.success('Đã xoá đơn hàng vĩnh viễn.');
      setOrderToDelete(null);
      fetchOrders();
    } catch (e: any) {
      toast.error(e.message || 'Không thể xoá đơn hàng.');
    } finally {
      setIsDeleting(false);
    }
  };



  return (
    <div className="flex flex-col gap-6 pb-4">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold tracking-tight text-foreground flex items-center gap-2">
            Đơn hàng
          </h1>
        </div>
        <div className="flex items-center gap-3">
          <Button 
            onClick={() => setIsSheetOpen(true)}
            className="group relative overflow-hidden bg-neutral-900/85 hover:bg-black/90 backdrop-blur-xl text-white border border-white/20 hover:border-white/40 shadow-[0_8px_30px_rgb(0,0,0,0.12)] hover:shadow-[0_8px_30px_rgb(0,0,0,0.2)] transition-all duration-500 font-bold px-6 h-11 rounded-full"
          >
            <Plus className="mr-2 h-5 w-5 opacity-80 group-hover:rotate-90 group-hover:scale-110 transition-all duration-500" />
            <span>Tạo Đơn Hàng</span>
            <div className="absolute inset-0 rounded-full ring-1 ring-inset ring-white/10 group-hover:ring-white/30 transition-all duration-500 pointer-events-none"></div>
          </Button>
        </div>
      </div>

      {/* FILTER ACTION DOCK */}
      <GlassCard className="mb-6 border border-white/40 shadow-sm shadow-black/5 rounded-[24px] bg-white/40 backdrop-blur-xl p-2" contentClassName="p-0 flex flex-col xl:flex-row gap-3 items-center justify-between w-full border-none shadow-none bg-transparent">
        <div className="flex flex-col lg:flex-row gap-2 lg:gap-3 items-center w-full xl:w-auto flex-1">
          <div className="relative flex-1 w-full max-w-md">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
            <Input
              placeholder="Tìm mã ORD hoặc tên KH, SĐT..."
              className="pl-9 h-10 border-white/40 bg-white/50 shadow-sm focus-visible:border-primary rounded-xl transition-all w-full"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
            />
          </div>
          
          <div className="w-full xl:w-[200px] shrink-0">
            <Select value={statusFilter} onValueChange={(v) => setStatusFilter(v ?? 'ALL')}>
              <SelectTrigger className="w-full h-10 bg-white/50 border-white/40 rounded-xl text-[13px] tracking-tight font-medium focus:ring-1 focus:ring-black/10 transition-all shadow-sm shadow-black/5 hover:bg-white">
                <SelectValue placeholder="Trạng thái">
                  <div className="flex items-center gap-2">
                    {statusFilter === "ALL" ? (
                      <div className="w-2 h-2 rounded-full border border-muted-foreground/30 flex items-center justify-center">
                        <div className="w-1 h-1 rounded-full bg-muted-foreground/30"></div>
                      </div>
                    ) : (
                      <div
                        className={`w-2 h-2 rounded-full shadow-sm ${ORDER_STATUS_CONFIG[statusFilter]?.dot || "bg-gray-500"}`}
                      ></div>
                    )}
                    <span>
                      {ORDER_STATUS_CONFIG[statusFilter]?.label ||
                        "Tất cả trạng thái"}
                    </span>
                  </div>
                </SelectValue>
              </SelectTrigger>
              <SelectContent className="rounded-[16px] p-2 shadow-2xl border-white/60 backdrop-blur-3xl bg-white/70">
                {Object.keys(ORDER_STATUS_CONFIG).map((key) => (
                  <SelectItem
                    key={key}
                    value={key}
                    className="rounded-xl py-2.5 px-3 mb-1 focus:bg-white/80 focus:text-foreground last:mb-0 transition-all cursor-pointer data-[state=checked]:bg-white data-[state=checked]:shadow-sm data-[state=checked]:shadow-black/5 border border-transparent data-[state=checked]:border-white/60"
                  >
                    <div className="flex items-center gap-2.5">
                      {key === "ALL" ? (
                        <div className="w-2.5 h-2.5 rounded-full border border-muted-foreground/30 flex items-center justify-center">
                          <div className="w-1.5 h-1.5 rounded-full bg-muted-foreground/30"></div>
                        </div>
                      ) : (
                        <div
                          className={`w-2.5 h-2.5 rounded-full shadow-sm ${ORDER_STATUS_CONFIG[key].dot}`}
                        ></div>
                      )}
                      <span className="text-[13px] font-semibold tracking-tight text-foreground/80">
                        {ORDER_STATUS_CONFIG[key].label}
                      </span>
                    </div>
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
        </div>

        <div className="flex items-center gap-2 shrink-0 bg-white/50 border border-white/40 rounded-xl shadow-sm h-10 px-3 self-end xl:self-auto">
          <span className="text-[13px] font-medium text-muted-foreground whitespace-nowrap">Hiển thị</span>
          <Select value={limit.toString()} onValueChange={(v) => setLimit(Number(v))}>
            <SelectTrigger className="w-[70px] !h-8 border-none bg-transparent hover:bg-white/50 transition-colors focus:ring-0 shadow-none px-2 rounded-lg text-[13px] font-bold">
              <SelectValue placeholder="Hiển" />
            </SelectTrigger>
            <SelectContent className="rounded-[16px] p-2 shadow-2xl border-white/60 backdrop-blur-3xl bg-white/70 min-w-[100px]">
              {[10, 20, 50, 100].map(val => (
                <SelectItem 
                  key={val} 
                  value={val.toString()}
                  className="rounded-xl py-2 px-3 mb-1 focus:bg-white/80 focus:text-foreground last:mb-0 transition-all cursor-pointer data-[state=checked]:bg-white data-[state=checked]:shadow-sm data-[state=checked]:shadow-black/5 border border-transparent data-[state=checked]:border-white/60 font-medium"
                >
                  <span className="text-[13px] font-semibold tracking-tight text-foreground/80">{val}</span>
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
      </GlassCard>

      {/* DATATABLE */}
      <GlassCard
        className="mb-4"
      >
        <div className="w-full overflow-auto custom-scrollbar">
          <Table>
            <TableHeader>
              <TableRow className="border-b border-border/40 hover:bg-transparent">
                <TableHead className="w-[140px] pl-6 lg:pl-8 uppercase tracking-wider text-[11px] font-semibold text-muted-foreground pb-4">Thời gian</TableHead>
                <TableHead className="uppercase tracking-wider text-[11px] font-semibold text-muted-foreground pb-4">Mã Đơn</TableHead>
                <TableHead className="uppercase tracking-wider text-[11px] font-semibold text-muted-foreground pb-4">Khách hàng</TableHead>
                <TableHead className="min-w-[220px] uppercase tracking-wider text-[11px] font-semibold text-muted-foreground pb-4">Sản Phẩm</TableHead>
                <TableHead className="text-center uppercase tracking-wider text-[11px] font-semibold text-muted-foreground pb-4">Trạng thái</TableHead>
                <TableHead className="text-right uppercase tracking-wider text-[11px] font-semibold text-muted-foreground pb-4">Tổng tiền</TableHead>
                <TableHead className="text-right pr-6 lg:pr-8 uppercase tracking-wider text-[11px] font-semibold text-muted-foreground pb-4">Thao tác</TableHead>
              </TableRow>
            </TableHeader>
          <TableBody>
            {isLoading ? (
              Array.from({ length: 5 }).map((_, i) => (
                <TableRow key={i} className="animate-pulse">
                  <TableCell className="pl-6 lg:pl-8 py-4"><div className="h-4 bg-muted rounded w-24 mb-2"></div><div className="h-3 bg-muted rounded w-16"></div></TableCell>
                  <TableCell className="py-4"><div className="h-4 bg-muted rounded w-32"></div></TableCell>
                  <TableCell className="py-4"><div className="h-4 bg-muted rounded w-32 mb-2"></div><div className="h-3 bg-muted rounded w-20"></div></TableCell>
                  <TableCell className="py-4"><div className="h-4 bg-muted rounded w-48 mb-2"></div><div className="h-4 bg-muted rounded w-36"></div></TableCell>
                  <TableCell className="text-center py-4"><div className="h-5 bg-muted rounded w-24 mx-auto"></div></TableCell>
                  <TableCell className="text-right py-4"><div className="h-4 bg-muted rounded w-20 ml-auto"></div></TableCell>
                  <TableCell className="pr-6 lg:pr-8 text-right py-4"><div className="h-8 bg-muted rounded w-24 ml-auto"></div></TableCell>
                </TableRow>
              ))
            ) : orders.length === 0 ? (
              <TableRow>
                <TableCell colSpan={7} className="h-48 text-center">
                  <div className="flex flex-col items-center justify-center text-muted-foreground">
                    <ShoppingCart className="h-10 w-10 mb-4 opacity-50" />
                    <p>Không tìm thấy đơn hàng nào phù hợp.</p>
                    <p>Bấm "Tạo Đơn Hàng" để bắt đầu.</p>
                  </div>
                </TableCell>
              </TableRow>
            ) : (
              orders.map((o) => (
                <TableRow key={o.id} className="group hover:bg-muted/40 transition-colors border-border/30">
                  <TableCell className="pl-6 lg:pl-8 py-4 align-top">
                    <div className="flex flex-col gap-1">
                      <span className="font-medium text-[13px] text-foreground tracking-tight whitespace-nowrap">
                        {new Date(o.createdAt).toLocaleDateString("vi-VN", { day: "2-digit", month: "short", year: "numeric", })}
                      </span>
                      <div className="flex items-center text-muted-foreground mt-1 gap-1.5 opacity-80">
                        <CalendarIcon className="w-[10px] h-[10px]" />
                        <span className="text-[10px] uppercase font-bold tracking-wider">
                          {new Date(o.createdAt).toLocaleTimeString("vi-VN", { hour: "2-digit", minute: "2-digit" })}
                        </span>
                      </div>
                    </div>
                  </TableCell>
                  <TableCell className="align-top py-4">
                    <Link href={`/orders/${o.id}`} className="group/link flex items-center gap-1 font-medium text-[13px] text-foreground hover:text-primary transition-colors whitespace-nowrap w-fit">
                      <span>{o.orderNumber?.replace("ORD-", "") || o.orderNumber}</span>
                      <ArrowRight className="w-3.5 h-3.5 opacity-0 -translate-x-2 group-hover/link:opacity-100 group-hover/link:translate-x-0 transition-all duration-300" />
                    </Link>
                  </TableCell>
                  <TableCell className="align-top py-4 max-w-[200px]">
                    <div className="flex flex-col gap-1">
                      <span className="font-medium text-[13px] text-foreground truncate pr-2">
                        {o.snapshotCustomerName}
                      </span>
                      <span className="text-[11px] text-muted-foreground font-medium">
                        {o.snapshotCustomerPhone || "Khách lẻ"}
                      </span>
                    </div>
                  </TableCell>
                  <TableCell className="align-top py-4">
                    <div className="flex flex-col min-w-[220px] max-w-[250px] pr-4">
                      {o.items?.slice(0, 1).map((i) => (
                        <div
                          key={i.id}
                          className="flex justify-between items-center text-xs"
                        >
                          <span className="pr-3 font-medium text-foreground truncate">
                            {i.snapshotProductName}
                          </span>
                          <span className="bg-muted text-muted-foreground px-1.5 py-0.5 rounded text-[10px] font-medium shrink-0">
                            x{i.quantity}
                          </span>
                        </div>
                      ))}
                      {(o.items?.length || 0) > 1 && (
                        <span className="text-muted-foreground text-[10px] italic font-medium hover:text-primary transition-colors cursor-default mt-1">
                          (+ {o.items!.length - 1} mặt hàng khác)
                        </span>
                      )}
                    </div>
                  </TableCell>
                  <TableCell className="text-center align-top py-4">
                    <OrderStatusBadge status={o.deliveryStatus} className="mx-auto" />
                  </TableCell>
                  <TableCell className="text-right align-top py-4">
                    <span className="font-bold text-[14px] text-[oklch(0.40_0.06_45)] tracking-tight whitespace-nowrap">
                      {formatMoney(o.totalAmount || 0)}
                    </span>
                  </TableCell>
                  <TableCell className="text-right align-top py-4 pr-6 lg:pr-8">
                    <div className="flex justify-end gap-1.5 opacity-80 group-hover:opacity-100 transition-opacity">
                       <Link href={`/orders/${o.id}`}>
                         <Button variant="ghost" size="icon" className="h-8 w-8 rounded-lg hover:bg-white shadow-sm border border-border/40 text-muted-foreground hover:text-primary transition-all" title="Chi tiết">
                           <Eye className="h-4 w-4" />
                         </Button>
                       </Link>
                       {user?.role === 'ADMIN' && (
                         <Button variant="ghost" size="icon" onClick={() => setOrderToDelete(o.id)} className="h-8 w-8 rounded-lg hover:bg-destructive/10 shadow-sm border border-border/40 text-muted-foreground hover:text-destructive transition-all" title="Xoá đơn hàng">
                           <Trash2 className="h-4 w-4" />
                         </Button>
                       )}
                    </div>
                  </TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
        </div>
      </GlassCard>

      {total > limit && (
        <div className="flex items-center justify-between pt-2">
          <div className="text-sm text-muted-foreground">
            Hiển thị {((page - 1) * limit) + 1} - {Math.min(page * limit, total)} trên tổng {total} hoá đơn
          </div>
          <div className="flex items-center gap-4">
            <Button
              variant="outline"
              size="sm"
              onClick={() => setPage(p => Math.max(1, p - 1))}
              disabled={page === 1 || isLoading}
            >
              <ChevronLeft className="h-4 w-4 mr-1" /> Trước
            </Button>
            <div className="text-sm font-medium">Trang {page} / {Math.ceil(total / limit) || 1}</div>
            <Button
              variant="outline"
              size="sm"
              onClick={() => setPage(p => p + 1)}
              disabled={page >= Math.ceil(total / limit) || isLoading}
            >
              Sau <ChevronRight className="h-4 w-4 ml-1" />
            </Button>
          </div>
        </div>
      )}

      <OrderCreateSheet 
        isOpen={isSheetOpen} 
        onClose={() => setIsSheetOpen(false)}
        onSuccess={() => {
          setIsSheetOpen(false);
          fetchOrders();
        }}
      />

      {/* MODAL DELETE */}
      <AlertDialog open={!!orderToDelete} onOpenChange={(open) => !open && setOrderToDelete(null)}>
        {(() => {
          const target = orders.find(o => o.id === orderToDelete);
          return (
            <AlertDialogContent className="glass sm:max-w-[400px] border-border/40 shadow-2xl p-6">
              <AlertDialogHeader className="flex flex-col items-center text-center space-y-4">
                <div className="w-14 h-14 rounded-full bg-red-700/10 flex items-center justify-center shrink-0">
                  <Trash2 className="w-7 h-7 text-red-700" />
                </div>
                <div className="space-y-2">
                  <AlertDialogTitle className="text-xl font-bold text-foreground">
                    Xoá vĩnh viễn đơn hàng?
                  </AlertDialogTitle>
                  <AlertDialogDescription className="text-foreground/80 leading-relaxed text-sm">
                    Bạn đang thao tác xoá đơn hàng <strong className="text-red-700 font-bold">{target?.orderNumber?.replace("ORD-", "") || target?.orderNumber}</strong> của khách hàng <span className="font-bold text-foreground">{target?.snapshotCustomerName}</span>.
                    <br/><br/>
                    Toàn bộ dữ liệu của đơn này sẽ xoá khỏi hệ thống và <strong className="text-foreground font-semibold">không thể khôi phục</strong>.
                  </AlertDialogDescription>
                </div>
              </AlertDialogHeader>
              <AlertDialogFooter className="sm:justify-center flex-row gap-3 pt-6 w-full">
                <AlertDialogCancel className="flex-1 text-foreground font-semibold hover:bg-muted/50 border border-border/60 bg-white/50 m-0 shadow-sm transition-all" disabled={isDeleting}>
                  Hủy bỏ
                </AlertDialogCancel>
                <AlertDialogAction onClick={() => { handleDeleteOrder(); }} className="flex-1 bg-red-700 text-white hover:bg-red-800 shadow-[0_0_15px_rgba(185,28,28,0.25)] hover:shadow-[0_0_20px_rgba(185,28,28,0.4)] transition-all duration-300 m-0" disabled={isDeleting}>
                  {isDeleting ? (
                    <span className="flex items-center gap-2">
                      <Loader2 className="w-4 h-4 animate-spin" />
                      Khai tử...
                    </span>
                  ) : 'Xác nhận Xóa'}
                </AlertDialogAction>
              </AlertDialogFooter>
            </AlertDialogContent>
          );
        })()}
      </AlertDialog>
    </div>
  );
}
