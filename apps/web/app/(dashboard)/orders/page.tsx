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
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Search, Plus, ShoppingCart, Eye, Filter, Download, ChevronLeft, ChevronRight } from 'lucide-react';
import Link from 'next/link';
import * as xlsx from 'xlsx';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { toast } from 'sonner';

export default function OrdersPage() {
  const { getToken } = useAuth();
  const [orders, setOrders] = useState<Order[]>([]);
  const [total, setTotal] = useState(0);
  const [isLoading, setIsLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState<string>('ALL');
  const [isSheetOpen, setIsSheetOpen] = useState(false);

  const [page, setPage] = useState(1);
  const limit = 10;

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
  }, [getToken, search, statusFilter, page]);

  useEffect(() => {
    setPage(1);
  }, [search, statusFilter]);

  useEffect(() => {
    const timer = setTimeout(() => {
      fetchOrders();
    }, 400);
    return () => clearTimeout(timer);
  }, [fetchOrders]);

  const formatMoney = (amount: number) => {
    return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(amount);
  };

  const handleExportExcel = async () => {
    try {
      setIsLoading(true);
      const res = await ordersApi.getOrders(getToken()!, { 
        take: 10000, // Lấy thoải mái để export
        search, 
        status: statusFilter === 'ALL' ? undefined : statusFilter 
      });
      
      const exportData = res.data.map(o => ({
        'Mã Đơn': o.orderNumber,
        'Ngày tạo': new Date(o.createdAt).toLocaleString('vi-VN'),
        'Khách hàng': o.snapshotCustomerName,
        'Điện thoại': o.snapshotCustomerPhone,
        'Trạng thái': o.deliveryStatus,
        'Tổng tiền': o.totalAmount,
        'Thu ngân': o.createdBy?.fullName || '',
        'Ghi chú': o.notes || ''
      }));

      const ws = xlsx.utils.json_to_sheet(exportData);
      const wb = xlsx.utils.book_new();
      xlsx.utils.book_append_sheet(wb, ws, 'Danh sách Đơn hàng');
      xlsx.writeFile(wb, `DonHang_OMS_${new Date().toISOString().slice(0,10)}.xlsx`);
      toast.success('Xuất file Excel thành công!');
    } catch (err) {
      toast.error('Lỗi phân tích khi xuất file Excel');
    } finally {
      setIsLoading(false);
    }
  };

  const getStatusBadge = (status: string) => {
    switch (status) {
      case 'PENDING': return <Badge variant="outline" className="bg-yellow-50 text-yellow-700 border-yellow-200">Đang xử lý</Badge>;
      case 'PROCESSING': return <Badge variant="outline" className="bg-orange-50 text-orange-700 border-orange-200">Đang giao</Badge>;
      case 'SHIPPING': return <Badge variant="outline" className="bg-blue-50 text-blue-700 border-blue-200">Đã giao</Badge>;
      case 'COMPLETED': return <Badge variant="outline" className="bg-emerald-50 text-emerald-700 border-emerald-200">Hoàn thành</Badge>;
      case 'CANCELLED': return <Badge variant="destructive">Huỷ</Badge>;
      case 'RETURNED': return <Badge variant="outline" className="bg-red-50 text-red-700 border-red-200">Hoàn trả</Badge>;
      default: return <Badge variant="outline">{status}</Badge>;
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
            variant="outline" 
            onClick={handleExportExcel} 
            disabled={isLoading}
            className="bg-background shadow-sm hover:bg-muted font-medium transition-all duration-200 border-muted-foreground/30"
          >
            <Download className="mr-2 h-4 w-4" />
            Xuất Excel
          </Button>
          <Button 
            onClick={() => setIsSheetOpen(true)}
            className="shadow-md hover:shadow-lg transition-all duration-200 font-semibold px-5"
          >
            <Plus className="mr-2 h-5 w-5" />
            Tạo Đơn Mới
          </Button>
        </div>
      </div>

      <Card className="glass shadow-sm border-muted/50 overflow-hidden">
        <CardContent className="p-0">
          <div className="p-6 border-b border-muted/30 flex items-center bg-muted/10 gap-4">
            <div className="relative flex-1 max-w-md shadow-sm">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
              <Input
                placeholder="Tìm mã ORD hoặc tên KH, SĐT..."
                className="pl-9 border-muted-foreground/30 bg-background h-10 transition-colors focus-visible:border-primary"
                value={search}
                onChange={(e) => setSearch(e.target.value)}
              />
            </div>
            
            <div className="w-[200px] shadow-sm">
              <Select value={statusFilter} onValueChange={(v) => setStatusFilter(v ?? 'ALL')} >
                <SelectTrigger className="w-full h-10 border-muted-foreground/30 bg-background hover:bg-muted/30 transition-colors focus:ring-1 focus:ring-primary focus-visible:outline-none focus:border-primary">
                  <div className="flex items-center gap-2 font-medium text-foreground truncate">
                    <Filter size={15} className="text-muted-foreground shrink-0" /> 
                    <SelectValue placeholder="Lọc trạng thái">
                      {statusFilter === 'ALL' ? 'Tất cả trạng thái' : 
                       statusFilter === 'PENDING' ? 'Đang xử lý' :
                       statusFilter === 'PROCESSING' ? 'Đang giao' :
                       statusFilter === 'SHIPPING' ? 'Đã giao' :
                       statusFilter === 'COMPLETED' ? 'Hoàn thành' :
                       statusFilter === 'RETURNED' ? 'Hoàn trả' :
                       statusFilter === 'CANCELLED' ? 'Huỷ' : 'Lọc trạng thái'}
                    </SelectValue>
                  </div>
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="ALL">Tất cả trạng thái</SelectItem>
                  <SelectItem value="PENDING">Đang xử lý</SelectItem>
                  <SelectItem value="PROCESSING">Đang giao</SelectItem>
                  <SelectItem value="SHIPPING">Đã giao</SelectItem>
                  <SelectItem value="COMPLETED">Hoàn thành</SelectItem>
                  <SelectItem value="RETURNED">Hoàn trả</SelectItem>
                  <SelectItem value="CANCELLED">Huỷ</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>

          <div className="w-full overflow-auto">
            <Table>
              <TableHeader className="bg-muted/50">
            <TableRow>
              <TableHead className="w-[180px] px-6 text-foreground font-semibold">Mã Đơn / Ngày tạo</TableHead>
              <TableHead className="px-6 text-foreground font-semibold">Khách hàng</TableHead>
              <TableHead className="px-6 text-foreground font-semibold">Trạng thái</TableHead>
              <TableHead className="px-6 text-foreground font-semibold">Tổng tiền</TableHead>
              <TableHead className="text-right px-6 text-foreground font-semibold">Thao tác</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {isLoading ? (
              Array.from({ length: 5 }).map((_, i) => (
                <TableRow key={i} className="animate-pulse">
                  <TableCell className="px-6"><div className="h-4 bg-muted rounded w-24 mb-2"></div><div className="h-3 bg-muted rounded w-32"></div></TableCell>
                  <TableCell className="px-6"><div className="h-4 bg-muted rounded w-32 mb-2"></div><div className="h-3 bg-muted rounded w-20"></div></TableCell>
                  <TableCell className="px-6"><div className="h-5 bg-muted rounded w-24"></div></TableCell>
                  <TableCell className="px-6"><div className="h-4 bg-muted rounded w-20"></div></TableCell>
                  <TableCell className="px-6"><div className="h-8 bg-muted rounded w-24 ml-auto"></div></TableCell>
                </TableRow>
              ))
            ) : orders.length === 0 ? (
              <TableRow>
                <TableCell colSpan={5} className="h-48 text-center">
                  <div className="flex flex-col items-center justify-center text-muted-foreground">
                    <ShoppingCart className="h-10 w-10 mb-4 opacity-50" />
                    <p>Không tìm thấy đơn hàng nào phù hợp.</p>
                    <p>Bấm "Tạo Đơn Mới" để bắt đầu.</p>
                  </div>
                </TableCell>
              </TableRow>
            ) : (
              orders.map((o) => (
                <TableRow key={o.id}>
                  <TableCell className="px-6 py-4">
                    <Link href={`/orders/${o.id}`} className="font-bold text-primary hover:underline transition-all">
                      {o.orderNumber}
                    </Link>
                    <div className="text-xs text-muted-foreground mt-1">
                      {new Date(o.createdAt).toLocaleString('vi-VN', { hour: '2-digit', minute:'2-digit', day: '2-digit', month: '2-digit', year: 'numeric' })}
                    </div>
                  </TableCell>
                  <TableCell className="px-6">
                    <div className="font-medium text-foreground">{o.snapshotCustomerName}</div>
                    <div className="text-xs text-muted-foreground mt-1">{o.snapshotCustomerPhone}</div>
                  </TableCell>
                  <TableCell className="px-6">
                    {getStatusBadge(o.deliveryStatus)}
                  </TableCell>
                  <TableCell className="px-6 font-medium text-primary">
                    {formatMoney(o.totalAmount)}
                  </TableCell>
                  <TableCell className="px-6 text-right">
                    <Link href={`/orders/${o.id}`}>
                      <Button variant="outline" size="sm" className="hover:text-primary transition-colors">
                        <Eye className="mr-2 h-4 w-4" /> Chi tiết
                      </Button>
                    </Link>
                  </TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
        </div>
        </CardContent>
      </Card>

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
    </div>
  );
}
