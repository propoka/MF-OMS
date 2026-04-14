'use client';

import { useState, useEffect, useCallback } from 'react';
import { dashboardApi, settingsApi, Order, CompanySettings } from '@/lib/api';
import { useAuth } from '@/lib/auth-context';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { Badge } from '@/components/ui/badge';
import { FileDown, Printer, Calendar as CalendarIcon, Loader2, RefreshCw, BarChart3, TrendingDown, Truck, Activity, Target, Percent, PackageOpen, Award } from 'lucide-react';
import * as xlsx from 'xlsx';
import { toast } from 'sonner';

const getStatusBadgeVariant = (status: string) => {
  switch (status) {
    case 'COMPLETED': return 'bg-emerald-100 text-emerald-700 border-emerald-200';
    case 'CANCELLED': return 'bg-red-100 text-red-700 border-red-200';
    case 'RETURNED': return 'bg-orange-100 text-orange-700 border-orange-200';
    case 'SHIPPING': return 'bg-blue-100 text-blue-700 border-blue-200';
    case 'PROCESSING': return 'bg-indigo-100 text-indigo-700 border-indigo-200';
    case 'PENDING': default: return 'bg-gray-100 text-gray-700 border-gray-200';
  }
};

const formatStatusText = (status: string) => {
  switch (status) {
    case 'COMPLETED': return 'Hoàn thành';
    case 'CANCELLED': return 'Đã Huỷ';
    case 'RETURNED': return 'Hoàn Trả';
    case 'SHIPPING': return 'Đang Giao';
    case 'PROCESSING': return 'Đang Xử Lý';
    case 'PENDING': default: return 'Chờ Xác Nhận';
  }
};

