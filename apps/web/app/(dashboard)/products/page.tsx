'use client';

import { useState, useEffect, useCallback } from 'react';
import { productsApi, crmApi, Product, CustomerGroup } from '@/lib/api';
import { useAuth } from '@/lib/auth-context';
import ProductFormModal from '@/components/products/ProductFormModal';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Search, Plus, PackageOpen, MoreHorizontal, Edit, Trash2, Loader2, Save, Inbox, AlertCircle } from 'lucide-react';
import { Badge } from '@/components/ui/badge';
import { Card, CardContent } from '@/components/ui/card';
import { GlassCard } from '@/components/ui/glass-card';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog";
import { toast } from "sonner";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";

function EditableCell({ 
  value, 
  onSave,
  fallbackValue 
}: { 
  value: number, 
  onSave: (val: number) => Promise<void>,
  fallbackValue?: number 
}) {
  const [val, setVal] = useState(value === 0 ? '' : value?.toString() || '');
  const [isEditing, setIsEditing] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [prevValueProp, setPrevValueProp] = useState(value);

  if (value !== prevValueProp) {
    setPrevValueProp(value);
    setVal(value === 0 ? '' : value?.toString() || '');
  }

  const handleBlur = async () => {
    setIsEditing(false);
    const num = Number(val.replace(/\D/g, ''));
    if (num !== value && !isNaN(num)) {
      setIsLoading(true);
      await onSave(num);
      setIsLoading(false);
    } else {
      setVal(value === 0 ? '' : value?.toString() || '');
    }
  };

  if (isLoading) return <div className="text-muted-foreground flex justify-end"><Loader2 className="h-4 w-4 animate-spin" /></div>;

  if (isEditing) {
    return (
      <Input
        autoFocus
        inputMode="numeric"
        className="h-7 w-24 text-right px-1 py-0 text-[13px] tracking-tight font-medium text-foreground bg-transparent border-0 shadow-none focus-visible:ring-0 focus-visible:ring-offset-0 focus:bg-transparent rounded-none"
        value={val ? new Intl.NumberFormat('vi-VN').format(Number(val.toString().replace(/\D/g, ''))) : ''}
        onChange={(e) => setVal(e.target.value.replace(/\D/g, ''))}
        onBlur={handleBlur}
        onKeyDown={(e) => {
          if (e.key === 'Enter') handleBlur();
          if (e.key === 'Escape') { setIsEditing(false); setVal(value === 0 ? '' : value?.toString() || ''); }
        }}
        placeholder={fallbackValue ? new Intl.NumberFormat('vi-VN').format(fallbackValue) : '0'}
      />
    );
  }

  const displayValue = value;

  return (
    <div 
      className={`text-right w-full cursor-text p-1 min-h-6 rounded-none font-medium text-[13px] tracking-tight text-muted-foreground bg-transparent`}
      onClick={() => setIsEditing(true)}
    >
      {new Intl.NumberFormat('vi-VN').format(displayValue)}
    </div>
  );
}

