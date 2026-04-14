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

  useEffect(() => setVal(value === 0 ? '' : value?.toString() || ''), [value]);

  const handleBlur = async () => {
    setIsEditing(false);
    const num = Number(val);
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
        className="h-7 w-24 text-right px-1 py-0 text-sm"
        value={val}
        onChange={(e) => setVal(e.target.value.replace(/[^0-9]/g, ''))}
        onBlur={handleBlur}
        onKeyDown={(e) => {
          if (e.key === 'Enter') handleBlur();
          if (e.key === 'Escape') { setIsEditing(false); setVal(value === 0 ? '' : value?.toString() || ''); }
        }}
        placeholder={fallbackValue ? fallbackValue.toString() : ''}
      />
    );
  }

  const displayValue = value === 0 && fallbackValue ? fallbackValue : value;

  return (
    <div 
      className={`text-right w-full cursor-pointer hover:bg-muted/50 p-1 min-h-6 rounded ${value === 0 ? 'text-muted-foreground opacity-40 italic' : 'font-medium'}`}
      onClick={() => setIsEditing(true)}
      title={value === 0 && fallbackValue ? 'Giá đang áp dụng (Mặc định)' : ''}
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
      setGroups(res.filter(g => !g.isDefault));
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

  useEffect(() => {
    fetchGroups();
  }, [fetchGroups]);

  useEffect(() => {
    const timer = setTimeout(() => {
      fetchProducts();
    }, 300);
    return () => clearTimeout(timer);
  }, [fetchProducts]);

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
    fetchProducts();
  };

  const handleSaveGroupPrice = async (product: Product, groupId: string, newPrice: number) => {
    const existingGroupPrices = product.groupPrices || [];
    const updated = existingGroupPrices.filter(gp => gp.groupId !== groupId);
    if (newPrice > 0) {
      updated.push({ groupId, fixedPrice: newPrice });
    }
    await productsApi.updateProduct(getToken()!, product.id, { groupPrices: updated });
    fetchProducts();
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
            className="shadow-md hover:shadow-lg transition-all duration-200 font-semibold px-5"
          >
            <Plus className="mr-2 h-5 w-5" />
            Thêm Sản phẩm
          </Button>
        </div>
      </div>

      <Card className="glass shadow-sm border-muted/50 overflow-hidden flex-1 flex flex-col">
        <CardContent className="p-0 flex-1 flex flex-col">
          <div className="p-6 border-b border-muted/30 flex items-center bg-muted/10 shrink-0">
            <div className="relative flex-1 max-w-md shadow-sm">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
              <Input
                placeholder="Tìm theo tên hoặc SKU..."
                className="pl-9 border-muted-foreground/30 bg-background h-10 transition-colors focus-visible:border-primary"
                value={search}
                onChange={(e) => setSearch(e.target.value)}
              />
            </div>
          </div>
          
          <div className="flex-1 overflow-auto max-w-[calc(100vw-300px)] lg:max-w-none">
            <div className="min-w-max pb-4">
              <Table>
            <TableHeader className="bg-muted/50 sticky top-0 z-10 shadow-sm">
              <TableRow className="hover:bg-transparent">
                <TableHead className="font-semibold px-4 w-12 text-center text-foreground">#</TableHead>
                <TableHead className="font-semibold px-4 w-[250px] sticky left-0 bg-muted/95 backdrop-blur-sm border-r text-foreground shadow-[1px_0_0_0_hsl(var(--border))]">Sản phẩm</TableHead>
                <TableHead className="font-semibold px-4 w-[120px] border-r text-foreground">SKU</TableHead>
                <TableHead className="font-semibold px-4 w-[80px] border-r text-center text-foreground">Đơn vị</TableHead>
                <TableHead className="font-semibold px-4 w-[110px] border-r text-right bg-primary/10 text-foreground">Giá lẻ</TableHead>
                {groups.map(g => (
                  <TableHead key={g.id} className="font-semibold px-4 min-w-[110px] text-right border-r truncate text-foreground" title={g.name}>
                    {g.name}
                  </TableHead>
                ))}
              </TableRow>
            </TableHeader>
            <TableBody className="relative">
              {isLoading ? (
                Array.from({ length: 5 }).map((_, i) => (
                  <TableRow key={i} className="animate-pulse">
                    <TableCell className="px-4 py-4"><div className="h-4 bg-muted rounded w-4 mx-auto"></div></TableCell>
                    <TableCell className="px-4 sticky left-0 bg-card border-r shadow-[1px_0_0_0_hsl(var(--border))]"><div className="h-4 bg-muted rounded w-3/4"></div></TableCell>
                    <TableCell className="px-4 border-r"><div className="h-4 bg-muted rounded w-16"></div></TableCell>
                    <TableCell className="px-4 border-r"><div className="h-4 bg-muted rounded w-10 mx-auto"></div></TableCell>
                    <TableCell className="px-4 border-r bg-primary/5"><div className="h-5 bg-muted rounded w-20 ml-auto"></div></TableCell>
                    {groups.map(g => (
                      <TableCell key={g.id} className="px-4 border-r"><div className="h-5 bg-muted rounded w-20 ml-auto"></div></TableCell>
                    ))}
                  </TableRow>
                ))
              ) : products.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={5 + groups.length} className="h-48 text-center">
                    <div className="flex flex-col items-center justify-center text-muted-foreground">
                      <Inbox className="h-10 w-10 mb-4 opacity-50" />
                      <p>Chưa có sản phẩm nào trong hệ thống.</p>
                      <p>Bấm "Thêm Sản phẩm" để tạo mới.</p>
                    </div>
                  </TableCell>
                </TableRow>
              ) : (
                products.map((p, idx) => (
                  <TableRow key={p.id} className="hover:bg-muted/30 transition-colors">
                    <TableCell className="px-4 text-center text-muted-foreground">
                      <DropdownMenu>
                        <DropdownMenuTrigger render={
                          <Button variant="ghost" size="sm" className="h-6 w-6 p-0 hover:bg-muted"><MoreHorizontal className="h-4 w-4" /></Button>
                        } />
                        <DropdownMenuContent align="start" className="shadow-lg">
                          <DropdownMenuItem onClick={() => handleEdit(p)} className="font-medium cursor-pointer"><Edit className="mr-2 h-4 w-4" /> Sửa thông tin</DropdownMenuItem>
                          {user?.role === 'ADMIN' && (
                            <DropdownMenuItem onClick={() => handleDelete(p.id)} className="text-destructive font-medium cursor-pointer focus:text-destructive focus:bg-destructive/10"><Trash2 className="mr-2 h-4 w-4" /> Xoá sản phẩm</DropdownMenuItem>
                          )}
                        </DropdownMenuContent>
                      </DropdownMenu>
                    </TableCell>
                    <TableCell className="px-4 sticky left-0 bg-card border-r font-semibold text-foreground truncate max-w-[250px] shadow-[1px_0_0_0_hsl(var(--border))] group-hover/row:bg-muted/30" title={p.name}>
                      <div className="flex items-center truncate">
                        <span className="truncate">{p.name}</span>
                        {!p.isActive && <Badge variant="destructive" className="ml-2 scale-75 whitespace-nowrap">Tắt</Badge>}
                      </div>
                    </TableCell>
                    <TableCell className="px-4 border-r text-muted-foreground tracking-tight text-sm font-medium">{p.sku}</TableCell>
                    <TableCell className="px-4 border-r text-center font-medium text-foreground">{p.unit}</TableCell>
                    <TableCell className="px-4 border-r bg-primary/5">
                      <EditableCell value={Number(p.retailPrice)} onSave={(v) => handleSaveRetailPrice(p.id, v)} />
                    </TableCell>
                    {groups.map(g => {
                      const gp = p.groupPrices?.find(x => x.groupId === g.id);
                      const currentVal = gp ? Number(gp.fixedPrice) : 0;
                      return (
                        <TableCell key={g.id} className="px-4 border-r">
                          <EditableCell 
                            value={currentVal} 
                            onSave={(v) => handleSaveGroupPrice(p, g.id, v)} 
                            fallbackValue={Number(p.retailPrice)}
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
        </CardContent>
      </Card>

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
        <AlertDialogContent className="glass sm:max-w-[425px]">
          <AlertDialogHeader>
            <AlertDialogTitle className="flex items-center text-destructive">
              <AlertCircle className="w-5 h-5 mr-2" />
              Xóa sản phẩm?
            </AlertDialogTitle>
            <AlertDialogDescription className="text-foreground/80">
              Hành động này không thể hoàn tác. Dữ liệu của sản phẩm này sẽ bị xóa khỏi hệ thống.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel className="hover:bg-muted/50 border-0 bg-transparent shadow-none">Hủy bỏ</AlertDialogCancel>
            <AlertDialogAction onClick={confirmDelete} className="bg-destructive text-destructive-foreground hover:bg-destructive/90">
              Xác nhận xóa
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}
