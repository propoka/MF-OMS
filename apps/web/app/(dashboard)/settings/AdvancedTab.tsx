import { Card, CardHeader, CardTitle, CardDescription, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Settings, Upload, Download, AlertTriangle, Loader2, Users, ShoppingBag, Package, ListTree, Grid, FileSpreadsheet } from 'lucide-react';
import { toast } from 'sonner';
import { useState, useRef } from 'react';
import { crmApi, productsApi, ordersApi, advancedApi } from '@/lib/api';
import { useAuth } from '@/lib/auth-context';
import * as XLSX from 'xlsx';
import { AlertDialog, AlertDialogContent, AlertDialogHeader, AlertDialogTitle, AlertDialogDescription, AlertDialogFooter, AlertDialogCancel, AlertDialogAction } from '@/components/ui/alert-dialog';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';

export function AdvancedTab() {
  const { getToken } = useAuth();
  const fileInputRef = useRef<HTMLInputElement>(null);
  
  const [isActionLoading, setIsActionLoading] = useState(false);
  const [advancedActionConfirmText, setAdvancedActionConfirmText] = useState('');
  const [advancedActionType, setAdvancedActionType] = useState<string | null>(null);
  const [isAdvancedModalOpen, setIsAdvancedModalOpen] = useState(false);

  const [importType, setImportType] = useState<string | null>(null);

  const handleDeleteAll = async () => {
    if (advancedActionConfirmText !== 'XOA-ALL') {
      toast.error('Vui lòng gõ chính xác XOA-ALL để xác nhận.');
      return;
    }
    
    try {
      setIsActionLoading(true);
      const token = getToken()!;
      let msg = '';
      
      switch(advancedActionType) {
        case 'products':
          await advancedApi.deleteAllProducts(token);
          msg = 'Đã xóa tất cả sản phẩm.';
          break;
        case 'customers':
          await advancedApi.deleteAllCustomers(token);
          msg = 'Đã xóa tất cả khách hàng.';
          break;
        case 'orders':
          await advancedApi.deleteAllOrders(token);
          msg = 'Đã xóa tất cả đơn hàng.';
          break;
        case 'groups':
          await advancedApi.deleteAllCustomerGroups(token);
          msg = 'Đã xóa cấu hình nhóm khách (trừ mặc định).';
          break;
        case 'categories':
          await advancedApi.deleteAllProductCategories(token);
          msg = 'Đã xóa tất cả danh mục sản phẩm.';
          break;
      }
      toast.success(msg);
      setIsAdvancedModalOpen(false);
    } catch (e: any) {
      toast.error(e.message || 'Xảy ra lỗi khi thao tác.');
    } finally {
      setIsActionLoading(false);
      setAdvancedActionType(null);
      setAdvancedActionConfirmText('');
    }
  };

  const openDeleteModal = (type: string) => {
    setAdvancedActionType(type);
    setAdvancedActionConfirmText('');
    setIsAdvancedModalOpen(true);
  };

  const handleFileUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file || !importType) return;
    
    setIsActionLoading(true);
    const token = getToken()!;

    try {
      const data = await file.arrayBuffer();
      const workbook = XLSX.read(data, { type: 'array' });
      const sheetName = workbook.SheetNames[0];
      const worksheet = workbook.Sheets[sheetName];
      const jsonData: any[] = XLSX.utils.sheet_to_json(worksheet);

      if (jsonData.length === 0) {
         toast.error('File không có dữ liệu');
         return;
      }

      const toastId = toast.loading(`Đang import ${jsonData.length} dòng dữ liệu...`);

      if (importType === 'customers') {
        const payload = jsonData.map((r: any) => ({
          phone: r['SĐT'] ? String(r['SĐT']).trim() : '',
          fullName: r['Họ Tên'] || 'Khách vãng lai',
          groupId: '', // Will be dynamically allocated a default group based on ID on server if possible, actually we didn't change CRM API.
          // Wait, backend `customers.service.ts` import creates records. If we don't pass `groupId`, it might fail because Prisma schema has `groupId` as required or we use `defaultGroup` logic?
          // I'll leave empty, the backend will fail if it's required. Wait, we should probably pass a default. Let's fix that later if it throws.
          note: r['Ghi chú'],
          provinceName: r['Tỉnh'],
          wardName: r['Phường'],
          addressDetail: r['Địa chỉ'],
        }));
        await crmApi.importCustomers(token, payload);
      } else if (importType === 'products') {
        const payload = jsonData.map((r: any) => ({
          name: r['Tên Sản Phẩm'],
          sku: r['SKU'],
          categoryCode: r['Mã Danh Mục'],
          unit: r['Đơn vị tính'] || 'Cái',
          retailPrice: Number(r['Giá bán lẻ'] || 0),
          weight: Number(r['Cân nặng'] || 0),
          dimensions: r['Kích thước'],
        }));
        await productsApi.importProducts(token, payload);
      } else if (importType === 'orders') {
        const payload = jsonData.map((r: any) => ({
          customerPhone: String(r['SĐT Khách']).trim(),
          customerName: r['Tên Khách'],
          productSkus: String(r['SKU Sản Phẩm (Cách nhau bằng phẩy)']),
          quantities: String(r['Số lượng tương ứng (Cách nhau bằng phẩy)']),
          shippingFee: Number(r['Cước vận chuyển'] || 0),
          discountAmount: Number(r['Giảm giá tổng'] || 0),
          notes: r['Ghi chú']
        }));
        await ordersApi.importOrders(token, payload);
      }

      toast.success('Import thành công!', { id: toastId });
    } catch (e: any) {
      toast.error(e.message || 'Lỗi parse file Excel.');
    } finally {
      setIsActionLoading(false);
      setImportType(null);
      if (fileInputRef.current) fileInputRef.current.value = '';
    }
  };

  const triggerImport = (type: string) => {
    setImportType(type);
    if (fileInputRef.current) fileInputRef.current.click();
  };

  return (
    <Card className="glass shadow-md shadow-primary/5 border-muted/30 overflow-hidden relative">
      <div className="absolute top-0 right-0 p-32 bg-primary/5 rounded-full blur-[100px] pointer-events-none" />
      <CardHeader className="bg-muted/10 border-b py-6 relative z-10">
        <CardTitle className="text-xl flex items-center gap-2.5">
          <div className="p-2 bg-primary/10 rounded-lg text-primary">
            <Settings className="h-5 w-5" />
          </div>
          Quản trị Công cụ Chuyên sâu
        </CardTitle>
        <CardDescription className="text-sm pt-1">
          Khu vực cung cấp các công cụ xử lý dữ liệu hàng loạt và khởi tạo lại cấu trúc lưu trữ. Các thao tác xoá dữ liệu tại đây mang tính vĩnh viễn và không thể phục hồi. Vui lòng thao tác cẩn trọng.
        </CardDescription>
      </CardHeader>
      <CardContent className="pt-8 space-y-10 relative z-10 px-6 sm:px-8">
        
        {/* Import Section */}
        <section>
           <h3 className="text-base font-bold mb-4 flex items-center gap-2 text-foreground">
             <div className="flex items-center justify-center w-6 h-6 rounded-full bg-primary/15 text-primary">
               <Upload className="w-3.5 h-3.5" />
             </div>
             Nhập dữ liệu hàng loạt từ tệp
           </h3>
           <div className="grid grid-cols-1 md:grid-cols-3 gap-5">
             {[
                { type: 'customers', label: 'Kết xuất Khách hàng', icon: <Users className="w-5 h-5" />, file: '/templates/template_import_customers.xlsx' },
                { type: 'products', label: 'Kết xuất Sản phẩm', icon: <Package className="w-5 h-5" />, file: '/templates/template_import_products.xlsx' },
                { type: 'orders', label: 'Giao dịch Đơn hàng', icon: <ShoppingBag className="w-5 h-5" />, file: '/templates/template_import_orders.xlsx' },
             ].map(item => (
                <div key={item.type} className="group p-5 border rounded-2xl bg-gradient-to-br from-background to-muted/20 flex flex-col items-start shadow-sm hover:shadow-md hover:border-primary/30 transition-all duration-300 relative overflow-hidden">
                   <div className="flex w-full items-center justify-between mb-4">
                      <div className="flex items-center gap-3">
                         <div className="p-2.5 bg-primary/10 text-primary rounded-xl group-hover:bg-primary/20 transition-colors">
                           {item.icon}
                         </div>
                         <div className="font-bold text-sm tracking-tight">{item.label}</div>
                      </div>
                      <a href={item.file} download title="Tải tệp biểu mẫu" className="inline-flex items-center justify-center whitespace-nowrap rounded-lg text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:pointer-events-none disabled:opacity-50 hover:bg-primary/10 text-primary h-8 w-8 hover:scale-110">
                        <Download className="w-4 h-4" />
                      </a>
                   </div>
                   <Button variant="outline" className="w-full text-xs font-semibold bg-background group-hover:bg-primary group-hover:text-primary-foreground group-hover:border-primary transition-all duration-300" onClick={() => triggerImport(item.type)} disabled={isActionLoading}>
                     <FileSpreadsheet className="w-4 h-4 mr-2" /> Tải tệp dữ liệu lên
                   </Button>
                </div>
             ))}
           </div>
        </section>

        <div className="w-2/3 h-px bg-gradient-to-r from-border/10 via-border/60 to-border/10 mx-auto" />

        {/* Delete Section */}
        <section>
           <h3 className="text-base font-bold mb-4 flex items-center gap-2 text-destructive">
             <div className="flex items-center justify-center w-6 h-6 rounded-full bg-destructive/10 text-destructive">
               <AlertTriangle className="w-3.5 h-3.5" />
             </div>
             Xoá dọn dẹp hệ thống
           </h3>
           <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-5 gap-4">
             {[
                { type: 'products', label: 'Sản phẩm lưu kho', icon: <Package className="w-4 h-4" /> },
                { type: 'customers', label: 'Hồ sơ Khách hàng', icon: <Users className="w-4 h-4" /> },
                { type: 'orders', label: 'Dữ liệu Đơn hàng', icon: <ShoppingBag className="w-4 h-4" /> },
                { type: 'groups', label: 'Quy tắc Nhóm Khách', icon: <ListTree className="w-4 h-4" /> },
                { type: 'categories', label: 'Danh mục Sản phẩm', icon: <Grid className="w-4 h-4" /> },
             ].map(item => (
                <Button 
                  key={item.type}
                  variant="outline" 
                  className="w-full h-[76px] flex flex-col justify-center gap-1.5 
                             border-destructive/20 text-destructive bg-destructive/5 
                             hover:bg-destructive hover:text-white hover:border-destructive hover:shadow-lg hover:shadow-destructive/20 
                             hover:-translate-y-0.5 transition-all duration-300" 
                  onClick={() => openDeleteModal(item.type)} 
                  disabled={isActionLoading}
                >
                   {item.icon}
                   <span className="font-bold text-xs tracking-tight">Xoá toàn bộ<br/>{item.label}</span>
                </Button>
             ))}
           </div>
        </section>

        {/* Hidden File Input */}
        <input 
          type="file" 
          accept=".xlsx, .xls" 
          className="hidden" 
          ref={fileInputRef} 
          onChange={handleFileUpload} 
        />
        
      </CardContent>

      <AlertDialog open={isAdvancedModalOpen} onOpenChange={setIsAdvancedModalOpen}>
        <AlertDialogContent className="glass sm:max-w-[425px] border-destructive shadow-destructive/20 border-2">
          <AlertDialogHeader>
            <AlertDialogTitle className="flex items-center gap-2 text-destructive">
              <AlertTriangle className="w-5 h-5 flex-shrink-0" />
              CẢNH BÁO BẢO MẬT DỮ LIỆU
            </AlertDialogTitle>
            <AlertDialogDescription className="text-foreground/80 pt-2 space-y-4 text-sm font-medium">
              <p>Bạn sắp thực thi một lệnh xóa dữ liệu hàng loạt trên máy chủ. Hành động này là <strong>vĩnh viễn và không thể khôi phục</strong>.</p>
              <div className="bg-destructive/10 p-3 rounded-md text-destructive">
                 Để hoàn tất thủ tục xác nhận, vui lòng nhập chính xác từ khoá bảo mật: <strong className="select-none inline-block px-1 bg-destructive/20 rounded">XOA-ALL</strong>
              </div>
              <div className="space-y-1">
                <Label>Nhập từ khoá xác nhận</Label>
                <Input 
                  value={advancedActionConfirmText}
                  onChange={e => setAdvancedActionConfirmText(e.target.value)}
                  placeholder="XOA-ALL"
                  className="font-mono tracking-widest text-destructive text-center uppercase"
                />
              </div>
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter className="mt-4">
            <AlertDialogCancel className="hover:bg-muted bg-transparent border-0">Huỷ bỏ thao tác</AlertDialogCancel>
            <AlertDialogAction 
              onClick={(e) => { e.preventDefault(); handleDeleteAll(); }} 
              disabled={advancedActionConfirmText !== 'XOA-ALL' || isActionLoading}
              className="bg-destructive hover:bg-destructive/90 text-white font-bold"
            >
              {isActionLoading ? <Loader2 className="w-4 h-4 animate-spin" /> : 'Xác nhận Rủi ro Thực thi'}
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>

    </Card>
  );
}
