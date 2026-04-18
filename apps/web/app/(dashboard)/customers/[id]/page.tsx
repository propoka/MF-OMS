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
import { ArrowLeft, ArrowRight, ShoppingCart, Edit, Inbox, Trash2, AlertTriangle, Loader2, AlertCircle, Phone, MapPin, DollarSign, User, CreditCard } from 'lucide-react';
import * as xlsx from 'xlsx';
import { GenerativeAvatar } from '@/components/ui/generative-avatar';
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
      <div className="flex flex-col xl:flex-row xl:items-center justify-between gap-4">
        <div className="flex items-center gap-4">
          <Link href="/customers" className="inline-flex items-center justify-center rounded-xl transition-colors bg-white/50 border border-border/40 hover:bg-white h-11 w-11 shadow-sm shrink-0">
            <ArrowLeft className="h-5 w-5 text-muted-foreground" />
          </Link>
          <div className="flex-1 min-w-0">
            <h1 className="text-2xl lg:text-3xl font-bold tracking-tight text-foreground flex items-center gap-3">
              {customer.fullName}
            </h1>
            <p className="flex flex-wrap items-center gap-2 lg:gap-4 text-[13px] text-muted-foreground mt-1.5 font-medium">
              <span className="flex items-center gap-1.5"><User className="h-3.5 w-3.5" /> Hồ sơ Khách hàng</span>
            </p>
          </div>
        </div>

        {/* ACTION DOCK */}
        <div className="flex bg-white shadow-sm border border-border/40 rounded-full p-1.5 shrink-0 h-12 w-auto items-center">
          <Button variant="ghost" onClick={() => setIsEditOpen(true)} className="rounded-full h-full w-9 p-0 text-muted-foreground hover:bg-primary/10 hover:text-primary transition-all duration-300" title="Cập nhật thông tin">
            <Edit className="h-[18px] w-[18px]" />
          </Button>
          {user?.role === 'ADMIN' && (
            <Button 
              variant="ghost" 
              onClick={() => setIsDeleteOpen(true)}
              disabled={(customer.orders?.length || 0) > 0}
              className="rounded-full h-full w-9 p-0 text-muted-foreground hover:bg-red-50 hover:text-red-700 transition-all duration-300"
              title={(customer.orders?.length || 0) > 0 ? "Không thể xoá khách đang có đơn hàng" : "Xoá vĩnh viễn"}
            >
              <Trash2 className="h-[18px] w-[18px]" />
            </Button>
          )}
          <div className="w-[1px] h-[60%] bg-border/40 mx-2"></div>
          <Button onClick={() => window.dispatchEvent(new CustomEvent('open-global-order-fab', { detail: { customerId: customer.id }}))} className="group relative overflow-hidden bg-neutral-900/90 hover:bg-black text-white shadow-[0_4px_14px_0_rgba(0,0,0,0.1)] hover:shadow-[0_6px_20px_rgba(0,0,0,0.15)] transition-all duration-300 font-bold px-6 h-full rounded-full w-auto flex-1 xl:flex-none">
            <ShoppingCart className="mr-2 h-4 w-4 opacity-90 group-hover:scale-110 transition-transform duration-300" />
            <span className="relative z-10 text-[13px] tracking-tight whitespace-nowrap">Lên đơn hàng</span>
          </Button>
        </div>
      </div>

      {/* CONTENT GRID */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* LEFT COLUMN — CRM Profile Card */}
        <div className="lg:col-span-1 flex flex-col items-start">
          <Card className="w-full bg-white border border-border/30 shadow-[0_2px_12px_-4px_rgba(0,0,0,0.05)] rounded-[24px] overflow-hidden hover:shadow-md transition-shadow">
            
            {/* Top Identity Block */}
            <div className="bg-muted/10 p-6 flex flex-col items-center text-center border-b border-border/30 relative">
               <div className="mb-4">
                 <GenerativeAvatar name={customer.fullName || 'C'} size={72} />
               </div>
               <h2 className="text-xl font-bold text-foreground tracking-tight">{customer.fullName}</h2>
               <div className="mt-2.5">
                 {customer.group ? (
                   <Badge variant="secondary" className="font-semibold bg-white border border-border/40 text-muted-foreground text-[11px] py-1 px-3 shadow-sm rounded-full">
                     {customer.group.name}
                   </Badge>
                 ) : (
                   <span className="text-muted-foreground italic text-xs">Chưa phân nhóm</span>
                 )}
               </div>
            </div>

            {/* Quick Stats Grid */}
            <div className="grid grid-cols-2 divide-x divide-border/30 border-b border-border/30 bg-white/50">
               <div className="p-4 flex flex-col items-center justify-center hover:bg-muted/10 transition-colors">
                  <span className="text-[10px] text-muted-foreground/80 font-bold uppercase tracking-widest mb-1.5 flex items-center gap-1">
                    <CreditCard className="w-3 h-3" /> Doanh số
                  </span>
                  <span className="font-black text-[15px] text-[oklch(0.40_0.06_45)] tracking-tight">
                    {formatMoney(customer.totalRevenue || 0)}
                  </span>
               </div>
               <div className="p-4 flex flex-col items-center justify-center hover:bg-muted/10 transition-colors">
                  <span className="text-[10px] text-muted-foreground/80 font-bold uppercase tracking-widest mb-1.5 flex items-center gap-1">
                    <ShoppingCart className="w-3 h-3" /> Đơn hàng
                  </span>
                  <span className="font-black text-[15px] text-foreground tracking-tight">
                    {customer.orders?.length || 0}
                  </span>
               </div>
            </div>

            {/* Contact Details List */}
            <div className="p-6 space-y-5 bg-white">
               <div className="flex items-start gap-3.5 group">
                  <div className="p-2 bg-muted/40 rounded-xl group-hover:bg-primary/10 transition-colors">
                     <Phone className="w-4 h-4 text-muted-foreground group-hover:text-primary transition-colors" />
                  </div>
                  <div className="flex flex-col min-w-0 pt-0.5">
                     <span className="text-[11px] text-muted-foreground font-medium uppercase tracking-wider mb-0.5">Điện thoại</span>
                     <span className="text-[14px] font-bold text-foreground tracking-tight">{customer.phone}</span>
                  </div>
               </div>

               <div className="flex items-start gap-3.5 group">
                  <div className="p-2 bg-muted/40 rounded-xl group-hover:bg-primary/10 transition-colors">
                     <MapPin className="w-4 h-4 text-muted-foreground group-hover:text-primary transition-colors" />
                  </div>
                  <div className="flex flex-col min-w-0 pt-0.5">
                     <span className="text-[11px] text-muted-foreground font-medium uppercase tracking-wider mb-0.5">Địa chỉ</span>
                     <span className="text-[13px] font-medium text-foreground leading-relaxed">
                       {customer.addressDetail || regionText ? (
                         [customer.addressDetail, regionText].filter(Boolean).join(', ')
                       ) : (
                         <span className="text-[10px] text-muted-foreground/60 uppercase tracking-widest font-semibold mt-0.5 inline-block">Chưa cập nhật</span>
                       )}
                     </span>
                  </div>
               </div>
            </div>
          </Card>
        </div>

        {/* RIGHT COLUMN — Order History */}
        <div className="lg:col-span-2 flex flex-col h-full">
          <Card className="bg-white/40 border border-border/30 shadow-[0_2px_12px_-4px_rgba(0,0,0,0.05)] rounded-[20px] overflow-hidden flex flex-col flex-1 h-full hover:shadow-md transition-shadow">
            <CardHeader className="border-b border-border/30 py-4 px-6 flex flex-row items-center justify-between">
              <CardTitle className="text-[15px] font-bold flex items-center gap-2">
                <ShoppingCart className="h-4 w-4 text-primary" />
                Lịch sử giao dịch
              </CardTitle>
              <Badge variant="outline" className="bg-muted/30 font-semibold text-muted-foreground rounded-full border border-border shadow-sm py-1 px-3">
                {customer.orders?.length || 0} Đơn hàng
              </Badge>
            </CardHeader>
            <CardContent className="p-0 flex-1">
              {!customer.orders || customer.orders.length === 0 ? (
                <div className="flex flex-col items-center justify-center text-muted-foreground py-16">
                  <Inbox className="h-12 w-12 mb-4 opacity-20" />
                  <p className="text-sm font-medium">Khách hàng chưa có đơn hàng nào.</p>
                  <p className="text-xs text-muted-foreground mt-1">Tạo đơn hàng đầu tiên bằng nút ở trên.</p>
                </div>
              ) : (
                <Table>
                  <TableHeader className="bg-transparent">
                    <TableRow className="hover:bg-transparent border-b border-border/40">
                      <TableHead className="px-6 pb-4 text-[11px] uppercase tracking-wider font-semibold text-muted-foreground">Mã ĐH</TableHead>
                      <TableHead className="px-6 pb-4 text-[11px] uppercase tracking-wider font-semibold text-muted-foreground">Ngày tạo</TableHead>
                      <TableHead className="px-6 pb-4 text-[11px] uppercase tracking-wider font-semibold text-muted-foreground text-right">Tổng tiền</TableHead>
                      <TableHead className="px-6 pb-4 text-[11px] uppercase tracking-wider font-semibold text-muted-foreground text-center">Trạng thái</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {customer.orders.map((order) => (
                      <TableRow key={order.id} className="group hover:bg-muted/40 transition-colors border-border/30 cursor-pointer" onClick={() => router.push(`/orders/${order.id}`)}>
                        <TableCell className="px-6 py-4 align-top">
                          <Link href={`/orders/${order.id}`} className="group/link flex items-center gap-1 font-medium text-[13px] text-foreground hover:text-primary transition-colors whitespace-nowrap">
                            <span>{order.orderNumber}</span>
                            <ArrowRight className="w-3.5 h-3.5 opacity-0 -translate-x-2 group-hover/link:opacity-100 group-hover/link:translate-x-0 transition-all duration-300" />
                          </Link>
                        </TableCell>
                        <TableCell className="px-6 py-4 align-top text-foreground font-medium whitespace-nowrap">
                          <span className="font-bold text-[14px] text-foreground tracking-tight block">
                            {formatDate(order.createdAt).split(' ')[1]}
                          </span>
                          <span className="text-[12px] font-semibold text-muted-foreground block mt-1 opacity-80 uppercase tracking-widest">
                            {formatDate(order.createdAt).split(' ')[0]}
                          </span>
                        </TableCell>
                        <TableCell className="px-6 py-4 align-top font-bold text-[14px] text-[oklch(0.40_0.06_45)] tracking-tight whitespace-nowrap text-right">
                          {formatMoney(order.totalAmount)}
                        </TableCell>
                        <TableCell className="px-6 py-4 align-top text-center w-[120px]">
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
        <AlertDialogContent className="glass sm:max-w-[425px] border-border/40 shadow-2xl p-6">
          <AlertDialogHeader className="flex flex-col items-center text-center space-y-4">
            <div className="w-14 h-14 rounded-full bg-red-500/10 flex items-center justify-center shrink-0">
              <AlertCircle className="w-7 h-7 text-red-600" />
            </div>
            <div className="space-y-2">
              <AlertDialogTitle className="text-xl font-bold text-foreground">
                Xóa khách hàng?
              </AlertDialogTitle>
              <AlertDialogDescription className="text-foreground/80 leading-relaxed text-sm">
                Bạn có chắc chắn muốn xoá khách hàng <strong className="text-red-600 font-bold">{customer.fullName}</strong> khỏi hệ thống? 
                <br/><br/>
                Hệ thống sẽ vĩnh viễn xóa dữ liệu của khách hàng này cùng mọi hóa đơn nếu có. Thao tác này là <strong className="text-foreground">không thể hoàn tác</strong>.
              </AlertDialogDescription>
            </div>
          </AlertDialogHeader>
          
          <AlertDialogFooter className="sm:justify-center flex-row gap-3 pt-6 w-full">
            <AlertDialogCancel disabled={isDeleting} className="flex-1 text-foreground font-semibold hover:bg-muted/50 border border-border/60 bg-white/50 m-0 shadow-sm transition-all text-[13px]">
              Huỷ bỏ
            </AlertDialogCancel>
            <Button 
              variant="default" 
              onClick={confirmDelete} 
              disabled={isDeleting} 
              className="flex-1 bg-red-600 text-white hover:bg-red-700 shadow-[0_0_15px_rgba(220,38,38,0.25)] hover:shadow-[0_0_20px_rgba(220,38,38,0.4)] transition-all duration-300 m-0 text-[13px] font-bold"
            >
              {isDeleting ? (
                 <span className="flex items-center gap-2">
                   <Loader2 className="w-4 h-4 animate-spin" /> Xử lý...
                 </span>
              ) : 'Xác nhận Xóa'}
            </Button>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}