export default function ProductsPage() {
  const { getToken, user } = useAuth();
  const [products, setProducts] = useState<Product[]>([]);
  const [groups, setGroups] = useState<CustomerGroup[]>([]);
  const [total, setTotal] = useState(0);
  const [isLoading, setIsLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [selectedProduct, setSelectedProduct] = useState<Product | null>(null);

  const fetchGroups = useCallback(async () => {
    try {
      const token = getToken();
      if (!token) return;
      const res = await crmApi.getGroups(token);
      const filtered = res.filter(g => !g.isDefault);
      
      filtered.sort((a, b) => {
        const aIsSi = a.name.toLowerCase().includes('sỉ');
        const bIsSi = b.name.toLowerCase().includes('sỉ');
        if (aIsSi && !bIsSi) return -1;
        if (!aIsSi && bIsSi) return 1;
        return (a.createdAt ?? '') > (b.createdAt ?? '') ? 1 : -1;
      });
      
      setGroups(filtered);
    } catch (err) {}
  }, [getToken]);

  const fetchProducts = useCallback(async () => {
    try {
      setIsLoading(true);
      const token = getToken();
      if (!token) return;

      const res = await productsApi.getProducts(token, { search, take: 500 });
      setProducts(res.data);
      setTotal(res.total);
    } catch (err) {
      console.error(err);
    } finally {
      setIsLoading(false);
    }
  }, [getToken, search]);

  // Gộp fetch song song khi mount lần đầu — giảm 50% thời gian chờ
  const initialFetchDone = useState(false);
  useEffect(() => {
    if (!initialFetchDone[0]) {
      initialFetchDone[1](true);
      Promise.all([fetchGroups(), fetchProducts()]);
    }
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  // Debounce search — chỉ gọi lại khi search thay đổi (không lặp lại mount)
  useEffect(() => {
    if (!initialFetchDone[0]) return; // skip initial
    const timer = setTimeout(() => {
      fetchProducts();
    }, 300);
    return () => clearTimeout(timer);
  }, [search]); // eslint-disable-line react-hooks/exhaustive-deps

  const [productToDelete, setProductToDelete] = useState<string | null>(null);

  const confirmDelete = async () => {
    if (!productToDelete) return;
    try {
      await productsApi.deleteProduct(getToken()!, productToDelete);
      toast.success('Xóa sản phẩm thành công');
      fetchProducts();
    } catch (e: any) {
      toast.error(e.message || 'Hệ thống từ chối thao tác');
    } finally {
      setProductToDelete(null);
    }
  };

  const handleDelete = (id: string) => {
    setProductToDelete(id);
  };

  const handleEdit = (product: Product) => {
    setSelectedProduct(product);
    setIsModalOpen(true);
  };

  const handleSaveRetailPrice = async (productId: string, newPrice: number) => {
    await productsApi.updateProduct(getToken()!, productId, { retailPrice: newPrice });
    // Cập nhật local state thay vì fetch lại toàn bộ 500 sản phẩm
    setProducts(prev => prev.map(p => p.id === productId ? { ...p, retailPrice: newPrice } : p));
  };

  const handleSaveGroupPrice = async (product: Product, groupId: string, newPrice: number) => {
    const existingGroupPrices = product.groupPrices || [];
    const updated = existingGroupPrices.filter(gp => gp.groupId !== groupId);
    if (newPrice >= 0) {
      updated.push({ groupId, fixedPrice: newPrice });
    }
    await productsApi.updateProduct(getToken()!, product.id, { groupPrices: updated });
    // Cập nhật local state thay vì fetch lại toàn bộ 500 sản phẩm
    setProducts(prev => prev.map(p => {
      if (p.id !== product.id) return p;
      return { ...p, groupPrices: updated.map(gp => ({ ...gp, fixedPrice: gp.fixedPrice, group: groups.find(g => g.id === gp.groupId) })) as any };
    }));
  };

  return (
    <div className="flex flex-col gap-6 pb-4">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold tracking-tight text-foreground">Sản phẩm</h1>
        </div>
        <div className="flex items-center gap-3">
          <Button 
            onClick={() => { setSelectedProduct(null); setIsModalOpen(true); }}
            className="group relative overflow-hidden bg-neutral-900/85 hover:bg-black/90 backdrop-blur-xl text-white border border-white/20 hover:border-white/40 shadow-[0_8px_30px_rgb(0,0,0,0.12)] hover:shadow-[0_8px_30px_rgb(0,0,0,0.2)] transition-all duration-500 h-11 rounded-full px-6"
          >
            <div className="absolute inset-0 rounded-full ring-1 ring-inset ring-white/10 group-hover:ring-white/30 transition-all duration-500 pointer-events-none"></div>
            <Plus className="mr-2 h-5 w-5 opacity-80 group-hover:rotate-90 group-hover:scale-110 transition-all duration-500" />
            <span className="font-semibold text-sm">Thêm Sản phẩm</span>
          </Button>
        </div>
      </div>

      <GlassCard className="mb-6 border border-white/40 shadow-sm shadow-black/5 rounded-[24px] bg-white/40 backdrop-blur-xl p-2" contentClassName="p-0 flex flex-col xl:flex-row gap-3 items-center justify-between w-full border-none shadow-none bg-transparent">
        <div className="flex flex-col lg:flex-row gap-2 lg:gap-3 items-center w-full xl:w-auto flex-1">
          <div className="relative flex-1 w-full max-w-md">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
            <Input
              placeholder="Tìm theo tên hoặc SKU..."
              className="pl-9 h-11 border-white/40 bg-white/50 shadow-sm focus-visible:border-primary rounded-xl transition-all w-full text-[13px] tracking-tight font-medium placeholder:font-medium placeholder:text-muted-foreground/70"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
            />
          </div>
        </div>

        <div className="flex items-center gap-2 shrink-0 bg-white/50 border border-white/40 rounded-xl shadow-sm h-11 px-4 self-end xl:self-auto">
          <span className="text-[13px] font-medium text-muted-foreground whitespace-nowrap">Tổng sản phẩm</span>
          <span className="font-bold text-[14px] text-foreground">{total}</span>
        </div>
      </GlassCard>

      <GlassCard className="mb-4 flex-1 flex flex-col" contentClassName="flex-1 flex flex-col p-0">
        <div className="flex-1 overflow-auto max-w-[calc(100vw-300px)] lg:max-w-none custom-scrollbar pb-4">
          <div className="min-w-max">
            <Table>
            <TableHeader className="sticky top-0 z-10 hover:bg-transparent">
              <TableRow className="border-b border-border/40 hover:bg-transparent text-center">
                <TableHead className="w-12 text-center uppercase tracking-wider text-[11px] font-semibold text-muted-foreground">#</TableHead>
                <TableHead className="w-[250px] text-center uppercase tracking-wider text-[11px] font-semibold text-muted-foreground">Sản phẩm</TableHead>
                <TableHead className="w-[120px] text-center uppercase tracking-wider text-[11px] font-semibold text-muted-foreground">SKU</TableHead>
                <TableHead className="w-[80px] text-center uppercase tracking-wider text-[11px] font-semibold text-muted-foreground">Đơn vị</TableHead>
                <TableHead className="w-[110px] text-center uppercase tracking-wider text-[11px] font-semibold text-muted-foreground">Giá lẻ</TableHead>
                {groups.map(g => (
                  <TableHead key={g.id} className="min-w-[110px] text-center truncate uppercase tracking-wider text-[11px] font-semibold text-muted-foreground" title={g.name}>
                    {g.name}
                  </TableHead>
                ))}
              </TableRow>
            </TableHeader>
            <TableBody className="relative">
              {isLoading ? (
                Array.from({ length: 5 }).map((_, i) => (
                  <TableRow key={i} className="animate-pulse border-border/30">
                    <TableCell className="py-4 pl-6 lg:pl-8"><div className="h-4 bg-muted/50 rounded w-4 mx-auto"></div></TableCell>
                    <TableCell className="py-4"><div className="h-4 bg-muted/50 rounded w-3/4"></div></TableCell>
                    <TableCell className="py-4"><div className="h-4 bg-muted/50 rounded w-16"></div></TableCell>
                    <TableCell className="py-4"><div className="h-4 bg-muted/50 rounded w-10 mx-auto"></div></TableCell>
                    <TableCell className="py-4"><div className="h-5 bg-muted/50 rounded w-20 ml-auto"></div></TableCell>
                    {groups.map(g => (
                      <TableCell key={g.id} className="py-4"><div className="h-5 bg-muted/50 rounded w-20 ml-auto"></div></TableCell>
                    ))}
                  </TableRow>
                ))
              ) : products.length === 0 ? (
                <TableRow className="border-border/30">
                  <TableCell colSpan={5 + groups.length} className="h-48 text-center">
                    <div className="flex flex-col items-center justify-center text-muted-foreground">
                      <Inbox className="h-10 w-10 mb-4 opacity-30" />
                      <p className="text-[13px] font-medium tracking-tight">Chưa có sản phẩm nào trong hệ thống.</p>
                      <p className="text-[13px] font-medium tracking-tight">Bấm "Thêm Sản phẩm" để tạo mới.</p>
                    </div>
                  </TableCell>
                </TableRow>
              ) : (
                products.map((p, idx) => (
                  <TableRow key={p.id} className="group hover:bg-muted/40 transition-colors border-border/30">
                    <TableCell className="py-4 align-middle text-center text-muted-foreground pl-6 lg:pl-8">
                      <DropdownMenu>
                        <DropdownMenuTrigger render={
                          <Button variant="ghost" size="sm" className="h-8 w-8 rounded-full bg-primary/5 text-primary hover:bg-primary/10 transition-all p-0 flex items-center justify-center"><MoreHorizontal className="h-4 w-4" /></Button>
                        } />
                        <DropdownMenuContent align="start" className="rounded-[16px] p-2 shadow-2xl border-white/60 backdrop-blur-3xl bg-white/70 min-w-[160px]">
                          <DropdownMenuItem onClick={() => handleEdit(p)} className="rounded-xl py-2 px-3 focus:bg-white/80 focus:text-primary transition-all cursor-pointer font-medium tracking-tight whitespace-nowrap mb-1">
                            <Edit className="mr-2 h-4 w-4" /> Cập nhật
                          </DropdownMenuItem>
                          {user?.role === 'ADMIN' && (
                            <DropdownMenuItem onClick={() => handleDelete(p.id)} className="rounded-xl py-2 px-3 focus:bg-destructive/10 focus:text-destructive text-destructive transition-all cursor-pointer font-medium tracking-tight whitespace-nowrap">
                              <Trash2 className="mr-2 h-4 w-4" /> Xoá sản phẩm
                            </DropdownMenuItem>
                          )}
                        </DropdownMenuContent>
                      </DropdownMenu>
                    </TableCell>
                    <TableCell className="py-4 align-middle truncate max-w-[250px] transition-colors" title={p.name}>
                      <div className="flex flex-col justify-center gap-1.5 truncate pr-2">
                        <span className="font-medium text-[13px] text-foreground tracking-tight whitespace-nowrap truncate">{p.name}</span>
                        {!p.isActive && <span className="text-[10px] uppercase font-bold tracking-wider text-destructive opacity-90 w-fit rounded bg-destructive/10 px-1.5 py-0.5 mt-0.5">Tắt</span>}
                      </div>
                    </TableCell>
                    <TableCell className="py-4 align-middle text-muted-foreground tracking-tight text-[13px] font-medium">{p.sku}</TableCell>
                    <TableCell className="py-4 align-middle text-center font-medium text-[13px] text-muted-foreground tracking-tight">{p.unit}</TableCell>
                    <TableCell className="py-4 align-middle">
                      <EditableCell value={Number(p.retailPrice)} onSave={(v) => handleSaveRetailPrice(p.id, v)} />
                    </TableCell>
                    {groups.map(g => {
                      const gp = p.groupPrices?.find(x => x.groupId === g.id);
                      const currentVal = gp ? Number(gp.fixedPrice) : 0;
                      return (
                        <TableCell key={g.id} className="py-4 align-middle pr-4">
                          <EditableCell 
                            value={currentVal} 
                            onSave={(v) => handleSaveGroupPrice(p, g.id, v)} 
                          />
                        </TableCell>
                      );
                    })}
                  </TableRow>
                ))
              )}
            </TableBody>
            </Table>
          </div>
        </div>
      </GlassCard>

      <ProductFormModal 
        isOpen={isModalOpen} 
        onClose={() => { setIsModalOpen(false); setSelectedProduct(null); }} 
        onSuccess={() => {
          setIsModalOpen(false);
          fetchProducts();
        }}
        initialData={selectedProduct}
      />

      <AlertDialog open={!!productToDelete} onOpenChange={(open) => !open && setProductToDelete(null)}>
        <AlertDialogContent className="glass sm:max-w-[400px] border-border/40 shadow-2xl p-6">
          <AlertDialogHeader className="flex flex-col items-center text-center space-y-4">
            <div className="w-14 h-14 rounded-full bg-red-700/10 flex items-center justify-center shrink-0">
              <Trash2 className="w-7 h-7 text-red-700" />
            </div>
            <div className="space-y-2">
              <AlertDialogTitle className="text-xl font-bold text-foreground">
                Xóa sản phẩm?
              </AlertDialogTitle>
              <AlertDialogDescription className="text-foreground/80 leading-relaxed text-sm">
                Hành động này sẽ xóa hoàn toàn thông tin sản phẩm khỏi danh mục quản lý và <strong>không thể hoàn tác</strong>.
              </AlertDialogDescription>
            </div>
          </AlertDialogHeader>
          <AlertDialogFooter className="sm:justify-center flex-row gap-3 pt-6 w-full">
            <AlertDialogCancel className="flex-1 text-foreground font-semibold hover:bg-muted/50 border border-border/60 bg-white/50 m-0 shadow-sm transition-all text-[13px]">
              Hủy bỏ
            </AlertDialogCancel>
            <AlertDialogAction onClick={confirmDelete} className="flex-1 bg-red-700 text-white hover:bg-red-800 shadow-[0_0_15px_rgba(185,28,28,0.25)] hover:shadow-[0_0_20px_rgba(185,28,28,0.4)] transition-all duration-300 m-0 text-[13px]">
              Xác nhận xóa
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}
