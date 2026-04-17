'use client';

import { useState, useEffect, useCallback, use } from 'react';
import { crmApi, Customer } from '@/lib/api';
import { useAuth } from '@/lib/auth-context';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { OrderStatusBadge } from '@/components/ui/order-status-badge';
import { ArrowLeft, ShoppingCart, Edit, Inbox, Trash2, AlertTriangle, Loader2, AlertCircle, Phone, MapPin, DollarSign, User, CreditCard } from 'lucide-react';
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
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import CustomerFormModal from '@/components/customers/CustomerFormModal';
import { toast } from 'sonner';

export default function CustomerDetailPage({ params }: { params: Promise<{ id: string }> }) {
  const resolvedParams = use(params);
  const { getToken, user } = useAuth();
  const router = useRouter();

  const [customer, setCustomer] = useState<Customer | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  // States for Edit / Delete
  const [isEditOpen, setIsEditOpen] = useState(false);
  const [isDeleteOpen, setIsDeleteOpen] = useState(false);
  const [isDeleting, setIsDeleting] = useState(false);

  const fetchCustomer = useCallback(async () => {
    try {
      setIsLoading(true);
      const token = getToken();
      if (!token) return;

      const res = await crmApi.getCustomer(token, resolvedParams.id);
      setCustomer(res);
    } catch (err) {
      console.error(err);
    } finally {
      setIsLoading(false);
    }
  }, [getToken, resolvedParams.id]);

  useEffect(() => {
    fetchCustomer();
  }, [fetchCustomer]);

  const confirmDelete = async () => {
    setIsDeleting(true);
    try {
      const token = getToken();
      if (!token) return;
      await crmApi.deleteCustomer(token, resolvedParams.id);
      setIsDeleteOpen(false);
      toast.success('Xóa khách hàng thành công');
      router.push('/customers'); // Redirect back to list
    } catch (err: any) {
      toast.error(err.message || 'Không thể xoá khách hàng này do rào cản dữ liệu.');
    } finally {
      setIsDeleting(false);
    }
  };

  const formatMoney = (amount: any) => {
    const num = Number(amount) || 0;
    return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(num);
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('vi-VN', {
      year: 'numeric', month: '2-digit', day: '2-digit',
      hour: '2-digit', minute: '2-digit'
    });
  };

  if (isLoading) {
    return (
      <div className="flex justify-center py-12">
        <Loader2 className="h-8 w-8 animate-spin text-primary" />
      </div>
    );
  }

  if (!customer) return <div className="p-8 text-center text-destructive">Không tìm thấy khách hàng</div>;

  const regionText = [customer.wardName, customer.provinceName].filter(Boolean).join(', ');

  return (
    <div className="flex flex-col gap-6 pb-4">
      {/* HEADER SECTION */}
      <div className="flex items-center gap-4">
        <Link href="/customers" className="inline-flex items-center justify-center whitespace-nowrap rounded-md text-sm font-medium transition-colors border border-input bg-background hover:bg-muted h-10 w-10 shadow-sm">
          <ArrowLeft className="h-5 w-5 text-muted-foreground" />
        </Link>
        <div className="flex-1 min-w-0">
          <h1 className="text-3xl font-bold tracking-tight text-foreground">{customer.fullName}</h1>
          <p className="text-sm text-muted-foreground mt-1">{customer.phone} <span className="mx-1">•</span> Hồ sơ Khách hàng</p>
        </div>
        <div className="flex gap-3 shrink-0">
          <Button variant="outline" onClick={() => setIsEditOpen(true)} className="shadow-sm hover:text-primary font-medium">
            <Edit className="mr-2 h-4 w-4" /> Cập nhật
          </Button>
          {user?.role === 'ADMIN' && (
            <Button 
              variant="outline" 
              onClick={() => setIsDeleteOpen(true)}
              disabled={(customer.orders?.length || 0) > 0}
              className="shadow-sm text-destructive hover:bg-destructive hover:text-destructive-foreground transition-colors"
            >
              <Trash2 className="h-4 w-4 mr-2" /> Xoá
            </Button>
          )}
          <Button onClick={() => window.dispatchEvent(new CustomEvent('open-global-order-fab', { detail: { customerId: customer.id }}))} className="shadow-md hover:shadow-lg transition-all duration-200 font-semibold px-5">
            <ShoppingCart className="mr-2 h-5 w-5" /> Lên đơn hàng
          </Button>
        </div>
      </div>

      {/* CONTENT GRID */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* LEFT COLUMN — Customer Info */}
        <div className="lg:col-span-1 space-y-5">
          {/* Info Card */}
          <Card className="glass shadow-sm border-muted/50 overflow-hidden">
            <CardHeader className="bg-muted/30 border-b py-4">
              <CardTitle className="text-base flex items-center gap-2">
                <User className="h-4 w-4 text-primary" />
                Thông tin chung
              </CardTitle>
            </CardHeader>
            <CardContent className="pt-5 space-y-0">
              {/* Group */}
              <div className="flex items-center justify-between py-3 border-b border-muted/50">
                <span className="text-sm text-muted-foreground">Nhóm KH</span>
                <span className="font-medium text-foreground">
                  {customer.group ? (
                    <Badge variant="secondary" className="font-medium">{customer.group.name}</Badge>
                  ) : (
                    <span className="text-sm text-muted-foreground italic">Chưa phân nhóm</span>
                  )}
                </span>
              </div>

              {/* Phone */}
              <div className="flex items-center justify-between py-3 border-b border-muted/50">
                <span className="text-sm text-muted-foreground flex items-center gap-1.5">
                  <Phone className="h-3.5 w-3.5" /> Điện thoại
                </span>
                <span className="font-semibold text-foreground tracking-wide">{customer.phone}</span>
              </div>

              {/* Region */}
              <div className="flex items-start justify-between py-3 border-b border-muted/50">
                <span className="text-sm text-muted-foreground flex items-center gap-1.5">
                  <MapPin className="h-3.5 w-3.5" /> Khu vực
                </span>
                <span className="font-medium text-foreground text-right max-w-[60%]">
                  {regionText || <span className="text-muted-foreground/60 italic text-sm">Chưa cập nhật</span>}
                </span>
              </div>

              {/* Address Detail */}
              <div className="flex items-start justify-between py-3">
                <span className="text-sm text-muted-foreground shrink-0">Địa chỉ</span>
                <span className="font-medium text-foreground text-right max-w-[65%]">
                  {customer.addressDetail || <span className="text-muted-foreground/60 italic text-sm">Chưa cập nhật</span>}
                </span>
              </div>
            </CardContent>
          </Card>
          
          {/* Revenue Card */}
          <Card className="glass shadow-sm border-muted/50 overflow-hidden">
            <CardContent className="py-5">
              <div className="flex items-center gap-3">
                <div className="p-2.5 bg-primary/10 rounded-xl">
                  <CreditCard className="h-5 w-5 text-primary" />
                </div>
                <div className="flex-1 min-w-0">
                  <div className="text-xs text-muted-foreground font-medium uppercase tracking-wide">Tổng doanh số</div>
                  <div className="text-xl font-bold text-primary mt-0.5">{formatMoney(customer.totalRevenue || 0)}</div>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>

        {/* RIGHT COLUMN — Order History */}
        <div className="lg:col-span-2">
          <Card className="glass shadow-sm border-muted/50 overflow-hidden h-full">
            <CardHeader className="bg-muted/30 border-b py-4 flex flex-row items-center justify-between">
              <CardTitle className="text-base flex items-center gap-2">
                <ShoppingCart className="h-4 w-4 text-primary" />
                Lịch sử giao dịch
              </CardTitle>
              <Badge variant="outline" className="bg-background font-semibold">
                {customer.orders?.length || 0} Đơn hàng
              </Badge>
            </CardHeader>
            <CardContent className="p-0">
              {!customer.orders || customer.orders.length === 0 ? (
                <div className="flex flex-col items-center justify-center text-muted-foreground py-16">
                  <Inbox className="h-12 w-12 mb-4 opacity-20" />
                  <p className="text-sm font-medium">Khách hàng chưa có đơn hàng nào.</p>
                  <p className="text-xs text-muted-foreground mt-1">Tạo đơn hàng đầu tiên bằng nút ở trên.</p>
                </div>
              ) : (
                <Table>
                  <TableHeader className="bg-muted/20">
                    <TableRow>
                      <TableHead className="px-6 text-foreground font-semibold">Mã ĐH</TableHead>
                      <TableHead className="px-6 text-foreground font-semibold">Ngày tạo</TableHead>
                      <TableHead className="px-6 text-foreground font-semibold">Tổng tiền</TableHead>
                      <TableHead className="px-6 text-foreground font-semibold">Trạng thái</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {customer.orders.map((order) => (
                      <TableRow key={order.id} className="hover:bg-muted/30 hover:cursor-pointer transition-colors" onClick={() => router.push(`/orders/${order.id}`)}>
                        <TableCell className="px-6 font-semibold text-primary">{order.orderNumber}</TableCell>
                        <TableCell className="px-6 text-muted-foreground text-sm">{formatDate(order.createdAt)}</TableCell>
                        <TableCell className="px-6 font-medium text-foreground">{formatMoney(order.totalAmount)}</TableCell>
                        <TableCell className="px-6">
                            <OrderStatusBadge status={order.deliveryStatus} />
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              )}
            </CardContent>
          </Card>
        </div>
      </div>

      {/* MODAL EDIT */}
      <CustomerFormModal
        isOpen={isEditOpen}
        onClose={() => setIsEditOpen(false)}
        onSuccess={() => {
          setIsEditOpen(false);
          fetchCustomer();
        }}
        customer={customer}
      />

      {/* MODAL DELETE */}
      <AlertDialog open={isDeleteOpen} onOpenChange={(open) => !open && !isDeleting && setIsDeleteOpen(false)}>
        <AlertDialogContent className="glass sm:max-w-[425px]">
          <AlertDialogHeader>
            <AlertDialogTitle className="flex items-center gap-2 text-destructive">
              <AlertCircle className="h-5 w-5" />
              Xóa khách hàng?
            </AlertDialogTitle>
            <AlertDialogDescription className="pt-2 text-foreground/80">
              Bạn có chắc chắn muốn xoá khách hàng <strong className="text-foreground">{customer.fullName}</strong> khỏi hệ thống? Hệ thống sẽ vĩnh viễn xóa dữ liệu của khách hàng này. Thao tác này <strong>không thể hoàn tác</strong>.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter className="mt-4">
            <AlertDialogCancel disabled={isDeleting} className="hover:bg-muted/50 border-0 bg-transparent shadow-none">
              Huỷ bỏ
            </AlertDialogCancel>
            <AlertDialogAction onClick={confirmDelete} disabled={isDeleting} className="bg-destructive text-destructive-foreground hover:bg-destructive/90">
              {isDeleting ? <Loader2 className="mr-2 h-4 w-4 animate-spin" /> : null}
              Xác nhận xóa
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}
