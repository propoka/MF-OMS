'use client';

import { useState, useEffect } from 'react';
import { ordersApi, settingsApi, Order, CompanySettings, CancelReason } from '@/lib/api';
import { useAuth } from '@/lib/auth-context';
import { useParams, useRouter } from 'next/navigation';
import { Button } from '@/components/ui/button';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { ArrowLeft, Printer, AlertTriangle, Truck, ShieldAlert, Pencil, History, Phone, MapPin, User, Package, FileText, Clock, Trash2, FileDown } from 'lucide-react';
import { Badge } from '@/components/ui/badge';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { OrderStatusBadge } from '@/components/ui/order-status-badge';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import Link from 'next/link';
import { toast } from 'sonner';
import { ORDER_STATUS_CONFIG } from '@/lib/constants';
import * as xlsx from 'xlsx';
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
import { AlertCircle, Loader2, CalendarIcon } from 'lucide-react';

export default function OrderDetailPage() {
  const { id } = useParams();
  const router = useRouter();
  const { getToken, user } = useAuth();
  
  const [order, setOrder] = useState<Order | null>(null);
  const [company, setCompany] = useState<CompanySettings | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);
  const [isCancelModalOpen, setIsCancelModalOpen] = useState(false);
  const [isDeleteModalOpen, setIsDeleteModalOpen] = useState(false);
  const [cancelReasons, setCancelReasons] = useState<CancelReason[]>([]);
  const [selectedCancelReasonId, setSelectedCancelReasonId] = useState<string>('');
  const [cancelNotes, setCancelNotes] = useState<string>('');

  useEffect(() => {
    fetchDetail();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [id]);

  const fetchDetail = async () => {
    try {
      setIsLoading(true);
      const [orderRes, companyRes, reasonsRes] = await Promise.all([
        ordersApi.getOrder(getToken()!, id as string),
        settingsApi.getCompanySettings(getToken()!).catch(() => null),
        settingsApi.getCancelReasons(getToken()!).catch(() => [])
      ]);
      setOrder(orderRes);
      if (companyRes) setCompany(companyRes);
      if (reasonsRes) setCancelReasons(reasonsRes.filter(r => r.isActive));
    } catch (err: any) {
      toast.error(err.message || 'Không kết nối được dữ liệu hoá đơn.');
      router.push('/orders');
    } finally {
      setIsLoading(false);
    }
  };

  const updateStatus = async (val: string | null, extraData?: { cancelReasonId?: string, cancelNotes?: string }) => {
    if (!val) return;
    try {
      setIsSaving(true);
      await ordersApi.updateStatus(getToken()!, id as string, {
        deliveryStatus: val,
        ...extraData
      });
      toast.success('Cập nhật trạng thái thành công.');
      fetchDetail();
    } catch (e: any) {
      toast.error(e.message || 'Không thể thao tác lúc này.');
    } finally {
      setIsSaving(false);
    }
  };

  const handleDeleteOrder = async () => {
    try {
      setIsSaving(true);
      await ordersApi.deleteOrder(getToken()!, id as string);
      toast.success('Đã xoá đơn hàng vĩnh viễn.');
      router.push('/orders');
    } catch (e: any) {
      toast.error(e.message || 'Không thể xoá đơn hàng.');
      setIsSaving(false);
    }
  };

  const handlePrint = () => {
    window.print();
  };

  const handleExportExcel = () => {
    if (!order) return;
    const detailsData: any[] = [];
    const phoneStr = order.snapshotCustomerPhone ? String(order.snapshotCustomerPhone) : '';
    
    if (!order.items || order.items.length === 0) {
      detailsData.push({
        'Mã Đơn': order.orderNumber,
        'Ngày tạo': new Date(order.createdAt).toLocaleString('vi-VN'),
        'Trạng thái': getStatusLabel(order.deliveryStatus),
        'Khách hàng': order.snapshotCustomerName,
        'SĐT': phoneStr,
        'Nhóm khách': order.customer?.group?.name || 'Khách lẻ',
        'SKU': '',
        'Tên SP': '',
        'ĐVT': '',
        'SL': 0,
        'Đơn giá bán': 0,
        'Chiết khấu dòng': 0,
        'Thành Tiền Dòng': 0,
        'Tổng tiền Hàng (Đơn)': Number(order.subtotal || 0),
        'Chiết khấu Đơn': Number(order.discountAmount || 0),
        'Phí Ship': Number(order.shippingFee || 0),
        'Thực thu': Number(order.totalAmount || 0),
        'Thu ngân': order.createdBy?.fullName || '',
        'Ghi chú': order.notes || ''
      });
    } else {
      order.items.forEach(i => {
        detailsData.push({
          'Mã Đơn': order.orderNumber,
          'Ngày tạo': new Date(order.createdAt).toLocaleString('vi-VN'),
          'Trạng thái': getStatusLabel(order.deliveryStatus),
          'Khách hàng': order.snapshotCustomerName,
          'SĐT': phoneStr,
          'Nhóm khách': order.customer?.group?.name || 'Khách lẻ',
          'SKU': i.snapshotProductSku,
          'Tên SP': i.snapshotProductName,
          'ĐVT': i.snapshotProductUnit || '',
          'SL': Number(i.quantity || 0),
          'Đơn giá bán': Number(i.snapshotUnitPrice || 0),
          'Chiết khấu dòng': Number(i.lineDiscount || 0),
          'Thành Tiền Dòng': Number(i.lineTotal || 0),
          'Tổng tiền Hàng (Đơn)': Number(order.subtotal || 0),
          'Chiết khấu Đơn': Number(order.discountAmount || 0),
          'Phí Ship': Number(order.shippingFee || 0),
          'Thực thu': Number(order.totalAmount || 0),
          'Thu ngân': order.createdBy?.fullName || '',
          'Ghi chú': order.notes || ''
        });
      });
    }

    const wb = xlsx.utils.book_new();
    const ws = xlsx.utils.json_to_sheet(detailsData);
    ws['!cols'] = [{wch: 15}, {wch: 20}, {wch: 15}, {wch: 20}, {wch: 15}, {wch: 15}, {wch: 12}, {wch: 30}];
    xlsx.utils.book_append_sheet(wb, ws, 'Order Details');
    xlsx.writeFile(wb, `ChiTietDonHang_${order.orderNumber}.xlsx`);
    toast.success('Đã tải xuống file Excel.');
  };

  const formatMoney = (amount: number) => new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(amount);



  const getStatusLabel = (status: string) => {
    const s = (status || '').toUpperCase();
    const map: Record<string, string> = {
      'PENDING': 'Chờ xác nhận',
      'PROCESSING': 'Đang xử lý',
      'SHIPPING': 'Đang giao',
      'COMPLETED': 'Hoàn thành',
      'RETURNED': 'Hoàn trả',
      'CANCELLED': 'Huỷ'
    };
    return map[s] || s;
  };

  if (isLoading || !order) {
    return <div className="p-10 text-center flex flex-col items-center justify-center min-h-[50vh]"><div className="w-8 h-8 border-4 border-primary border-t-transparent rounded-full animate-spin mb-4"></div><span className="text-muted-foreground animate-pulse">Đang tải hoá đơn...</span></div>;
  }

  const normalizedStatus = (order.deliveryStatus || '').toUpperCase();
  const isCancelled = ['CANCELLED', 'RETURNED'].includes(normalizedStatus);
  const isCancellable = ['PENDING', 'PROCESSING'].includes(normalizedStatus);

  const VALID_TRANSITIONS: Record<string, string[]> = {
    PENDING:    ['PROCESSING', 'CANCELLED'],
    PROCESSING: ['SHIPPING', 'CANCELLED'],
    SHIPPING:   ['COMPLETED', 'RETURNED'],
    COMPLETED:  ['RETURNED'],
    RETURNED:   [],
    CANCELLED:  [],
  };
  const allowedTransitions = VALID_TRANSITIONS[normalizedStatus] || [];
  const totalDiscount = Number(order.discountAmount || 0) + (order.items?.reduce((sum, item) => sum + Number(item.lineDiscount || 0), 0) || 0);
  const totalQuantity = order.items?.reduce((sum, item) => sum + (Number(item.quantity) || 0), 0) || 0;

  return (
    <div className="flex flex-col gap-6 pb-8">
      {/* HEADER SECTION */}
      <div className="flex flex-col xl:flex-row xl:items-center justify-between gap-4 print:hidden">
        <div className="flex items-center gap-4">
          <Link href="/orders" className="inline-flex items-center justify-center rounded-xl transition-colors bg-white/50 border border-border/40 hover:bg-white h-11 w-11 shadow-sm shrink-0">
            <ArrowLeft className="h-5 w-5 text-muted-foreground" />
          </Link>
          <div className="flex-1 min-w-0">
            <h1 className="text-2xl lg:text-3xl font-bold tracking-tight text-foreground flex items-center gap-3">
              Hóa đơn {order.orderNumber}
            </h1>
            <div className="flex flex-wrap items-center gap-2 lg:gap-4 text-[13px] text-muted-foreground mt-1.5 font-medium">
              <OrderStatusBadge status={normalizedStatus} />
              <span className="hidden lg:inline text-border/60">•</span>
              <span className="flex items-center gap-1.5">
                <CalendarIcon className="h-3.5 w-3.5" />
                {new Date(order.createdAt).toLocaleTimeString('vi-VN', {hour: '2-digit', minute:'2-digit'})} - {new Date(order.createdAt).toLocaleDateString('vi-VN', {day:'2-digit', month:'2-digit', year:'numeric'})}
              </span>
              <span className="hidden lg:inline text-border/60">•</span>
              <span className="flex items-center gap-1.5">
                <User className="h-3.5 w-3.5" />
                Thu ngân: {order.createdBy?.fullName || 'Hệ thống'}
              </span>
            </div>
          </div>
        </div>

        {/* ACTION DOCK */}
        <div className="flex bg-white/50 border border-white/40 shadow-sm rounded-full p-1 h-11 shrink-0 w-full xl:w-auto">
          {normalizedStatus === 'PENDING' && (
            <Link href={`/orders/${id}/edit`} tabIndex={-1}>
              <Button variant="ghost" className="rounded-full h-full px-3 text-muted-foreground hover:bg-white hover:text-primary transition-all duration-300" title="Chỉnh sửa">
                <Pencil className="h-4 w-4" />
              </Button>
            </Link>
          )}
          {isCancellable && (
            <Button variant="ghost" onClick={() => setIsCancelModalOpen(true)} className="rounded-full h-full px-3 text-muted-foreground hover:bg-amber-50 hover:text-amber-700 transition-all duration-300" title="Huỷ đơn hàng">
              <ShieldAlert className="h-4 w-4" />
            </Button>
          )}
          {user?.role === 'ADMIN' && (
            <Button variant="ghost" onClick={() => setIsDeleteModalOpen(true)} className="rounded-full h-full px-3 text-muted-foreground hover:bg-red-50 hover:text-red-700 transition-all duration-300" disabled={isSaving} title="Xoá vĩnh viễn">
              <Trash2 className="h-4 w-4" />
            </Button>
          )}
          
          {(normalizedStatus === 'PENDING' || isCancellable || user?.role === 'ADMIN') && (
            <div className="w-[1px] h-full bg-border/40 mx-1"></div>
          )}
          
          <Button variant="ghost" onClick={handleExportExcel} className="rounded-full h-full text-[13px] font-semibold px-4 hover:bg-emerald-50 hover:text-emerald-700 text-muted-foreground transition-all duration-300 flex-1 xl:flex-none">
            <FileDown className="mr-2 h-4 w-4" /> 
            <span className="hidden sm:inline">Xuất Excel</span>
          </Button>
          <Button variant="ghost" onClick={handlePrint} className="rounded-full h-full text-[13px] font-bold px-5 text-primary hover:bg-primary/10 transition-all duration-300 flex-1 xl:flex-none">
            <Printer className="mr-2 h-4 w-4" />
            In Hóa Đơn
          </Button>
        </div>
      </div>

      {isCancelled && (
        <div className="p-4 bg-destructive/10 text-destructive text-sm rounded-xl flex items-center gap-3 print:hidden border border-destructive/20 shadow-sm">
          <AlertTriangle className="h-5 w-5 shrink-0" />
          <span className="leading-relaxed">Đơn hàng đã bị <strong>HUỶ</strong> hoặc <strong>HOÀN</strong>.</span>
        </div>
      )}

      {/* CONTENT GRID */}
      <div className="grid grid-cols-1 xl:grid-cols-3 gap-6 print:block">
        
        {/* LEFT: Order Items */}
        <div className="xl:col-span-2 print:col-span-3">
          <Card className="bg-white/40 backdrop-blur-3xl border border-white/40 shadow-sm shadow-black/5 rounded-[24px] overflow-hidden print:shadow-none print:border-none print:bg-transparent">
            <CardHeader className="bg-white/40 border-b border-white/40 py-4 print:hidden flex flex-row items-center justify-between px-6">
              <CardTitle className="text-base flex items-center gap-2">
                <Package className="h-4 w-4 text-primary" />
                Chi tiết đơn hàng
              </CardTitle>
              <Badge variant="outline" className="bg-background font-semibold">
                {order.items?.length || 0} Sản phẩm
              </Badge>
            </CardHeader>
            
            <div className="print:hidden">
              <CardContent className="p-0">
              <Table>
                <TableHeader className="bg-muted/20">
                  <TableRow className="hover:bg-transparent">
                    <TableHead className="px-6 text-[11px] uppercase tracking-wider font-semibold text-muted-foreground w-auto">Sản phẩm</TableHead>
                    <TableHead className="px-3 text-[11px] uppercase tracking-wider font-semibold text-muted-foreground text-center w-[70px]">ĐVT</TableHead>
                    <TableHead className="px-3 text-[11px] uppercase tracking-wider font-semibold text-muted-foreground text-center w-[60px]">SL</TableHead>
                    <TableHead className="px-4 text-[11px] uppercase tracking-wider font-semibold text-muted-foreground text-right w-[110px]">Đơn giá</TableHead>
                    <TableHead className="px-4 text-[11px] uppercase tracking-wider font-semibold text-muted-foreground text-right w-[110px]">Chiết khấu</TableHead>
                    <TableHead className="px-6 text-[11px] uppercase tracking-wider font-semibold text-muted-foreground text-right w-[120px]">Thành tiền</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {order.items?.map((item, idx) => (
                    <TableRow key={idx} className="hover:bg-muted/30 transition-colors">
                      <TableCell className="px-6 py-3">
                        <div className="font-semibold text-foreground">{item.snapshotProductName}</div>
                        <div className="flex items-center gap-1.5 mt-0.5 flex-wrap">
                          <span className="text-[10px] text-muted-foreground/80 tracking-wide font-medium">SKU: {item.snapshotProductSku}</span>
                          {item.pricingNote && <span className="text-[10px] text-primary/70 font-medium italic print:hidden">• {item.pricingNote}</span>}
                        </div>
                      </TableCell>
                      <TableCell className="px-3 text-center text-sm text-muted-foreground">{item.snapshotProductUnit}</TableCell>
                      <TableCell className="px-3 text-center font-bold text-foreground">{item.quantity}</TableCell>
                      <TableCell className="px-4 text-right text-sm text-muted-foreground">{formatMoney(item.snapshotUnitPrice)}</TableCell>
                      <TableCell className="px-4 text-right text-sm text-muted-foreground">{item.lineDiscount > 0 ? formatMoney(item.lineDiscount) : '-'}</TableCell>
                      <TableCell className="px-6 text-right font-bold text-foreground">{formatMoney(item.lineTotal)}</TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>

              {/* Summary Footer */}
              <div className="px-6 py-5 bg-muted/20 border-t">
                <div className="flex justify-end">
                  <div className="w-full md:w-[320px] space-y-2">
                    <div className="flex justify-between text-sm text-muted-foreground">
                      <span>Tạm tính:</span>
                      <span className="font-semibold text-foreground text-right min-w-[120px]">{formatMoney(order.subtotal)}</span>
                    </div>
                    <div className="flex justify-between text-sm text-muted-foreground">
                      <span>Phí vận chuyển:</span>
                      <span className="font-semibold text-foreground text-right min-w-[120px]">{order.shippingFee > 0 ? '+' : ''} {formatMoney(order.shippingFee)}</span>
                    </div>
                    {totalDiscount > 0 ? (
                      <div className="flex justify-between text-sm text-muted-foreground border-b border-border/50 pb-3 mt-2">
                        <span>Chiết khấu:</span>
                        <span className="font-semibold text-destructive text-right min-w-[120px]">- {formatMoney(totalDiscount)}</span>
                      </div>
                    ) : (
                      <div className="flex justify-between text-sm text-muted-foreground border-b border-border/50 pb-3 mt-2">
                        <span>Chiết khấu:</span>
                        <span className="font-semibold text-foreground text-right min-w-[120px]">0 ₫</span>
                      </div>
                    )}
                    <div className="flex justify-between font-bold items-center pt-2">
                      <span className="text-[14px] text-muted-foreground uppercase tracking-wider">Tổng Thu</span>
                      <span className="text-[26px] text-foreground text-right min-w-[120px] tracking-tight">{formatMoney(order.totalAmount)}</span>
                    </div>
                  </div>
                </div>
              </div>

              {order.notes && (
                <div className="mx-6 mb-6 p-4 bg-amber-50/80 rounded-xl border border-amber-200/60 print:hidden">
                  <div className="flex items-center gap-2 mb-1.5 text-amber-800">
                     <FileText className="h-4 w-4" />
                     <p className="font-semibold text-sm">Ghi chú đơn hàng</p>
                  </div>
                  <p className="text-sm italic text-amber-900/80 leading-relaxed">{order.notes}</p>
                </div>
              )}
              </CardContent>
            </div>

            {/* ======================= BẢN IN POS A5 ======================= */}
            <div id="pos-receipt" className="hidden print:block w-full text-black" style={{ fontFamily: '"Inter", sans-serif' }}>
              <style dangerouslySetInnerHTML={{__html: `
                @media print {
                  @page { size: A5; margin: 15mm; }
                  
                  /* Ép toàn bộ các thẻ con đều trong suốt màu nền và chữ phải đen */
                  * {
                    background-color: transparent !important;
                    color: black !important;
                  }
                  
                  /* Tẩy viền bo tròn và đổ bóng của khối Card bao ngoài hóa đơn */
                  .glass, .shadow-sm, [class*="border-muted"] {
                    box-shadow: none !important;
                    border: none !important;
                    border-radius: 0 !important;
                  }
                  
                  body { background: white !important; padding: 0 !important; margin: 0 !important; -webkit-print-color-adjust: exact; print-color-adjust: exact; }
                  
                  /* Gỡ bỏ giới hạn chiều cao từ các container bên ngoài để nội dung không bị cắt khi sang trang mới */
                  html, body, #__next, #root, [data-sidebar="wrapper"], [data-sidebar="inset"], main, section, .h-screen, .overflow-hidden, .glass, .print\\:col-span-3, .xl\\:col-span-2 { 
                    height: auto !important; 
                    min-height: 0 !important; 
                    overflow: visible !important; 
                    position: static !important; 
                    padding: 0 !important;
                    margin: 0 !important;
                    max-width: 100% !important;
                    width: auto !important;
                  }
                  
                  /* Ẩn triệt để thanh sidebar và top header của layout chính */
                  [data-sidebar="sidebar"], header { 
                    display: none !important; 
                  }
                  
                  /* Trả lại dòng chảy chuẩn (flow) cho hóa đơn để trình duyệt tự ngắt trang */
                  #pos-receipt { 
                    width: 100% !important; 
                    margin: 0 !important;
                    padding: 0 !important;
                    display: block !important;
                  }
                }
              `}} />
              
              <div className="flex flex-col items-center mb-3 pb-2 border-b-[1.5px] border-black">
                <h2 className="text-[16px] xl:text-[18px] font-black uppercase tracking-tight mb-0.5 text-center w-full">{company?.name || 'CỬA HÀNG MINH PHƯƠNG'}</h2>
                {(company?.address || company?.phone) && (
                  <div className="text-center w-full">
                    {company?.address && <p className="text-[11px] font-medium leading-tight">ĐC: {company.address}</p>}
                    {company?.phone && <p className="text-[11px] font-medium leading-tight">Hotline: {company.phone}</p>}
                  </div>
                )}
              </div>

              <div className="text-center mb-3">
                <h1 className="text-[18px] xl:text-[20px] font-bold uppercase tracking-widest inline-block">Hoá Đơn Bán Hàng</h1>
              </div>

              <div className="text-[11px] xl:text-[12px] mb-3 leading-tight">
                <div className="grid grid-cols-2 gap-2 mb-1">
                  <div className="flex gap-1">
                    <span className="font-semibold min-w-[55px]">Mã HĐ:</span>
                    <span>{order.orderNumber}</span>
                  </div>
                  <div className="flex gap-1 justify-end text-right">
                    <span className="font-semibold">Ngày tạo:</span>
                    <span>{new Date(order.createdAt).toLocaleDateString('vi-VN', {day:'2-digit', month:'2-digit', year:'numeric'})} {new Date(order.createdAt).toLocaleTimeString('vi-VN', {hour:'2-digit', minute:'2-digit'})}</span>
                  </div>
                </div>
                
                <div className="grid grid-cols-2 gap-2 mb-1">
                  <div className="flex gap-1">
                    <span className="font-semibold min-w-[55px]">Nhân viên:</span>
                    <span>{order.createdBy?.fullName || 'Hệ thống'}</span>
                  </div>
                  <div className="flex gap-1 justify-end text-right">
                    <span className="font-semibold">SĐT:</span>
                    <span>{order.snapshotCustomerPhone}</span>
                  </div>
                </div>

                <div className="flex gap-1 mb-1">
                  <span className="font-semibold min-w-[55px]">Khách:</span>
                  <span className="font-bold uppercase w-full">{order.snapshotCustomerName}</span>
                </div>

                <div className="hidden gap-1">
                  <span className="font-semibold min-w-[55px]">Giao tới:</span>
                  <span className="w-full">{[order.customer?.addressDetail, order.customer?.wardName, order.customer?.provinceName].filter(Boolean).join(', ') || 'Mua trực tiếp tại quầy'}</span>
                </div>
              </div>

              <table className="w-full text-[10px] xl:text-[11px] mb-4 border-collapse border border-black">
                <thead className="bg-transparent">
                  <tr>
                    <th className="border border-black text-center py-1 font-bold w-[5%]">STT</th>
                    <th className="border border-black text-left py-1 font-bold px-1.5 w-[15%]">Mã SP</th>
                    <th className="border border-black text-left py-1 font-bold px-1.5">Tên sản phẩm</th>
                    <th className="border border-black text-center py-1 font-bold w-[8%]">ĐVT</th>
                    <th className="border border-black text-center py-1 font-bold w-[8%]">SL</th>
                    <th className="border border-black text-right py-1 font-bold px-1.5 w-[15%]">Đơn giá</th>
                    <th className="border border-black text-right py-1 font-bold px-1.5 w-[18%]">Thành tiền</th>
                  </tr>
                </thead>
                <tbody>
                  {order.items?.map((item, idx) => (
                    <tr key={idx}>
                      <td className="border border-black text-center py-1 px-1">{idx + 1}</td>
                      <td className="border border-black text-left py-1 px-1.5 break-all leading-tight">{item.snapshotProductSku}</td>
                      <td className="border border-black text-left py-1 px-1.5">
                        <div className="font-semibold leading-tight">{item.snapshotProductName}</div>
                        {item.lineDiscount > 0 && <div className="text-[9px] italic text-black leading-tight">- CK: {formatMoney(item.lineDiscount)}/SP</div>}
                      </td>
                      <td className="border border-black text-center py-1 px-1">{item.snapshotProductUnit}</td>
                      <td className="border border-black text-center py-1 font-semibold px-1">{item.quantity}</td>
                      <td className="border border-black text-right py-1 px-1.5">{formatMoney(item.snapshotUnitPrice)}</td>
                      <td className="border border-black text-right py-1 font-bold px-1.5">{formatMoney(item.lineTotal)}</td>
                    </tr>
                  ))}
                </tbody>
              </table>

              <div className="flex justify-end mb-4 text-[11px] xl:text-[12px]">
                <div className="w-[60%]">
                  <div className="flex justify-between items-center py-0.5">
                    <span className="font-semibold">Tổng số lượng:</span>
                    <span>{totalQuantity}</span>
                  </div>
                  <div className="flex justify-between items-center py-0.5">
                    <span className="font-semibold">Tổng tiền:</span>
                    <span>{formatMoney(order.subtotal)}</span>
                  </div>
                  <div className="flex justify-between items-center py-0.5">
                    <span className="font-semibold">Chiết khấu:</span>
                    <span>{totalDiscount > 0 ? `- ${formatMoney(totalDiscount)}` : '0 ₫'}</span>
                  </div>
                  <div className="flex justify-between items-center py-0.5 border-b border-black pb-1">
                    <span className="font-semibold">Phí vận chuyển:</span>
                    <span>{order.shippingFee > 0 ? `+ ${formatMoney(order.shippingFee)}` : '0 ₫'}</span>
                  </div>
                  <div className="flex justify-between items-center py-1 mt-0.5">
                    <span className="font-bold text-[13px] uppercase">Khách phải trả:</span>
                    <span className="font-black text-[15px]">{formatMoney(order.totalAmount)}</span>
                  </div>
                </div>
              </div>

              {order.notes && (
                <div className="mb-4 p-1.5 border border-black bg-transparent">
                  <span className="font-bold text-[10px] uppercase">Ghi chú:</span>
                  <p className="text-[11px] italic mt-0.5 leading-tight">{order.notes}</p>
                </div>
              )}

              <div className="grid grid-cols-2 text-center pt-2 px-2 text-[11px]">
                <div>
                  <p className="font-bold uppercase mb-8">Khách Hàng</p>
                  <p className="italic text-[9.5px] text-black">(Ký & Ghi rõ họ tên)</p>
                </div>
                <div>
                  <p className="font-bold uppercase mb-8">Chữ Ký Người Bán</p>
                  <p className="italic text-[9.5px] text-black">(Ký & Ghi rõ họ tên)</p>
                </div>
              </div>
              
              <div className="text-center pt-2 mt-4 mb-2 border-t border-dashed border-black">
                <p className="font-bold text-[11px]">Xin Chân Thành Cảm Ơn Quý Khách!</p>
              </div>
            </div>

          </Card>
        </div>

        {/* RIGHT SIDEBAR */}
        <div className="xl:col-span-1 space-y-5 print:hidden">
          
          {/* Status Card */}
          <Card className="bg-white/40 backdrop-blur-3xl border border-white/40 shadow-sm shadow-black/5 rounded-[24px] overflow-hidden">
            <CardHeader className="bg-white/40 border-b border-white/40 py-3 px-4">
              <CardTitle className="text-sm font-semibold flex items-center gap-2">
                <Truck className="h-4 w-4 text-primary" />
                Trạng thái
              </CardTitle>
            </CardHeader>
            <CardContent className="p-4">
              <Select value={normalizedStatus} onValueChange={v => updateStatus(v)} disabled={isCancelled}>
                <SelectTrigger className="w-full h-10 bg-background border-input transition-shadow">
                  <SelectValue>
                    <div className="flex items-center gap-2 font-medium">
                      <span className={`w-2 h-2 rounded-full ${ORDER_STATUS_CONFIG[normalizedStatus]?.dot || 'bg-gray-500'}`}></span>
                      {getStatusLabel(normalizedStatus)}
                    </div>
                  </SelectValue>
                </SelectTrigger>
                <SelectContent className="rounded-[16px] p-2 shadow-2xl border-white/60 backdrop-blur-3xl bg-white/70">
                  {/* Luôn hiển thị trạng thái hiện tại */}
                  <SelectItem value={normalizedStatus} className="rounded-xl py-2.5 px-3 mb-1 focus:bg-white/80 focus:text-foreground last:mb-0 transition-all cursor-pointer data-[state=checked]:bg-white data-[state=checked]:shadow-sm data-[state=checked]:shadow-black/5 border border-transparent data-[state=checked]:border-white/60">
                    <div className="flex items-center gap-2">
                       <span className={`w-2 h-2 rounded-full shadow-sm ${ORDER_STATUS_CONFIG[normalizedStatus]?.dot || 'bg-gray-500'}`}></span>
                       <span className="font-semibold text-primary">{getStatusLabel(normalizedStatus)}</span>
                    </div>
                  </SelectItem>
                  {allowedTransitions.map(tr => {
                    const config = ORDER_STATUS_CONFIG[tr] || ORDER_STATUS_CONFIG['PENDING'];
                    return (
                      <SelectItem key={tr} value={tr} className="rounded-xl py-2.5 px-3 mb-1 focus:bg-white/80 focus:text-foreground last:mb-0 transition-all cursor-pointer data-[state=checked]:bg-white data-[state=checked]:shadow-sm data-[state=checked]:shadow-black/5 border border-transparent data-[state=checked]:border-white/60">
                        <div className="flex items-center gap-2">
                          <span className={`w-2 h-2 rounded-full shadow-sm ${config.dot}`}></span>
                          <span className={tr === 'COMPLETED' ? 'font-medium text-emerald-700' : tr === 'RETURNED' ? 'text-orange-600' : tr === 'CANCELLED' ? 'text-red-700' : 'font-medium'}>
                            {getStatusLabel(tr)}
                          </span>
                        </div>
                      </SelectItem>
                    );
                  })}
                </SelectContent>
              </Select>
            </CardContent>
          </Card>

          {/* Customer Info Card */}
          <Card className="bg-white/40 backdrop-blur-3xl border border-white/40 shadow-sm shadow-black/5 rounded-[24px] overflow-hidden">
            <CardHeader className="bg-white/40 border-b border-white/40 py-3 px-4 flex flex-row items-center justify-between space-y-0">
              <CardTitle className="text-sm font-semibold flex items-center gap-2">
                <User className="h-4 w-4 text-primary" />
                Thông tin Khách hàng
              </CardTitle>
              {order.customer?.group?.name && (
                <Badge variant="secondary" className="font-medium text-xs">
                  {order.customer.group.name}
                </Badge>
              )}
            </CardHeader>
            <CardContent className="p-4 space-y-3">
              <div className="flex items-center gap-3">
                <div className="h-10 w-10 rounded-full bg-primary/10 text-primary flex items-center justify-center font-bold text-base border border-primary/20 shrink-0">
                  {order.snapshotCustomerName ? order.snapshotCustomerName.charAt(0).toUpperCase() : 'K'}
                </div>
                <div className="flex flex-col min-w-0">
                  <span className="font-semibold text-foreground leading-tight truncate">{order.snapshotCustomerName}</span>
                  <div className="flex items-center gap-2 mt-1.5 text-xs">
                    <div className="p-1 rounded-md bg-primary/10 text-primary shrink-0">
                      <Phone className="h-3.5 w-3.5" />
                    </div>
                    <span className="font-semibold text-foreground/80">{order.snapshotCustomerPhone || 'Trống'}</span>
                  </div>
                </div>
              </div>

              <div className="flex flex-col gap-1.5 pt-2.5 border-t border-muted/50">
                <span className="text-[10px] font-semibold text-muted-foreground uppercase tracking-wider flex items-center gap-1">
                  <MapPin className="h-3 w-3" /> Địa chỉ giao hàng
                </span>
                <span className="text-sm text-foreground leading-snug">
                  {[order.customer?.addressDetail, order.customer?.wardName, order.customer?.provinceName].filter(Boolean).join(', ') || <span className="italic text-muted-foreground/60">Chưa cập nhật</span>}
                </span>
              </div>
            </CardContent>
          </Card>

          {/* Activity Log Card */}
          <Card className="bg-white/40 backdrop-blur-3xl border border-white/40 shadow-sm shadow-black/5 rounded-[24px] overflow-hidden">
            <CardHeader className="bg-white/40 border-b border-white/40 py-3 px-4">
              <CardTitle className="text-sm font-semibold flex items-center gap-2">
                <History className="h-4 w-4 text-primary" />
                Nhật ký đơn hàng
              </CardTitle>
            </CardHeader>
            <CardContent className="p-0">
               <div className="flex flex-col">
                 {order.auditLogs && order.auditLogs.length > 0 ? (
                   order.auditLogs.map((log) => {
                     let title = '';
                     let desc = <></>;
                     let bColor = '';
                     let tColor = '';
                     let rowBgColor = '';
                     
                     if (log.action === 'CREATE') {
                       title = 'Tạo đơn hàng';
                       desc = <><strong className="font-medium text-foreground">{log.user?.fullName || 'Hệ thống'}</strong> đã tạo đơn hàng.</>;
                       bColor = 'bg-muted/50'; tColor = 'text-foreground';
                     } else if (log.action === 'UPDATE') {
                       title = 'Cập nhật đơn hàng';
                       desc = <><strong className="font-medium text-foreground">{log.user?.fullName || 'Hệ thống'}</strong> đã chỉnh sửa thông tin đơn hàng.</>;
                       bColor = 'bg-muted/50'; tColor = 'text-foreground';
                     } else if (log.action === 'STATUS_CHANGE') {
                       const oldStatus = log.oldData?.deliveryStatus || '';
                       const newStatus = log.newData?.deliveryStatus || '';
                       title = 'Cập nhật trạng thái';
                       
                       if (newStatus === 'COMPLETED') {
                          bColor = 'bg-emerald-100/50'; tColor = 'text-emerald-800'; rowBgColor = 'bg-emerald-50/30';
                       } else if (newStatus === 'CANCELLED' || newStatus === 'RETURNED') {
                          bColor = 'bg-destructive/10'; tColor = 'text-destructive'; rowBgColor = 'bg-destructive/5';
                       } else {
                          bColor = 'bg-blue-50'; tColor = 'text-blue-700'; rowBgColor = 'bg-blue-50/10';
                       }

                       desc = <><strong className={`font-medium ${tColor}`}>{log.user?.fullName || 'Hệ thống'}</strong> đã đổi trạng thái từ <strong className="font-medium">"{getStatusLabel(oldStatus)}"</strong> sang <strong className={`font-semibold ${tColor}`}>"{getStatusLabel(newStatus)}"</strong>.</>;
                     } else {
                        title = log.action;
                        desc = <><strong className="font-medium text-foreground">{log.user?.fullName || 'Hệ thống'}</strong> đã thực hiện thao tác.</>;
                     }

                     return (
                       <div key={log.id} className={`border-b border-muted/30 last:border-0 p-4 py-3 hover:bg-muted/20 transition-colors ${rowBgColor}`}>
                         <div className="flex justify-between items-start mb-1">
                           <span className={`font-semibold text-xs flex items-center gap-1.5 ${tColor}`}>
                             <Clock className="h-3 w-3" />
                             {title}
                           </span>
                           <span className={`text-[10px] whitespace-nowrap ml-2 px-1.5 py-0.5 rounded ${bColor} ${tColor.replace('800', '600').replace('700', '600')}`}>{new Date(log.createdAt).toLocaleTimeString('vi-VN', {hour: '2-digit', minute:'2-digit'})} {new Date(log.createdAt).toLocaleDateString('vi-VN')}</span>
                         </div>
                         <p className={`text-[11px] leading-relaxed pl-[18px] ${tColor.replace('800', '700').replace('text-foreground', 'text-muted-foreground')}`}>
                           {desc}
                         </p>
                       </div>
                     );
                   })
                 ) : (
                   /* Fallback for old orders without audit logs */
                   <>
                     {/* Creation Log */}
                     <div className="border-b border-muted/30 last:border-0 p-4 py-3 hover:bg-muted/20 transition-colors">
                       <div className="flex justify-between items-start mb-1">
                         <span className="font-semibold text-foreground text-xs flex items-center gap-1.5">
                           <Clock className="h-3 w-3 text-muted-foreground" />
                           Phát sinh đơn hàng
                         </span>
                         <span className="text-[10px] text-muted-foreground whitespace-nowrap ml-2 bg-muted/50 px-1.5 py-0.5 rounded">{new Date(order.createdAt).toLocaleTimeString('vi-VN', {hour: '2-digit', minute:'2-digit'})} {new Date(order.createdAt).toLocaleDateString('vi-VN')}</span>
                       </div>
                       <p className="text-muted-foreground text-[11px] leading-relaxed pl-[18px]">
                         <strong className="text-foreground font-medium">{order.createdBy?.fullName || 'Hệ thống'}</strong> đã tạo đơn hàng mới trên hệ thống.
                       </p>
                     </div>

                     {/* Completion Log */}
                     {order.deliveryStatus === 'COMPLETED' && (
                       <div className="border-b border-muted/30 last:border-0 p-4 py-3 hover:bg-muted/20 transition-colors bg-emerald-50/30">
                         <div className="flex justify-between items-start mb-1">
                           <span className="font-semibold text-emerald-800 text-xs flex items-center gap-1.5">
                             <Clock className="h-3 w-3" />
                             Giao hàng thành công
                           </span>
                           <span className="text-[10px] text-emerald-600/70 whitespace-nowrap ml-2 bg-emerald-100/50 px-1.5 py-0.5 rounded">Gần đây</span>
                         </div>
                         <p className="text-emerald-700/80 text-[11px] leading-relaxed pl-[18px]">
                           Đơn hàng đã được đánh dấu là <strong>Hoàn thành</strong>.
                         </p>
                       </div>
                     )}

                     {/* Cancellation Log */}
                     {isCancelled && (
                       <div className="border-b border-muted/30 last:border-0 p-4 py-3 hover:bg-muted/20 transition-colors bg-destructive/5">
                         <div className="flex justify-between items-start mb-1">
                           <span className="font-semibold text-destructive/90 text-xs flex items-center gap-1.5">
                             <Clock className="h-3 w-3" />
                             Đơn hàng bị huỷ/hoàn
                           </span>
                           <span className="text-[10px] text-destructive/60 whitespace-nowrap ml-2 bg-destructive/10 px-1.5 py-0.5 rounded">Gần đây</span>
                         </div>
                         <p className="text-destructive/80 text-[11px] leading-relaxed pl-[18px]">
                           Đơn hàng đã bị huỷ bởi người dùng.
                         </p>
                       </div>
                     )}
                   </>
                 )}
               </div>
            </CardContent>
          </Card>
          
        </div>
      </div>

      {/* MODAL CANCELLATION */}
      <AlertDialog open={isCancelModalOpen} onOpenChange={(open) => !open && setIsCancelModalOpen(false)}>
        <AlertDialogContent className="glass sm:max-w-[425px] border-border/40 shadow-2xl p-6">
          <AlertDialogHeader className="flex flex-col items-center text-center space-y-4">
            <div className="w-14 h-14 rounded-full bg-amber-500/10 flex items-center justify-center shrink-0">
              <AlertCircle className="w-7 h-7 text-amber-600" />
            </div>
            <div className="space-y-2">
              <AlertDialogTitle className="text-xl font-bold text-foreground">
                Hủy đơn hàng?
              </AlertDialogTitle>
              <AlertDialogDescription className="text-foreground/80 leading-relaxed text-sm">
                Bạn đang thao tác huỷ đơn hàng <strong className="text-amber-600 font-bold">{order.orderNumber.replace("ORD-", "")}</strong> của khách hàng <span className="font-bold text-foreground">{order.snapshotCustomerName}</span>.
                <br/><br/>
                Hành động này sẽ thay đổi trạng thái và ngừng xử lý đơn hàng. Bạn vui lòng cung cấp lý do huỷ cụ thể bên dưới.
              </AlertDialogDescription>
            </div>
          </AlertDialogHeader>
          
          <div className="py-2 space-y-4 w-full">
            <div className="space-y-2 text-left">
              <label className="text-sm font-semibold leading-none text-foreground">
                Lý do huỷ <span className="text-destructive">*</span>
              </label>
              <Select value={selectedCancelReasonId} onValueChange={(v) => setSelectedCancelReasonId(v ?? '')}>
                <SelectTrigger className="w-full">
                  <SelectValue placeholder="-- Chọn lý do --">
                    {selectedCancelReasonId 
                      ? cancelReasons.find(r => r.id === selectedCancelReasonId)?.label 
                      : "-- Chọn lý do --"}
                  </SelectValue>
                </SelectTrigger>
                <SelectContent>
                  {cancelReasons.map(r => (
                    <SelectItem key={r.id} value={r.id}>{r.label}</SelectItem>
                  ))}
                  {cancelReasons.length === 0 && <SelectItem value="custom" disabled>Chưa có lý do nào được cài đặt...</SelectItem>}
                </SelectContent>
              </Select>
            </div>
            
            <div className="space-y-2 text-left">
              <label className="text-sm font-semibold leading-none text-foreground">
                Ghi chú thêm <span className="text-muted-foreground font-normal whitespace-nowrap ml-1">(Tuỳ chọn)</span>
              </label>
              <textarea 
                className="flex min-h-[80px] w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2" 
                placeholder="Nhập thêm chi tiết nguyên nhân huỷ đơn..."
                value={cancelNotes}
                onChange={e => setCancelNotes(e.target.value)}
              />
            </div>
          </div>

          <AlertDialogFooter className="sm:justify-center flex-row gap-3 pt-4 w-full">
            <AlertDialogCancel className="flex-1 text-foreground font-semibold hover:bg-muted/50 border border-border/60 bg-white/50 m-0 shadow-sm transition-all" disabled={isSaving}>
              Hủy bỏ
            </AlertDialogCancel>
            <Button 
               variant="default" 
               className="flex-1 bg-amber-600 text-white hover:bg-amber-700 shadow-[0_0_15px_rgba(217,119,6,0.25)] hover:shadow-[0_0_20px_rgba(217,119,6,0.4)] transition-all duration-300 m-0"
               disabled={!selectedCancelReasonId || isSaving} 
               onClick={() => { 
                 updateStatus('CANCELLED', { cancelReasonId: selectedCancelReasonId, cancelNotes }); 
                 setIsCancelModalOpen(false); 
               }}
            >
              {isSaving ? (
                <span className="flex items-center gap-2">
                  <Loader2 className="w-4 h-4 animate-spin" /> Xử lý...
                </span>
              ) : 'Xác nhận Hủy Đơn'}
            </Button>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>

      {/* MODAL DELETE */}
      <AlertDialog open={isDeleteModalOpen} onOpenChange={(open) => !open && setIsDeleteModalOpen(false)}>
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
                Bạn đang thao tác xoá đơn hàng <strong className="text-red-700 font-bold">{order.orderNumber.replace("ORD-", "")}</strong> của khách hàng <span className="font-bold text-foreground">{order.snapshotCustomerName}</span>.
                <br/><br/>
                Toàn bộ dữ liệu của đơn này sẽ xoá khỏi hệ thống và <strong className="text-foreground font-semibold">không thể khôi phục</strong>.
              </AlertDialogDescription>
            </div>
          </AlertDialogHeader>
          <AlertDialogFooter className="sm:justify-center flex-row gap-3 pt-6 w-full">
            <AlertDialogCancel className="flex-1 text-foreground font-semibold hover:bg-muted/50 border border-border/60 bg-white/50 m-0 shadow-sm transition-all" disabled={isSaving}>
              Hủy bỏ
            </AlertDialogCancel>
            <AlertDialogAction onClick={() => { handleDeleteOrder(); setIsDeleteModalOpen(false); }} className="flex-1 bg-red-700 text-white hover:bg-red-800 shadow-[0_0_15px_rgba(185,28,28,0.25)] hover:shadow-[0_0_20px_rgba(185,28,28,0.4)] transition-all duration-300 m-0" disabled={isSaving}>
              {isSaving ? (
                <span className="flex items-center gap-2">
                  <Loader2 className="w-4 h-4 animate-spin" /> Khai tử...
                </span>
              ) : 'Xác nhận Xóa'}
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}