export default function ReportsPage() {
  const { getToken } = useAuth();
  
  // Date State
  const [startDate, setStartDate] = useState<string>('');
  const [endDate, setEndDate] = useState<string>('');

  // Data State
  const [reportData, setReportData] = useState<{
    summary: { 
      totalOrders: number; 
      completedOrdersCount: number; 
      grossRevenue: number; 
      netRevenue: number; 
      totalShippingFee: number; 
      totalDiscount: number; 
      aov: number; 
      cancelRate: number; 
    };
    overview: {
      statusBreakdown: Record<string, { count: number; revenue: number }>;
      topCustomers: { name: string; phone: string; revenue: number; orderCount: number }[];
      topProducts: { name: string; sku: string; revenue: number; sold: number }[];
    };
    orders: Order[];
  } | null>(null);
  
  const [company, setCompany] = useState<CompanySettings | null>(null);
  const [isLoading, setIsLoading] = useState(false);

  useEffect(() => {
    // init 30 days
    handlePreset('30days');
    fetchCompany();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const fetchCompany = async () => {
    try {
      const token = getToken();
      if (!token) return;
      const res = await settingsApi.getCompanySettings(token).catch(()=>null);
      if(res) setCompany(res);
    } catch {}
  };

  const fetchReport = useCallback(async (start?: string, end?: string) => {
    try {
      setIsLoading(true);
      const s = start !== undefined ? start : startDate;
      const e = end !== undefined ? end : endDate;
      
      const token = getToken();
      if (!token) return;
      const res = await dashboardApi.getReport(token, s, e);
      setReportData(res);
    } catch (err: any) {
      toast.error(err.message || 'Lỗi tải báo cáo');
    } finally {
      setIsLoading(false);
    }
  }, [getToken, startDate, endDate]);

  const handlePreset = (type: string) => {
    const todayDate = new Date();
    let s = new Date();
    let e = new Date();

    switch (type) {
      case 'today':
        break; // today already
      case 'yesterday':
        s.setDate(todayDate.getDate() - 1);
        e.setDate(todayDate.getDate() - 1);
        break;
      case '7days':
        s.setDate(todayDate.getDate() - 6);
        break;
      case '30days':
        s.setDate(todayDate.getDate() - 29);
        break;
      case 'thisMonth':
        s = new Date(todayDate.getFullYear(), todayDate.getMonth(), 1);
        break;
      case 'lastMonth':
        s = new Date(todayDate.getFullYear(), todayDate.getMonth() - 1, 1);
        e = new Date(todayDate.getFullYear(), todayDate.getMonth(), 0);
        break;
    }

    const startStr = s.toISOString().slice(0,10);
    const endStr = e.toISOString().slice(0,10);
    setStartDate(startStr);
    setEndDate(endStr);
    fetchReport(startStr, endStr);
  };

  const formatMoney = (amount: number) => {
    return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(amount);
  };

  const exportExcel = () => {
    if (!reportData || !reportData.orders) return;
    
    // Sheet 1: Summary
    const summaryData = [
      { 'Mục': 'Khoảng thời gian', 'Giá trị': `${startDate || 'Tất cả'} đến ${endDate || 'Tất cả'}` },
      { 'Mục': 'Tổng Doanh Thu Gộp (Gross)', 'Giá trị': reportData.summary.grossRevenue || 0 },
      { 'Mục': 'Doanh Thu Thực Nhận (Net)', 'Giá trị': reportData.summary.netRevenue || 0 },
      { 'Mục': 'Tổng Số Đơn Hàng', 'Giá trị': reportData.summary.totalOrders || 0 },
      { 'Mục': 'Giá Trị Tiêu Dùng Trung Bình (AOV)', 'Giá trị': reportData.summary.aov || 0 },
      { 'Mục': 'Tỷ Lệ Huỷ / Hoàn (%)', 'Giá trị': (reportData.summary.cancelRate || 0).toFixed(2) },
      { 'Mục': 'Tổng Phí Vận Chuyển', 'Giá trị': reportData.summary.totalShippingFee },
      { 'Mục': 'Tổng Chiết Khấu / Giảm giá', 'Giá trị': reportData.summary.totalDiscount },
    ];
    
    const statusDataArray = Object.keys(reportData.overview?.statusBreakdown || {}).map(k => ({
      'Trạng thái': formatStatusText(k),
      'Số lượng': reportData.overview.statusBreakdown[k].count,
      'Doanh thu tương ứng': reportData.overview.statusBreakdown[k].revenue
    }));

    // Sheet 3: Details (Order Lines - Flattened by Products)
    const detailsData: any[] = [];
    reportData.orders.forEach(o => {
      if (!o.items || o.items.length === 0) {
        // Fallback for orders without items
        detailsData.push({
          'Mã Đơn': o.orderNumber,
          'Ngày tạo': new Date(o.createdAt).toLocaleString('vi-VN'),
          'Trạng thái': formatStatusText(o.deliveryStatus),
          'Khách hàng': o.snapshotCustomerName,
          'SĐT': o.snapshotCustomerPhone,
          'Nhóm khách': o.customer?.group?.name || 'Khách lẻ',
          'SKU': '',
          'Tên SP': '',
          'SL': 0,
          'Đơn giá bán': 0,
          'Chiết khấu dòng': 0,
          'Thành Tiền Dòng': 0,
          'Tổng tiền Hàng (Đơn)': o.subtotal,
          'Chiết khấu Đơn': o.discountAmount,
          'Phí Ship': o.shippingFee,
          'Thực thu': o.totalAmount,
          'Thu ngân': o.createdBy?.fullName || '',
          'Ghi chú': o.notes || ''
        });
      } else {
        o.items.forEach(i => {
          detailsData.push({
            'Mã Đơn': o.orderNumber,
            'Ngày tạo': new Date(o.createdAt).toLocaleString('vi-VN'),
            'Trạng thái': formatStatusText(o.deliveryStatus),
            'Khách hàng': o.snapshotCustomerName,
            'SĐT': o.snapshotCustomerPhone,
            'Nhóm khách': o.customer?.group?.name || 'Khách lẻ',
            'SKU': i.snapshotProductSku,
            'Tên SP': i.snapshotProductName,
            'SL': i.quantity,
            'Đơn giá bán': i.snapshotUnitPrice,
            'Chiết khấu dòng': i.lineDiscount,
            'Thành Tiền Dòng': i.lineTotal,
            'Tổng tiền Hàng (Đơn)': o.subtotal,
            'Chiết khấu Đơn': o.discountAmount,
            'Phí Ship': o.shippingFee,
            'Thực thu': o.totalAmount,
            'Thu ngân': o.createdBy?.fullName || '',
            'Ghi chú': o.notes || ''
          });
        });
      }
    });

    const wb = xlsx.utils.book_new();
    const ws1 = xlsx.utils.json_to_sheet(summaryData);
    const ws2 = xlsx.utils.json_to_sheet(statusDataArray);
    const ws3 = xlsx.utils.json_to_sheet(detailsData);

    // Apply auto-width for some columns
    ws3['!cols'] = [{wch: 15}, {wch: 20}, {wch: 15}, {wch: 20}, {wch: 15}, {wch: 15}, {wch: 12}, {wch: 30}];

    xlsx.utils.book_append_sheet(wb, ws1, '1. Summary');
    xlsx.utils.book_append_sheet(wb, ws2, '2. Order Overview');
    xlsx.utils.book_append_sheet(wb, ws3, '3. Order Details');

    xlsx.writeFile(wb, `BaoCao_ERP_${startDate}_${endDate}.xlsx`);
    toast.success('Đã tải xuống file Excel phân tích đa chiều.');
  };

  const exportPdf = () => {
    window.print();
  };

  return (
    <div className="w-full">
      {/* =========================================================================
          MAIN APPLICATION LAYOUT (HIDDEN DURING PRINT)
          ========================================================================= */}
      <div className="flex flex-col gap-6 pb-10 print:hidden">
        {/* HEADER SECTION */}
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
          <div>
            <h1 className="text-3xl font-bold tracking-tight text-foreground flex items-center gap-2">
              <BarChart3 className="h-8 w-8 text-primary shadow-sm rounded-lg border bg-background p-1.5" />
              Báo cáo Quản trị Doanh thu
            </h1>
            <p className="text-sm text-muted-foreground mt-1">Hệ thống phân tích B2B (Dữ liệu giao hàng, tỷ lệ chuyển đổi, danh sách chi tiết).</p>
          </div>
          <div className="flex gap-3">
            <Button variant="outline" onClick={exportExcel} disabled={isLoading || !reportData} className="shadow-sm hover:bg-emerald-50 hover:text-emerald-700 bg-background hover:border-emerald-200 transition-colors cursor-pointer">
              <FileDown className="mr-2 h-4 w-4" /> Export Excel
            </Button>
            <Button onClick={exportPdf} disabled={isLoading || !reportData} className="shadow-md hover:shadow-lg font-semibold px-6 cursor-pointer">
              <Printer className="mr-2 h-4 w-4" /> Export PDF
            </Button>
          </div>
        </div>

      {/* FILTER PANEL */}
      <Card className="glass shadow-sm border-muted/50 print:hidden overflow-hidden">
        <CardContent className="p-4 flex flex-col md:flex-row gap-4 items-end bg-muted/10">
          <div className="flex-1 w-full flex flex-col md:flex-row gap-4">
            <div className="space-y-1.5 flex-1">
              <Label className="text-xs font-semibold text-muted-foreground uppercase tracking-wider">Từ ngày</Label>
              <div className="relative">
                <CalendarIcon className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                <Input type="date" value={startDate} onChange={e => setStartDate(e.target.value)} className="pl-9 h-10 bg-background" />
              </div>
            </div>
            <div className="space-y-1.5 flex-1">
              <Label className="text-xs font-semibold text-muted-foreground uppercase tracking-wider">Đến ngày</Label>
              <div className="relative">
                <CalendarIcon className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                <Input type="date" value={endDate} onChange={e => setEndDate(e.target.value)} className="pl-9 h-10 bg-background" />
              </div>
            </div>
          </div>
          
          <div className="flex gap-2">
            <Button variant="secondary" onClick={() => fetchReport()} disabled={isLoading} className="h-10 px-5 shadow-sm min-w-[120px]">
              {isLoading ? <Loader2 className="h-4 w-4 animate-spin mx-auto" /> : <><RefreshCw className="h-4 w-4 mr-2" /> Trích xuất</>}
            </Button>
          </div>
        </CardContent>
        <div className="px-4 py-3 border-t bg-muted/5 flex flex-wrap gap-2 text-sm justify-between items-center">
            <span className="text-xs font-medium text-muted-foreground mr-2 shrink-0">Lọc nhanh:</span>
            <div className="flex flex-wrap gap-2 flex-1">
              <Button variant="outline" size="sm" onClick={() => handlePreset('today')} className="h-7 text-xs rounded-full">Hôm nay</Button>
              <Button variant="outline" size="sm" onClick={() => handlePreset('yesterday')} className="h-7 text-xs rounded-full">Hôm qua</Button>
              <Button variant="outline" size="sm" onClick={() => handlePreset('7days')} className="h-7 text-xs rounded-full">7 ngày qua</Button>
              <Button variant="outline" size="sm" onClick={() => handlePreset('30days')} className="h-7 text-xs rounded-full">30 ngày qua</Button>
              <Button variant="outline" size="sm" onClick={() => handlePreset('thisMonth')} className="h-7 text-xs rounded-full">Tháng này</Button>
              <Button variant="outline" size="sm" onClick={() => handlePreset('lastMonth')} className="h-7 text-xs rounded-full">Tháng trước</Button>
            </div>
        </div>
      </Card>

      {/* KPI SUMMARY CARDS */}
      {reportData && (
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 print:hidden">
          <Card className="shadow-sm border-muted/60 relative overflow-hidden">
             <div className="absolute top-0 right-0 p-3 opacity-10"><Activity className="h-12 w-12" /></div>
            <CardContent className="p-4">
              <span className="text-[11px] font-semibold text-muted-foreground uppercase tracking-wider mb-1 block">Doanh Thu Gộp (Gross)</span>
              <span className="text-xl font-bold text-foreground">{formatMoney(reportData.summary.grossRevenue || 0)}</span>
            </CardContent>
          </Card>
          
          <Card className="shadow-sm border-muted/60 relative overflow-hidden bg-primary/5 border-primary/20">
             <div className="absolute top-0 right-0 p-3 opacity-10 text-primary"><Target className="h-12 w-12" /></div>
            <CardContent className="p-4">
              <span className="text-[11px] font-semibold text-primary uppercase tracking-wider mb-1 block">Thực Nhận (Net - Đã chốt)</span>
              <span className="text-xl font-black text-primary">{formatMoney(reportData.summary.netRevenue || 0)}</span>
            </CardContent>
          </Card>

          <Card className="shadow-sm border-muted/60 relative overflow-hidden">
             <div className="absolute top-0 right-0 p-3 opacity-10"><Truck className="h-12 w-12" /></div>
            <CardContent className="p-4">
              <span className="text-[11px] font-semibold text-muted-foreground uppercase tracking-wider mb-1 block">Tổng Thu Phí Ship</span>
              <span className="text-xl font-bold text-foreground">+{formatMoney(reportData.summary.totalShippingFee)}</span>
            </CardContent>
          </Card>

          <Card className="shadow-sm border-muted/60 relative overflow-hidden">
             <div className="absolute top-0 right-0 p-3 opacity-10 text-destructive"><TrendingDown className="h-12 w-12" /></div>
            <CardContent className="p-4">
              <span className="text-[11px] font-semibold text-muted-foreground uppercase tracking-wider mb-1 block">Tổng Chiết Khấu</span>
              <span className="text-xl font-bold text-destructive">-{formatMoney(reportData.summary.totalDiscount)}</span>
            </CardContent>
          </Card>

          <Card className="shadow-sm border-muted/60 relative overflow-hidden">
             <div className="absolute top-0 right-0 p-3 opacity-10"><PackageOpen className="h-12 w-12" /></div>
            <CardContent className="p-4">
              <span className="text-[11px] font-semibold text-muted-foreground uppercase tracking-wider mb-1 block">Đơn Hàng Tổng Kho</span>
              <div className="flex items-baseline gap-1.5">
                <span className="text-xl font-bold text-foreground">{reportData.summary.totalOrders}</span>
              </div>
            </CardContent>
          </Card>
          
          <Card className="shadow-sm border-muted/60 relative overflow-hidden">
             <div className="absolute top-0 right-0 p-3 opacity-10 text-emerald-600"><Award className="h-12 w-12" /></div>
            <CardContent className="p-4">
              <span className="text-[11px] font-semibold text-emerald-700 uppercase tracking-wider mb-1 block">Tỷ Lệ Chốt Đơn (Hoàn thành)</span>
              <div className="flex items-baseline gap-1.5">
                <span className="text-xl font-bold text-emerald-600">{reportData.summary.completedOrdersCount}</span>
                <span className="text-sm font-medium text-muted-foreground">đơn</span>
              </div>
            </CardContent>
          </Card>

           <Card className="shadow-sm border-muted/60">
            <CardContent className="p-4">
              <span className="text-[11px] font-semibold text-muted-foreground uppercase tracking-wider mb-1 block">AOV (Trung bình / Đơn)</span>
              <span className="text-xl font-bold text-foreground">{formatMoney(reportData.summary.aov || 0)}</span>
            </CardContent>
          </Card>

           <Card className="shadow-sm border-muted/60 relative overflow-hidden">
             <div className="absolute top-0 right-0 p-3 opacity-10 text-destructive"><Percent className="h-12 w-12" /></div>
            <CardContent className="p-4">
              <span className="text-[11px] font-semibold text-muted-foreground uppercase tracking-wider mb-1 block">Tỷ Lệ Huỷ / Hoàn trả</span>
              <div className="flex items-baseline gap-1.5">
                <span className="text-xl font-bold text-destructive">{(reportData.summary.cancelRate || 0).toFixed(1)}%</span>
              </div>
            </CardContent>
          </Card>
        </div>
      )}

      {/* OVERVIEW SECTION */}
      {reportData && (
        <Card className="glass shadow-sm border-muted/50 overflow-hidden print:hidden">
          <CardHeader className="bg-muted/10 border-b py-3 px-5">
            <CardTitle className="text-base font-semibold">Tổng quan Giao nhận & Phân lớp khách</CardTitle>
          </CardHeader>
          <CardContent className="p-0">
            <div className="grid grid-cols-1 md:grid-cols-2 divide-y md:divide-y-0 md:divide-x divide-border">
              {/* Cột 1: Status Breakdown */}
              <div className="p-5">
                 <h3 className="text-sm font-bold tracking-tight mb-4 flex items-center gap-2 text-foreground">Phân bổ Doanh thu theo Trạng thái</h3>
                 <div className="space-y-3">
                   {Object.keys(reportData.overview?.statusBreakdown || {}).map(status => {
                     const detail = reportData.overview.statusBreakdown[status];
                     if (detail.count === 0) return null;
                     return (
                       <div key={status} className="flex justify-between items-center text-sm">
                         <div className="flex items-center gap-2">
                           <Badge variant="outline" className={getStatusBadgeVariant(status)}>{formatStatusText(status)}</Badge>
                           <span className="text-xs text-muted-foreground">({detail.count} đơn)</span>
                         </div>
                         <span className="font-medium">{formatMoney(detail.revenue)}</span>
                       </div>
                     );
                   })}
                 </div>
              </div>

              {/* Cột 2: Top Lists (Simplified) */}
              <div className="p-5 bg-muted/5">
                 <h3 className="text-sm font-bold tracking-tight mb-4 flex items-center gap-2 text-foreground">Top 5 Đại lý xuất sắc kì này</h3>
                 <div className="space-y-3">
                   {!reportData.overview?.topCustomers || reportData.overview.topCustomers.length === 0 ? <p className="text-sm text-muted-foreground">Chưa có dữ liệu giao dịch.</p> : null}
                   {(reportData.overview?.topCustomers || []).slice(0,5).map((c, idx) => (
                     <div key={c.phone + idx} className="flex justify-between items-start text-sm group">
                       <div className="flex items-start gap-2 max-w-[200px]">
                         <span className="w-5 text-muted-foreground text-xs font-mono font-bold mt-0.5">{idx+1}.</span>
                         <div>
                            <p className="font-semibold text-foreground leading-tight line-clamp-1 group-hover:text-primary transition-colors">{c.name}</p>
                            <p className="text-[10px] text-muted-foreground mt-0.5">{c.phone} • {c.orderCount} đơn</p>
                         </div>
                       </div>
                       <span className="font-bold text-primary tabular-nums mt-0.5">{formatMoney(c.revenue)}</span>
                     </div>
                   ))}
                 </div>
              </div>
            </div>
          </CardContent>
        </Card>
      )}

      {/* DATATABLE */}
      {reportData && (
        <Card className="glass shadow-sm border-muted/50 overflow-hidden print:hidden">
          <CardHeader className="bg-muted/10 border-b py-4">
             <div className="flex items-center justify-between">
                <CardTitle className="text-base font-semibold">Danh sách Đơn hàng (Order Details)</CardTitle>
                <Badge variant="secondary" className="font-mono">{reportData.orders.length} Records</Badge>
             </div>
          </CardHeader>
          <CardContent className="p-0">
            <div className="w-full overflow-auto max-h-[550px] custom-scrollbar">
              <Table>
                <TableHeader className="bg-muted/50 sticky top-0 shadow-sm z-10">
                  <TableRow>
                    <TableHead className="px-5 w-[140px] text-foreground font-semibold">Mã ĐH / Ngày</TableHead>
                    <TableHead className="px-5 w-[180px] text-foreground font-semibold">Khách hàng</TableHead>
                    <TableHead className="px-5 min-w-[200px] text-foreground font-semibold">Sản phẩm (SL)</TableHead>
                    <TableHead className="px-5 w-[130px] text-foreground font-semibold text-center">Trạng thái</TableHead>
                    <TableHead className="px-5 w-[140px] text-foreground font-semibold text-right">Tổng thanh toán</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {reportData.orders.length === 0 ? (
                    <TableRow>
                      <TableCell colSpan={5} className="h-32 text-center text-muted-foreground">Không tìm thấy đơn hàng nào trong thời gian này.</TableCell>
                    </TableRow>
                  ) : (
                    reportData.orders.map(o => (
                      <TableRow key={o.id} className="hover:bg-muted/30 transition-colors">
                        <TableCell className="px-5 align-top pt-4">
                          <div className="font-bold text-foreground text-[13px]">{o.orderNumber}</div>
                          <div className="text-[11px] text-muted-foreground mt-1">{new Date(o.createdAt).toLocaleString('vi-VN')}</div>
                        </TableCell>
                        <TableCell className="px-5 align-top pt-4">
                          <div className="font-semibold text-[13px] line-clamp-1">{o.snapshotCustomerName}</div>
                          <div className="text-[11px] text-muted-foreground mt-1">{o.snapshotCustomerPhone}</div>
                          <div className="mt-1.5"><Badge variant="outline" className="text-[9px] px-1.5 py-0 shadow-none border-dashed">{o.customer?.group?.name || 'Khách lẻ'}</Badge></div>
                        </TableCell>
                        <TableCell className="px-5 align-top pt-4">
                           <ul className="space-y-1.5">
                             {o.items?.slice(0, 3).map(i => (
                               <li key={i.id} className="text-xs flex justify-between items-start gap-2 border-b border-border/40 pb-1.5 last:border-0 last:pb-0">
                                 <span className="line-clamp-1 text-muted-foreground flex-1" title={i.snapshotProductName}>{i.snapshotProductName}</span>
                                 <span className="font-semibold tabular-nums shrink-0">x{i.quantity}</span>
                               </li>
                             ))}
                             {(o.items?.length || 0) > 3 && (
                               <li className="text-[10px] text-primary font-medium italic">+ {(o.items?.length || 0) - 3} sản phẩm khác</li>
                             )}
                           </ul>
                        </TableCell>
                        <TableCell className="px-5 align-top pt-4 text-center">
                           <Badge className={`${getStatusBadgeVariant(o.deliveryStatus)} text-[10px] px-2 py-0.5 shadow-none`}>
                              {formatStatusText(o.deliveryStatus)}
                           </Badge>
                           {o.notes && <div className="text-[10px] text-muted-foreground italic mt-2 line-clamp-1 max-w-[100px] mx-auto text-center" title={o.notes}>"{o.notes}"</div>}
                        </TableCell>
                        <TableCell className="px-5 align-top pt-4 text-right">
                          <div className="font-bold text-primary">{formatMoney(o.totalAmount)}</div>
                          {(Number(o.shippingFee) > 0 || Number(o.discountAmount) > 0) && (
                            <div className="text-[10px] text-muted-foreground mt-1">
                               {Number(o.shippingFee) > 0 && <div>+Ship: {formatMoney(Number(o.shippingFee))}</div>}
                               {Number(o.discountAmount) > 0 && <div>-CK Đơn: {formatMoney(Number(o.discountAmount))}</div>}
                            </div>
                          )}
                        </TableCell>
                      </TableRow>
                    ))
                  )}
                </TableBody>
              </Table>
            </div>
          </CardContent>
        </Card>
      )}
      </div>

      {/* =========================================================================
          HIDDEN PRINT LAYOUT (A4 OPTIMIZED - ENTERPRISE GRADE)
          ========================================================================= */}
      {reportData && (
        <div id="print-report" className="hidden print:block w-[210mm] text-black bg-white mx-auto print:absolute print:top-0 print:left-0" style={{ fontFamily: '"Inter", sans-serif', color: 'black' }}>
          <style dangerouslySetInnerHTML={{__html: `
            @media print {
              @page { size: A4 portrait; margin: 15mm; }
              /* Force overflow visibility so multiple pages are created */
              html, body, #root, main, .overflow-hidden, .overflow-y-auto { 
                height: auto !important; 
                max-height: none !important; 
                overflow: visible !important; 
              }
              body { background: white !important; font-family: "Inter", sans-serif; -webkit-print-color-adjust: exact; print-color-adjust: exact; margin: 0; padding: 0; }
              
              /* Hide all components recursively globally up to html, except print-report */
              /* In Tailwind + Next.js, we rely on print:hidden classes added above */
              
              #print-report { 
                position: relative !important; 
                display: block !important;
                visibility: visible !important;
                width: 100% !important; 
              }
              .page-break { page-break-before: always; }
              table { border-collapse: collapse; width: 100%; border: 1px solid #111; }
              th, td { border: 1px solid #111; padding: 4px 6px; text-align: left; }
              th { background-color: #f3f4f6 !important; font-weight: bold; }
            }
          `}} />

          {/* Header */}
          <div className="border-b-2 border-black pb-3 mb-4 flex justify-between items-start">
            <div className="w-1/2">
              <h2 className="text-sm font-black uppercase tracking-tight">{company?.name || 'CỬA HÀNG MINH PHƯƠNG'}</h2>
              <p className="text-[10px] mt-0.5">ĐC: {company?.address || 'Chưa cập nhật'}</p>
              <p className="text-[10px]">Hotline: {company?.phone || 'Chưa cập nhật'}</p>
              <p className="text-[10px]">MST: {company?.taxCode || 'Chưa cập nhật'}</p>
            </div>
            <div className="w-1/2 text-right">
              <h1 className="text-lg font-black uppercase tracking-widest text-black mb-0.5">Báo Cáo Quản Trị</h1>
              <p className="text-[12px] font-semibold">Doanh Thu & Giao Nhận</p>
              <p className="text-[9px] font-medium mt-1 uppercase text-gray-700">KỲ BÁO CÁO: {startDate ? new Date(startDate).toLocaleDateString('vi-VN') : 'TẤT CẢ'} - {endDate ? new Date(endDate).toLocaleDateString('vi-VN') : 'TẤT CẢ'}</p>
              <p className="text-[8px] mt-0.5">Ngày trích xuất: {new Date().toLocaleString('vi-VN')}</p>
            </div>
          </div>

          {/* PART 1: KPI SUMMARY */}
          <div className="mb-5">
            <h3 className="font-bold text-[12px] mb-1.5 uppercase border-l-4 border-black pl-2">I. Tổng quan Chỉ số KPI</h3>
            <table className="text-[11px]">
              <tbody>
                <tr>
                  <td className="font-bold bg-gray-100" width="25%">Doanh Thu Gộp (Gross)</td>
                  <td className="font-black text-[13px]" width="25%">{formatMoney(reportData.summary.grossRevenue || 0)}</td>
                  <td className="font-bold bg-gray-100" width="25%">Doanh Thu Thực Nhận (Net)</td>
                  <td className="font-black text-[13px]" width="25%">{formatMoney(reportData.summary.netRevenue || 0)}</td>
                </tr>
                <tr>
                  <td className="font-semibold bg-gray-100">Tổng Số Đơn Khởi Tạo</td>
                  <td className="font-bold">{reportData.summary.totalOrders} đơn</td>
                  <td className="font-semibold bg-gray-100">Số Đơn Hoàn Thành (Thành công)</td>
                  <td className="font-bold">{reportData.summary.completedOrdersCount} đơn</td>
                </tr>
                <tr>
                  <td className="font-semibold bg-gray-100">AOV (Trung bình / Đơn)</td>
                  <td className="font-bold">{formatMoney(reportData.summary.aov || 0)}</td>
                  <td className="font-semibold bg-gray-100">Tỷ lệ Huỷ / Hoàn</td>
                  <td className="font-bold">{(reportData.summary.cancelRate || 0).toFixed(2)}%</td>
                </tr>
                <tr>
                  <td className="font-semibold bg-gray-100">Tổng Phí Thu Hộ (Ship)</td>
                  <td className="font-bold">{formatMoney(reportData.summary.totalShippingFee)}</td>
                  <td className="font-semibold bg-gray-100">Tổng Chiết Khấu / Giảm giá</td>
                  <td className="font-bold">{formatMoney(reportData.summary.totalDiscount)}</td>
                </tr>
              </tbody>
            </table>
          </div>

          {/* PART 2: ORDER OVERVIEW */}
          <div className="mb-5 flex gap-6">
             <div className="w-1/2">
                <h3 className="font-bold text-[12px] mb-1.5 uppercase border-l-4 border-black pl-2">II. Phân bổ theo Trạng thái</h3>
                <table className="text-[10px]">
                  <thead>
                    <tr>
                      <th className="w-[40%]">Trạng thái</th>
                      <th className="text-center w-[20%]">Số lượng</th>
                      <th className="text-right w-[40%]">Doanh Thu Tạm Tính</th>
                    </tr>
                  </thead>
                  <tbody>
                    {Object.keys(reportData.overview?.statusBreakdown || {}).map(k => {
                       const d = reportData.overview.statusBreakdown[k];
                       return (
                         <tr key={k}>
                           <td className="font-semibold uppercase">{formatStatusText(k)}</td>
                           <td className="text-center">{d.count}</td>
                           <td className="text-right font-bold">{formatMoney(d.revenue)}</td>
                         </tr>
                       )
                    })}
                  </tbody>
                </table>
             </div>
             
             <div className="w-1/2">
                <h3 className="font-bold text-[12px] mb-1.5 uppercase border-l-4 border-black pl-2">III. Top Đại Lý Trong Kỳ</h3>
                <table className="text-[10px]">
                  <thead>
                    <tr>
                      <th className="w-[10%] text-center">Top</th>
                      <th className="w-[50%]">Khách Hàng</th>
                      <th className="text-right w-[40%]">Đóng Góp (Net)</th>
                    </tr>
                  </thead>
                  <tbody>
                     {!reportData.overview?.topCustomers || reportData.overview.topCustomers.length === 0 && <tr><td colSpan={3} className="text-center">Trống</td></tr>}
                     {(reportData.overview?.topCustomers || []).slice(0,6).map((c, idx) => (
                       <tr key={c.phone}>
                         <td className="text-center font-bold text-[10px]">{idx + 1}</td>
                         <td className="font-semibold leading-tight">{c.name}<br/><span className="text-[9px] font-normal text-gray-600">{c.phone}</span></td>
                         <td className="text-right font-bold text-[11px]">{formatMoney(c.revenue)}</td>
                       </tr>
                     ))}
                  </tbody>
                </table>
             </div>
          </div>

          {/* PART 3: ORDER DETAILS (PAGE BREAK) */}
          <div className="page-break">
             <h3 className="font-bold text-[12px] mb-1.5 uppercase border-l-4 border-black pl-2">IV. Bảng kê Chi Tiết Đơn Hàng</h3>
             <table className="w-full text-[9px]">
                <thead>
                  <tr>
                    <th className="text-center w-[5%] font-bold">STT</th>
                    <th className="text-left w-[12%] font-bold">Mã / Ngày</th>
                    <th className="text-left w-[20%] font-bold">Khách Hàng (SĐT)</th>
                    <th className="text-left w-[36%] font-bold">Tóm tắt Sản Phẩm</th>
                    <th className="text-center w-[12%] font-bold">Trạng thái</th>
                    <th className="text-right w-[15%] font-bold">Tổng Thanh Toán</th>
                  </tr>
                </thead>
                <tbody>
                  {reportData.orders.map((o, idx) => (
                    <tr key={o.id}>
                      <td className="text-center font-bold">{idx + 1}</td>
                      <td>
                        <div className="font-bold">{o.orderNumber}</div>
                        <div className="text-[9px]">{new Date(o.createdAt).toLocaleDateString('vi-VN')}</div>
                      </td>
                      <td>
                        <div className="font-bold">{o.snapshotCustomerName}</div>
                        <div className="text-[9px]">{o.snapshotCustomerPhone}</div>
                      </td>
                      <td className="leading-[1.4]">
                         {o.items?.map((i, iIdx) => (
                            <div key={i.id} className="mb-[2px]">{iIdx+1}. {i.snapshotProductName} <span className="font-bold">x{i.quantity}</span></div>
                         ))}
                      </td>
                      <td className="text-center font-bold">
                          {formatStatusText(o.deliveryStatus)}
                      </td>
                      <td className="text-right font-black">
                        {formatMoney(o.totalAmount)}
                      </td>
                    </tr>
                  ))}
                </tbody>
             </table>
          </div>

          {/* SIGNATURES */}
          <div className="flex justify-between text-center pt-10 px-16 text-sm mb-6 avoid-break mt-6">
             <div>
                <p className="font-bold uppercase mb-14 text-[11px]">Lập bảng (Người xuất)</p>
                <p className="italic text-[9px] text-gray-500">(Ký & ghi rõ họ tên)</p>
             </div>
             <div>
                <p className="font-bold uppercase mb-14 text-[11px]">Giám đốc / Kế Toán Trưởng</p>
                <p className="italic text-[9px] text-gray-500">(Ký & đóng dấu)</p>
             </div>
          </div>
        </div>
      )}
    </div>
  );
}
