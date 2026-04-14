'use client';

import { useState, useEffect, useCallback } from 'react';
import { crmApi, CustomerGroup } from '@/lib/api';
import { useAuth } from '@/lib/auth-context';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
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
import { Edit, Pencil, Plus, Inbox, Users, Trash2, AlertTriangle, Loader2, AlertCircle } from 'lucide-react';
import CustomerGroupFormModal from '@/components/customers/CustomerGroupFormModal';
import { toast } from 'sonner';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { Card, CardContent } from '@/components/ui/card';

export default function CustomerGroupsPage() {
  const { getToken, user } = useAuth();
  const [groups, setGroups] = useState<CustomerGroup[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  
  // Form Modal State
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [selectedGroup, setSelectedGroup] = useState<CustomerGroup | null>(null);

  // Delete Modal State
  const [deleteTarget, setDeleteTarget] = useState<{id: string, name: string} | null>(null);
  const [isDeleting, setIsDeleting] = useState(false);

  const handleOpenModal = (group?: CustomerGroup) => {
    setSelectedGroup(group || null);
    setIsModalOpen(true);
  };

  const fetchGroups = useCallback(async () => {
    try {
      setIsLoading(true);
      const token = getToken();
      if (!token) return;

      const data = await crmApi.getGroups(token);
      setGroups(data);
    } catch (err) {
      console.error(err);
    } finally {
      setIsLoading(false);
    }
  }, [getToken]);

  const confirmDelete = async () => {
    if (!deleteTarget) return;
    setIsDeleting(true);
    try {
      const token = getToken();
      if (!token) return;
      await crmApi.deleteGroup(token, deleteTarget.id);
      setDeleteTarget(null);
      toast.success('Xóa nhóm khách hàng thành công');
      fetchGroups();
    } catch (err: any) {
      toast.error(err.message || 'Không thể xoá nhóm này do rào cản nền tảng.');
    } finally {
      setIsDeleting(false);
    }
  };

  useEffect(() => {
    fetchGroups();
  }, [fetchGroups]);

  return (
    <div className="flex flex-col gap-6 pb-4">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold tracking-tight text-foreground">Nhóm Khách hàng</h1>
          <p className="text-sm text-muted-foreground mt-1">Phân loại khách hàng và thiết lập quy tắc giá bán sỉ.</p>
        </div>
        <div className="flex items-center gap-3">
          <Button 
            onClick={() => handleOpenModal()}
            className="shadow-md hover:shadow-lg transition-all duration-200 font-semibold px-5"
          >
            <Plus className="mr-2 h-5 w-5" />
            Tạo Nhóm Mới
          </Button>
        </div>
      </div>

      <Card className="glass shadow-sm border-muted/50 overflow-hidden">
        <CardContent className="p-0">
          <div className="w-full overflow-auto">
            <Table>
              <TableHeader className="bg-muted/50">
            <TableRow>
              <TableHead className="w-[250px] px-6 text-foreground font-semibold">Tên Nhóm</TableHead>
              <TableHead className="px-6 text-foreground font-semibold">Mô tả</TableHead>
              <TableHead className="px-6 text-foreground font-semibold">Quy tắc Giá</TableHead>
              <TableHead className="text-center px-6 text-foreground font-semibold">Số lượng KH</TableHead>
              <TableHead className="text-right px-6 text-foreground font-semibold">Thao tác</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {isLoading ? (
              Array.from({ length: 3 }).map((_, i) => (
                <TableRow key={i} className="animate-pulse">
                  <TableCell className="px-6 py-4"><div className="h-4 bg-muted rounded w-32"></div></TableCell>
                  <TableCell className="px-6"><div className="h-4 bg-muted rounded w-48"></div></TableCell>
                  <TableCell className="px-6"><div className="h-4 bg-muted rounded w-24"></div></TableCell>
                  <TableCell className="px-6"><div className="h-4 bg-muted rounded w-12 mx-auto"></div></TableCell>
                  <TableCell className="px-6"><div className="h-8 bg-muted rounded w-8 ml-auto"></div></TableCell>
                </TableRow>
              ))
            ) : groups.length === 0 ? (
              <TableRow>
                <TableCell colSpan={5} className="h-48 text-center">
                  <div className="flex flex-col items-center justify-center text-muted-foreground">
                    <Inbox className="h-10 w-10 mb-4 opacity-50" />
                    <p>Chưa có nhóm khách hàng nào.</p>
                  </div>
                </TableCell>
              </TableRow>
            ) : (
              groups.map(group => (
                <TableRow key={group.id}>
                  <TableCell className="px-6 py-4">
                    <div className="font-semibold flex items-center gap-2 text-foreground">
                      {group.name}
                      {group.isDefault && <Badge variant="secondary">Mặc định</Badge>}
                    </div>
                  </TableCell>
                  <TableCell className="px-6 text-muted-foreground">{group.description || <span className="italic text-muted-foreground/60">Chưa có mô tả</span>}</TableCell>
                  <TableCell className="px-6 font-medium text-foreground">
                    {group.priceType === 'PERCENTAGE' 
                      ? `Giảm ${group.discountPercent}% lẻ` 
                      : 'Bảng giá cố định'}
                  </TableCell>
                  <TableCell className="px-6 text-center">
                    <Badge variant="outline" className="font-semibold">
                      <Users className="h-3 w-3 mr-1" />
                      {group._count?.customers || 0}
                    </Badge>
                  </TableCell>
                  <TableCell className="px-6 text-right">
                    <div className="flex items-center justify-end gap-2">
                      <Button variant="outline" size="sm" onClick={() => handleOpenModal(group)} className="hover:text-primary transition-colors">
                        <Pencil className="mr-2 h-4 w-4" /> Cập nhật
                      </Button>
                      {user?.role === 'ADMIN' && (
                        <Button 
                          variant="outline" 
                          size="sm" 
                          onClick={() => setDeleteTarget({ id: group.id, name: group.name })} 
                          disabled={group.isDefault || (group._count?.customers || 0) > 0}
                          className="text-destructive hover:bg-destructive hover:text-destructive-foreground transition-colors"
                        >
                          <Trash2 className="h-4 w-4" />
                        </Button>
                      )}
                    </div>
                  </TableCell>
                </TableRow>
              ))
              )}
            </TableBody>
          </Table>
        </div>
        </CardContent>
      </Card>
      
      <CustomerGroupFormModal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        onSuccess={() => {
          setIsModalOpen(false);
          fetchGroups();
        }}
        group={selectedGroup}
      />

      <AlertDialog open={!!deleteTarget} onOpenChange={(open) => !open && !isDeleting && setDeleteTarget(null)}>
        <AlertDialogContent className="glass sm:max-w-[425px]">
          <AlertDialogHeader>
            <AlertDialogTitle className="flex items-center gap-2 text-destructive">
              <AlertCircle className="h-5 w-5" />
              Xác nhận xóa nhóm
            </AlertDialogTitle>
            <AlertDialogDescription className="pt-2 text-foreground/80">
              Bạn có chắc chắn muốn xóa nhóm <strong className="text-foreground">{deleteTarget?.name}</strong> khỏi hệ thống? Hành động này <strong>không thể hoàn tác</strong>.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter className="mt-4">
            <AlertDialogCancel disabled={isDeleting} className="hover:bg-muted/50 border-0 bg-transparent shadow-none">
              Hủy bỏ
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
