'use client';

import { useState, useEffect } from 'react';
import { ordersApi, settingsApi, Order, CompanySettings } from '@/lib/api';
import { useAuth } from '@/lib/auth-context';
import { useParams, useRouter } from 'next/navigation';
import { Button } from '@/components/ui/button';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { ArrowLeft, Printer, AlertTriangle, Truck, ShieldAlert, Pencil, History, Phone, MapPin, User, Package, FileText, Clock } from 'lucide-react';
import { Badge } from '@/components/ui/badge';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import Link from 'next/link';
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
import { AlertCircle } from 'lucide-react';

export default function OrderDetailPage() {
  const { id } = useParams();
  const router = useRouter();
  const { getToken } = useAuth();
  
  const [order, setOrder] = useState<Order | null>(null);
  const [company, setCompany] = useState<CompanySettings | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);
  const [isCancelModalOpen, setIsCancelModalOpen] = useState(false);

  useEffect(() => {
    fetchDetail();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [id]);

  const fetchDetail = async () => {
    try {
      setIsLoading(true);
      const [orderRes, companyRes] = await Promise.all([
        ordersApi.getOrder(getToken()!, id as string),
        settingsApi.getCompanySettings(getToken()!).catch(() => null)
      ]);
      setOrder(orderRes);
      if (companyRes) setCompany(companyRes);
    } catch (err: any) {
      toast.error(err.message || 'Không kết nối được dữ liệu hoá đơn.');
      router.push('/orders');
    } finally {
      setIsLoading(false);
    }
  };

  const updateStatus = async (val: string | null) => {
    if (!val) return;
    try {
      setIsSaving(true);
      await ordersApi.updateStatus(getToken()!, id as string, {
        deliveryStatus: val
      });
      toast.success('Cập nhật trạng thái thành công.');
      fetchDetail();
    } catch (e: any) {
      toast.error(e.message || 'Không thể thao tác lúc này.');
    } finally {
      setIsSaving(false);
    }
  };

  const handlePrint = () => {
    window.print();
  };

  const formatMoney = (amount: number) => new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(amount);

  const getStatusBadge = (status: string) => {
    switch (status) {
      case 'PENDING': return <Badge variant="outline" className="bg-yellow-50 text-yellow-700 border-yellow-200 shadow-sm px-3 py-1">Đang xử lý</Badge>;
      case 'PROCESSING': return <Badge variant="outline" className="bg-orange-50 text-orange-700 border-orange-200 shadow-sm px-3 py-1">Đang giao</Badge>;
      case 'SHIPPING': return <Badge variant="outline" className="bg-blue-50 text-blue-700 border-blue-200 shadow-sm px-3 py-1">Đã giao</Badge>;
      case 'COMPLETED': return <Badge variant="outline" className="bg-emerald-50 text-emerald-700 border-emerald-200 shadow-sm px-3 py-1">Hoàn thành</Badge>;
      case 'CANCELLED': return <Badge variant="destructive" className="shadow-sm px-3 py-1">Huỷ</Badge>;
      case 'RETURNED': return <Badge variant="outline" className="bg-red-50 text-red-700 border-red-200 shadow-sm px-3 py-1">Hoàn trả</Badge>;
      default: return <Badge variant="outline" className="shadow-sm px-3 py-1">{status}</Badge>;
    }
  };

  const getStatusLabel = (status: string) => {
    const s = (status || '').toUpperCase();
    const map: Record<string, string> = {
      'PENDING': 'Đang xử lý',
      'PROCESSING': 'Đang giao',
      'SHIPPING': 'Đã giao',
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
  const totalDiscount = Number(order.discountAmount || 0) + (order.items?.reduce((sum, item) => sum + Number(item.lineDiscount || 0), 0) || 0);

  return (
    <div className="flex flex-col gap-6 pb-8">
      {/* HEADER SECTION */}
      <div className="flex items-center gap-4 print:hidden">
        <Link href="/orders" className="inline-flex items-center justify-center whitespace-nowrap rounded-md text-sm font-medium transition-colors border border-input bg-background hover:bg-muted h-10 w-10 shadow-sm">
          <ArrowLeft className="h-5 w-5 text-muted-foreground" />
        </Link>
        <div className="flex-1 min-w-0">
          <h1 className="text-3xl font-bold tracking-tight text-foreground flex items-center gap-3">
            Hóa đơn {order.orderNumber}
            {getStatusBadge(normalizedStatus)}
          </h1>
          <p className="text-sm text-muted-foreground mt-1">
            Ngày lập: {new Date(order.createdAt).toLocaleString('vi-VN')} <span className="mx-1">•</span> Thu ngân: {order.createdBy?.fullName || 'Hệ thống'}
          </p>
        </div>
        <div className="flex gap-3 shrink-0">
          {normalizedStatus === 'PENDING' && (
            <Link href={`/orders/${id}/edit`} tabIndex={-1}>
              <Button variant="outline" className="shadow-sm font-medium hover:text-primary">
                <Pencil className="mr-2 h-4 w-4" /> Chỉnh sửa
              </Button>
            </Link>
          )}
          {!isCancelled && (
              <Button variant="outline" onClick={() => setIsCancelModalOpen(true)} className="shadow-sm text-destructive hover:bg-destructive hover:text-destructive-foreground transition-colors">
                <ShieldAlert className="mr-2 h-4 w-4" /> Huỷ đơn hàng
              </Button>
          )}
          <Button onClick={handlePrint} className="shadow-md hover:shadow-lg transition-all duration-200 font-semibold px-5">
            <Printer className="mr-2 h-5 w-5" /> In Hoá Đơn
          </Button>
        </div>
      </div>

      {isCancelled && (
        <div className="p-4 bg-destructive/10 text-destructive text-sm rounded-xl flex items-center gap-3 print:hidden border border-destructive/20 shadow-sm">
          <AlertTriangle className="h-5 w-5 shrink-0" />
          <span className="leading-relaxed">Đơn hàng đã bị <strong>HUỶ</strong> hoặc <strong>HOÀN</strong>. Tồn kho của các sản phẩm trong đơn đã được tự động cộng lại vào hệ thống.</span>
        </div>
      )}

      {/* CONTENT GRID */}
      <div className="grid grid-cols-1 xl:grid-cols-3 gap-6 print:block">
        
        {/* LEFT: Order Items */}
        <div className="xl:col-span-2 print:col-span-3">
          <Card className="glass shadow-sm border-muted/50 overflow-hidden print:shadow-none print:border-none print:bg-transparent">
            <CardHeader className="bg-muted/30 border-b py-4 print:hidden flex flex-row items-center justify-between px-6">
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
                    <TableHead className="px-6 text-foreground font-semibold">Sản phẩm</TableHead>
                    <TableHead className="px-3 text-foreground font-semibold text-center w-[70px]">ĐVT</TableHead>
                    <TableHead className="px-3 text-foreground font-semibold text-center w-[60px]">SL</TableHead>
                    <TableHead className="px-4 text-foreground font-semibold text-right w-[110px]">Đơn giá</TableHead>
                    <TableHead className="px-4 text-foreground font-semibold text-right w-[110px]">Chiết khấu</TableHead>
                    <TableHead className="px-6 text-foreground font-semibold text-right w-[120px]">Thành tiền</TableHead>
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
                  <div className="w-full md:w-72 space-y-2">
                    <div className="flex justify-between text-sm text-muted-foreground">
                      <span>Tạm tính:</span>
                      <span className="font-semibold text-foreground">{formatMoney(order.subtotal)}</span>
                    </div>
                    <div className="flex justify-between text-sm text-muted-foreground">
                      <span>Phí vận chuyển:</span>
                      <span className="font-semibold text-foreground">{order.shippingFee > 0 ? '+' : ''} {formatMoney(order.shippingFee)}</span>
                    </div>
                    {totalDiscount > 0 ? (
                      <div className="flex justify-between text-sm text-muted-foreground border-b border-border/50 pb-3">
                        <span>Chiết khấu:</span>
                        <span className="font-semibold text-destructive">- {formatMoney(totalDiscount)}</span>
                      </div>
                    ) : (
                      <div className="flex justify-between text-sm text-muted-foreground border-b border-border/50 pb-3">
                        <span>Chiết khấu:</span>
                        <span className="font-semibold text-foreground">0 ₫</span>
                      </div>
                    )}
                    <div className="flex justify-between font-bold items-center pt-1">
                      <span className="text-base text-foreground">Tổng:</span>
                      <span className="text-2xl text-primary">{formatMoney(order.totalAmount)}</span>
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
                  body { background: white !important; padding: 0 !important; margin: 0 !important; -webkit-print-color-adjust: exact; print-color-adjust: exact; }
                  
                  /* Hide all UI elements except the receipt */
                  body * { visibility: hidden; }
                  #pos-receipt, #pos-receipt * { visibility: visible; }
                  
                  /* Rip the receipt out of the layout flow completely */
                  #pos-receipt { 
                    position: absolute !important; 
                    left: 0 !important; 
                    top: 0 !important; 
                    width: 100% !important; 
                    margin: 0 !important;
                    padding: 0 !important;
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

                <div className="flex gap-1">
                  <span className="font-semibold min-w-[55px]">Giao tới:</span>
                  <span className="w-full">{[order.customer?.addressDetail, order.customer?.wardName, order.customer?.provinceName].filter(Boolean).join(', ') || 'Mua trực tiếp tại quầy'}</span>
                </div>
              </div>

              <table className="w-full text-[11px] xl:text-[12px] mb-4 border-collapse border border-black/50">
                <thead className="bg-gray-100/50">
                  <tr>
                    <th className="border border-black/50 text-center py-1 font-bold w-[6%]">STT</th>
                    <th className="border border-black/50 text-left py-1 font-bold px-1.5">Tên hàng / Dịch vụ</th>
                    <th className="border border-black/50 text-center py-1 font-bold w-[10%]">SL</th>
                    <th className="border border-black/50 text-right py-1 font-bold px-1.5 w-[16%]">Đơn giá</th>
                    <th className="border border-black/50 text-right py-1 font-bold px-1.5 w-[20%]">Thành tiền</th>
                  </tr>
                </thead>
                <tbody>
                  {order.items?.map((item, idx) => (
                    <tr key={idx}>
                      <td className="border border-black/50 text-center py-1 px-1">{idx + 1}</td>
                      <td className="border border-black/50 text-left py-1 px-1.5">
                        <div className="font-semibold leading-tight">{item.snapshotProductName}</div>
                        {item.lineDiscount > 0 && <div className="text-[9.5px] italic text-black/70 leading-tight">- CK: {formatMoney(item.lineDiscount)}/SP</div>}
                      </td>
                      <td className="border border-black/50 text-center py-1 font-semibold px-1">{item.quantity}</td>
                      <td className="border border-black/50 text-right py-1 px-1.5">{formatMoney(item.snapshotUnitPrice)}</td>
                      <td className="border border-black/50 text-right py-1 font-bold px-1.5">{formatMoney(item.lineTotal)}</td>
                    </tr>
                  ))}
                </tbody>
              </table>

              <div className="flex justify-end mb-4 text-[11px] xl:text-[12px]">
                <div className="w-[50%]">
                  <div className="flex justify-between items-center py-0.5">
                    <span className="font-semibold">Cộng tiền hàng:</span>
                    <span>{formatMoney(order.subtotal)}</span>
                  </div>
                  {totalDiscount > 0 && (
                    <div className="flex justify-between items-center py-0.5">
                      <span className="font-semibold">Trừ chiết khấu:</span>
                      <span>- {formatMoney(totalDiscount)}</span>
                    </div>
                  )}
                  {order.shippingFee > 0 && (
                    <div className="flex justify-between items-center py-0.5 border-b border-black/20 pb-1">
                      <span className="font-semibold">Phí vận chuyển:</span>
                      <span>+ {formatMoney(order.shippingFee)}</span>
                    </div>
                  )}
                  <div className="flex justify-between items-center py-1 mt-0.5">
                    <span className="font-bold text-[13px] uppercase">Tổng cộng:</span>
                    <span className="font-black text-[15px]">{formatMoney(order.totalAmount)}</span>
                  </div>
                </div>
              </div>

              {order.notes && (
                <div className="mb-4 p-1.5 border border-black/30 bg-gray-50/50">
                  <span className="font-bold text-[10px] uppercase">Ghi chú:</span>
                  <p className="text-[11px] italic mt-0.5 leading-tight">{order.notes}</p>
                </div>
              )}

              <div className="grid grid-cols-2 text-center pt-2 px-2 text-[11px]">
                <div>
                  <p className="font-bold uppercase mb-8">Khách Hàng</p>
                  <p className="italic text-[9.5px] text-gray-500">(Ký & Ghi rõ họ tên)</p>
                </div>
                <div>
                  <p className="font-bold uppercase mb-8">Chữ Ký Người Bán</p>
                  <p className="italic text-[9.5px] text-gray-500">(Ký & Ghi rõ họ tên)</p>
                </div>
              </div>
              
              <div className="text-center pt-2 mt-4 mb-2 border-t border-dashed border-black/30">
                <p className="font-bold text-[11px]">Xin Chân Thành Cảm Ơn Quý Khách!</p>
              </div>
            </div>

          </Card>
        </div>

        {/* RIGHT SIDEBAR */}
        <div className="xl:col-span-1 space-y-5 print:hidden">
          
          {/* Status Card */}
          <Card className="glass shadow-sm border-muted/50 overflow-hidden">
            <CardHeader className="bg-muted/30 border-b py-3 px-4">
              <CardTitle className="text-sm font-semibold flex items-center gap-2">
                <Truck className="h-4 w-4 text-primary" />
                Trạng thái
              </CardTitle>
            </CardHeader>
            <CardContent className="p-4">
              <Select value={normalizedStatus} onValueChange={v => updateStatus(v)} disabled={isCancelled}>
                <SelectTrigger className="w-full h-10 bg-background border-input transition-shadow">
                  <SelectValue>{getStatusLabel(normalizedStatus)}</SelectValue>
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="PENDING" className="py-2 cursor-pointer">Đang xử lý</SelectItem>
                  <SelectItem value="PROCESSING" className="py-2 cursor-pointer">Đang giao</SelectItem>
                  <SelectItem value="SHIPPING" className="py-2 cursor-pointer">Đã giao</SelectItem>
                  <SelectItem value="COMPLETED" className="py-2 cursor-pointer font-medium text-emerald-700">Hoàn thành</SelectItem>
                  <SelectItem value="RETURNED" className="py-2 cursor-pointer text-orange-600">Hoàn trả</SelectItem>
                  <SelectItem value="CANCELLED" disabled className="py-2">Huỷ</SelectItem>
                </SelectContent>
              </Select>
            </CardContent>
          </Card>

          {/* Customer Info Card */}
          <Card className="glass shadow-sm border-muted/50 overflow-hidden">
            <CardHeader className="bg-muted/30 border-b py-3 px-4 flex flex-row items-center justify-between space-y-0">
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
                  <div className="flex items-center gap-1.5 text-primary font-medium text-xs mt-0.5">
                    <Phone className="h-3 w-3" />
                    {order.snapshotCustomerPhone}
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
          <Card className="glass shadow-sm border-muted/50 overflow-hidden">
            <CardHeader className="bg-muted/30 border-b py-3 px-4">
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
                           Đơn hàng đã bị huỷ và tồn kho đã được phục hồi.
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
        <AlertDialogContent className="glass sm:max-w-[425px]">
          <AlertDialogHeader>
            <AlertDialogTitle className="flex items-center text-destructive">
              <AlertCircle className="w-5 h-5 mr-2" />
              Hủy đơn hàng?
            </AlertDialogTitle>
            <AlertDialogDescription className="text-foreground/80">
              Bạn có chắc chắn muốn hủy đơn hàng này không? Sau khi chuyển trạng thái thành Hủy, hệ thống sẽ tự động hoàn trả số lượng dự trữ vào quỹ tồn kho. Hành động này không thể hoàn tác.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel className="hover:bg-muted/50 border-0 bg-transparent shadow-none">
              Hủy bỏ
            </AlertDialogCancel>
            <AlertDialogAction onClick={() => { updateStatus('CANCELLED'); setIsCancelModalOpen(false); }} className="bg-destructive text-destructive-foreground hover:bg-destructive/90">
              Xác nhận Hủy Đơn
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}
