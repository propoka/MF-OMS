'use client';

import { useState, useEffect, useCallback } from 'react';
import { categoriesApi, ProductCategory } from '@/lib/api';
import { useAuth } from '@/lib/auth-context';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Input } from '@/components/ui/input';
import { Plus, Edit, Trash2, Loader2, AlertCircle, Package, Layers, Check } from 'lucide-react';
import { GlassCard } from '@/components/ui/glass-card';
import { toast } from "sonner";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
  DialogFooter,
} from '@/components/ui/dialog';
import { Label } from '@/components/ui/label';
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

export default function CategoriesPage() {
  const { getToken } = useAuth();
  const [categories, setCategories] = useState<ProductCategory[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [selectedCat, setSelectedCat] = useState<ProductCategory | null>(null);
  const [catToDelete, setCatToDelete] = useState<string | null>(null);
  
  // Form state
  const [name, setName] = useState('');
  const [code, setCode] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  const fetchCategories = useCallback(async () => {
    try {
      setIsLoading(true);
      const token = getToken();
      if (!token) return;
      const res = await categoriesApi.getCategories(token);
      setCategories(res);
    } catch (err) {
      toast.error('Lỗi khi tải danh mục');
    } finally {
      setIsLoading(false);
    }
  }, [getToken]);

  useEffect(() => {
    fetchCategories();
  }, [fetchCategories]);

  const handleEdit = (cat: ProductCategory) => {
    setSelectedCat(cat);
    setName(cat.name);
    setCode(cat.code);
    setIsModalOpen(true);
  };

  const handleAddNew = () => {
    setSelectedCat(null);
    setName('');
    setCode('');
    setIsModalOpen(true);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!name || !code) return;
    
    setIsSubmitting(true);
    try {
      if (selectedCat) {
        await categoriesApi.updateCategory(getToken()!, selectedCat.id, { name, code });
        toast.success('Cập nhật thành công');
      } else {
        await categoriesApi.createCategory(getToken()!, { name, code });
        toast.success('Tạo danh mục thành công');
      }
      setIsModalOpen(false);
      fetchCategories();
    } catch (err: any) {
      toast.error(err.message || 'Lỗi lưu danh mục');
    } finally {
      setIsSubmitting(false);
    }
  };

  const confirmDelete = async () => {
    if (!catToDelete) return;
    try {
      await categoriesApi.deleteCategory(getToken()!, catToDelete);
      toast.success('Đã xoá danh mục');
      fetchCategories();
    } catch (e: any) {
      toast.error(e.message || 'Không thể xóa danh mục đang chứa sản phẩm');
    } finally {
      setCatToDelete(null);
    }
  };

  return (
    <div className="flex flex-col gap-6 pb-4">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold tracking-tight text-foreground flex items-center gap-2">
            Danh mục Sản phẩm
          </h1>
        </div>
        <div className="flex items-center gap-3">
          <Button 
            onClick={handleAddNew}
            className="group relative overflow-hidden bg-neutral-900/85 hover:bg-black/90 backdrop-blur-xl text-white border border-white/20 hover:border-white/40 shadow-[0_8px_30px_rgb(0,0,0,0.12)] hover:shadow-[0_8px_30px_rgb(0,0,0,0.2)] transition-all duration-500 h-11 rounded-full px-6"
          >
            <div className="absolute inset-0 rounded-full ring-1 ring-inset ring-white/10 group-hover:ring-white/30 transition-all duration-500 pointer-events-none"></div>
            <Plus className="mr-2 h-5 w-5 group-hover:rotate-90 group-hover:scale-110 transition-all duration-500" />
            <span className="font-semibold text-[13px]">Tạo Danh mục</span>
          </Button>
        </div>
      </div>

      <GlassCard className="mb-4">
        <div className="w-full overflow-auto custom-scrollbar">
          <Table>
            <TableHeader>
              <TableRow className="border-b border-border/40 hover:bg-transparent text-center">
                <TableHead className="w-[80px] text-center uppercase tracking-wider text-[11px] font-semibold text-muted-foreground">STT</TableHead>
                <TableHead className="text-left uppercase tracking-wider text-[11px] font-semibold text-muted-foreground">Tên danh mục</TableHead>
                <TableHead className="text-center uppercase tracking-wider text-[11px] font-semibold text-muted-foreground">Mã danh mục (SKU Prefix)</TableHead>
                <TableHead className="text-center uppercase tracking-wider text-[11px] font-semibold text-muted-foreground">Sản phẩm</TableHead>
                <TableHead className="text-center uppercase tracking-wider text-[11px] font-semibold text-muted-foreground">Thao tác</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {isLoading ? (
                Array.from({ length: 3 }).map((_, i) => (
                  <TableRow key={i} className="animate-pulse border-border/30">
                    <TableCell className="py-4 text-center"><div className="h-4 bg-muted/50 rounded w-4 mx-auto"></div></TableCell>
                    <TableCell className="py-4 text-left"><div className="h-4 bg-muted/50 rounded w-24"></div></TableCell>
                    <TableCell className="py-4 text-center"><div className="h-5 bg-muted/50 rounded-xl w-24 mx-auto"></div></TableCell>
                    <TableCell className="py-4 text-center"><div className="h-5 bg-muted/50 rounded-xl w-16 mx-auto"></div></TableCell>
                    <TableCell className="py-4 text-center"><div className="h-8 bg-muted/50 rounded-lg w-16 mx-auto"></div></TableCell>
                  </TableRow>
                ))
              ) : categories.length === 0 ? (
                <TableRow className="border-border/30">
                  <TableCell colSpan={5} className="h-48 text-center">
                    <div className="flex flex-col items-center justify-center text-muted-foreground">
                      <Package className="h-10 w-10 mb-4 opacity-30" />
                      <p className="text-[13px] font-medium tracking-tight">Chưa có danh mục nào.</p>
                    </div>
                  </TableCell>
                </TableRow>
              ) : (
                categories.map((c, i) => (
                  <TableRow key={c.id} className="group hover:bg-muted/40 transition-colors border-border/30">
                    <TableCell className="py-4 align-middle text-center text-muted-foreground font-medium text-[13px] tracking-tight">{i + 1}</TableCell>
                    <TableCell className="py-4 align-middle text-left font-medium text-[13px] text-foreground tracking-tight whitespace-nowrap">{c.name}</TableCell>
                    <TableCell className="py-4 align-middle text-center">
                      <Badge variant="secondary" className="font-bold tracking-widest text-[10px] bg-muted/50 text-foreground uppercase px-2 shadow-none border-border/40 hover:bg-muted/50">{c.code}</Badge>
                    </TableCell>
                    <TableCell className="py-4 align-middle text-center">
                      <Badge variant="outline" className="font-medium text-[11px] bg-muted/30 border-border/40 text-foreground px-2 h-5 inline-flex items-center">
                        <Package className="h-3 w-3 mr-1.5 opacity-70" />
                        {c._count?.products || 0}
                      </Badge>
                    </TableCell>
                    <TableCell className="py-4 align-middle text-center">
                      <div className="flex items-center justify-center gap-2">
                        <Button 
                          variant="ghost" size="sm"
                          onClick={() => handleEdit(c)} 
                          className="h-8 w-8 rounded-full bg-primary/5 text-primary hover:bg-primary/10 transition-all p-0 flex items-center justify-center"
                          title="Sửa"
                        >
                          <Edit className="h-4 w-4" />
                        </Button>
                        <Button 
                          variant="ghost" size="sm"
                          onClick={() => setCatToDelete(c.id)} 
                          className="h-8 w-8 rounded-full hover:bg-destructive/10 text-muted-foreground hover:text-destructive transition-all p-0 flex items-center justify-center"
                          title="Xóa"
                        >
                          <Trash2 className="h-4 w-4" />
                        </Button>
                      </div>
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </div>
      </GlassCard>

      <Dialog open={isModalOpen} onOpenChange={(open) => !open && setIsModalOpen(false)}>
        <DialogContent className="sm:max-w-[500px] p-0 border border-white/80 shadow-2xl overflow-hidden rounded-[24px] bg-[#fcfbfb] backdrop-blur-2xl">
          <DialogHeader className="px-6 py-5 border-b border-black/5">
            <DialogTitle className="text-2xl font-bold tracking-tight text-foreground flex items-center gap-2">
              {selectedCat ? 'Cập nhật Danh mục' : 'Thêm Danh mục mới'}
            </DialogTitle>
            <DialogDescription className="text-foreground/70 text-[13px] font-medium tracking-tight">
              Mã tiền tố sẽ được dùng để tự động sinh SKU cho sản phẩm thuộc danh mục này. (Phải viết liền không dấu, sẽ tự uppercase).
            </DialogDescription>
          </DialogHeader>
          
          <form onSubmit={handleSubmit} className="px-6 py-4 max-h-[80vh] overflow-y-auto custom-scrollbar">
            <div className="space-y-6">
              <div className="flex items-center gap-2 text-foreground font-semibold">
                <div className="p-1.5 rounded-lg bg-primary/10 text-primary border border-primary/20">
                  <Layers className="h-4 w-4" />
                </div>
                <h3 className="text-[14px]">Thông tin chi tiết</h3>
              </div>
              
              <div className="grid grid-cols-1 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="name" className="text-[12px] font-bold tracking-tight text-foreground/80">Tên danh mục <span className="text-destructive">*</span></Label>
                  <Input 
                    id="name" 
                    value={name} 
                    onChange={e => setName(e.target.value)} 
                    placeholder="VD: Phụ kiện Nam" 
                    required 
                    autoFocus
                    className="h-11 px-4 border-black/5 bg-white focus-visible:border-primary focus-visible:ring-1 focus-visible:ring-primary/20 rounded-2xl transition-all w-full text-[13px] tracking-tight font-medium placeholder:font-medium placeholder:text-muted-foreground/50"
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="code" className="text-[12px] font-bold tracking-tight text-foreground/80">Mã tiền tố SKU <span className="text-destructive">*</span></Label>
                  <Input 
                    id="code" 
                    value={code} 
                    onChange={e => setCode(e.target.value.toUpperCase().replace(/[^A-Z]/g, ''))} 
                    placeholder="VD: PKNAM" 
                    maxLength={10}
                    required 
                    className="h-11 px-4 border-black/5 bg-white focus-visible:border-primary focus-visible:ring-1 focus-visible:ring-primary/20 rounded-2xl transition-all w-full text-[13px] tracking-tight font-bold uppercase placeholder:font-medium placeholder:text-muted-foreground/50"
                  />
                </div>
              </div>
            </div>
            
            <DialogFooter className="pt-8 mt-4 border-t border-black/5 bg-transparent m-0 flex items-center justify-end gap-3 px-0 pb-2">
              <Button type="button" variant="outline" onClick={() => setIsModalOpen(false)} disabled={isSubmitting} className="h-11 rounded-2xl px-6 bg-white border-black/10 hover:bg-neutral-100 shadow-sm text-[13px] font-bold tracking-tight transition-all">
                Huỷ bỏ
              </Button>
              <Button type="submit" disabled={isSubmitting || !name || !code} className="group relative overflow-hidden bg-neutral-900/85 hover:bg-black/90 backdrop-blur-xl text-white border border-white/20 hover:border-white/40 shadow-[0_8px_30px_rgb(0,0,0,0.12)] hover:shadow-[0_8px_30px_rgb(0,0,0,0.2)] transition-all duration-500 font-bold px-8 h-11 rounded-2xl">
                {isSubmitting ? (
                  <Loader2 className="mr-2 h-4 w-4 animate-spin opacity-80" />
                ) : (
                  <Check className="mr-2 h-4 w-4 opacity-80 group-hover:scale-110 transition-all duration-500" />
                )}
                <span className="relative z-10 text-[13px] tracking-tight">{selectedCat ? 'Lưu thay đổi' : 'Tạo danh mục'}</span>
                <div className="absolute inset-0 rounded-2xl ring-1 ring-inset ring-white/10 group-hover:ring-white/30 transition-all duration-500 pointer-events-none"></div>
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>
      
      <AlertDialog open={!!catToDelete} onOpenChange={(open) => !open && setCatToDelete(null)}>
        <AlertDialogContent className="glass sm:max-w-[425px]">
          <AlertDialogHeader>
            <AlertDialogTitle className="flex items-center gap-2 text-destructive">
              <AlertCircle className="h-5 w-5" /> Xác nhận xoá
            </AlertDialogTitle>
            <AlertDialogDescription className="pt-2 text-foreground/80">
              Bạn có chắc muốn xoá danh mục này? Hệ thống sẽ chặn thao tác nếu danh mục đang chứa sản phẩm.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter className="mt-4">
            <AlertDialogCancel className="hover:bg-muted/50 border-0 bg-transparent shadow-none">Huỷ bỏ</AlertDialogCancel>
            <AlertDialogAction onClick={confirmDelete} className="bg-destructive text-destructive-foreground hover:bg-destructive/90">Xoá danh mục</AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}
