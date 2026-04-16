'use client';

import { useState, useEffect, useCallback } from 'react';
import { categoriesApi, ProductCategory } from '@/lib/api';
import { useAuth } from '@/lib/auth-context';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Input } from '@/components/ui/input';
import { Plus, Edit, Trash2, Loader2, AlertCircle, Package } from 'lucide-react';
import { Card, CardContent } from '@/components/ui/card';
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
            className="shadow-md hover:shadow-lg transition-all duration-200 font-semibold px-5"
          >
            <Plus className="mr-2 h-5 w-5" />
            Tạo Danh mục
          </Button>
        </div>
      </div>

      <Card className="glass shadow-sm border-muted/50">
        <CardContent className="p-0">
          <Table>
            <TableHeader className="bg-muted/50">
              <TableRow>
                <TableHead className="w-[100px] font-semibold text-center">STT</TableHead>
                <TableHead className="font-semibold text-foreground">Tên danh mục</TableHead>
                <TableHead className="font-semibold text-foreground">Mã danh mục</TableHead>
                <TableHead className="font-semibold text-foreground text-center">Số lượng sản phẩm</TableHead>
                <TableHead className="text-right font-semibold text-foreground">Thao tác</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {isLoading ? (
                <TableRow><TableCell colSpan={5} className="text-center py-10"><Loader2 className="h-6 w-6 animate-spin mx-auto text-muted-foreground" /></TableCell></TableRow>
              ) : categories.length === 0 ? (
                <TableRow><TableCell colSpan={5} className="text-center py-10 text-muted-foreground">Chưa có danh mục nào.</TableCell></TableRow>
              ) : (
                categories.map((c, i) => (
                  <TableRow key={c.id}>
                    <TableCell className="text-center text-muted-foreground font-medium">{i + 1}</TableCell>
                    <TableCell className="font-semibold text-foreground">{c.name}</TableCell>
                    <TableCell><Badge variant="secondary" className="font-medium">{c.code}</Badge></TableCell>
                    <TableCell className="text-center">
                      <Badge variant="outline" className="font-semibold">
                        <Package className="h-3 w-3 mr-1" />
                        {c._count?.products || 0}
                      </Badge>
                    </TableCell>
                    <TableCell className="text-right">
                      <Button variant="ghost" size="icon" onClick={() => handleEdit(c)} className="h-8 w-8 text-muted-foreground hover:text-foreground">
                        <Edit className="h-4 w-4" />
                      </Button>
                      <Button variant="ghost" size="icon" onClick={() => setCatToDelete(c.id)} className="h-8 w-8 text-muted-foreground hover:text-destructive">
                        <Trash2 className="h-4 w-4" />
                      </Button>
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      <Dialog open={isModalOpen} onOpenChange={(open) => !open && setIsModalOpen(false)}>
        <DialogContent className="sm:max-w-[425px]">
          <DialogHeader>
            <DialogTitle>{selectedCat ? 'Sửa danh mục' : 'Thêm mới danh mục'}</DialogTitle>
            <DialogDescription>
              Mã tiền tố sẽ được dùng để tự động sinh SKU cho sản phẩm thuộc danh mục này. (Phải viết liền không dấu, sẽ tự uppercase)
            </DialogDescription>
          </DialogHeader>
          <form onSubmit={handleSubmit} className="space-y-4 pt-4">
            <div className="space-y-2">
              <Label htmlFor="name">Tên danh mục <span className="text-destructive">*</span></Label>
              <Input id="name" value={name} onChange={e => setName(e.target.value)} placeholder="VD: Hàng tươi" required autoFocus />
            </div>
            <div className="space-y-2">
              <Label htmlFor="code">Mã tiền tố SKU <span className="text-destructive">*</span></Label>
              <Input 
                id="code" 
                value={code} 
                onChange={e => setCode(e.target.value.toUpperCase().replace(/[^A-Z]/g, ''))} 
                placeholder="VD: HANGTUOI" 
                maxLength={10}
                required 
                className="uppercase font-bold tracking-wider"
              />
            </div>
            <DialogFooter className="pt-4">
              <Button type="button" variant="outline" onClick={() => setIsModalOpen(false)}>Huỷ</Button>
              <Button type="submit" disabled={isSubmitting || !name || !code} className="bg-emerald-600 hover:bg-emerald-700">
                {isSubmitting && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                Lưu lại
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>

      <AlertDialog open={!!catToDelete} onOpenChange={(open) => !open && setCatToDelete(null)}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle className="text-destructive flex items-center"><AlertCircle className="mr-2 h-5 w-5" /> Xác nhận xoá</AlertDialogTitle>
            <AlertDialogDescription>
              Bạn có chắc muốn xoá danh mục này? Hệ thống sẽ chặn thao tác nếu danh mục đang chứa sản phẩm.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Huỷ bỏ</AlertDialogCancel>
            <AlertDialogAction onClick={confirmDelete} className="bg-destructive hover:bg-destructive/90">Xoá</AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}
