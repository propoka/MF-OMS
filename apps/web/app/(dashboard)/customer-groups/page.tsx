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
import { GlassCard } from '@/components/ui/glass-card';

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
        </div>
        <div className="flex items-center gap-3">
          <Button 
            onClick={() => handleOpenModal()}
            className="group relative overflow-hidden bg-neutral-900/85 hover:bg-black/90 backdrop-blur-xl text-white border border-white/20 hover:border-white/40 shadow-[0_8px_30px_rgb(0,0,0,0.12)] hover:shadow-[0_8px_30px_rgb(0,0,0,0.2)] transition-all duration-500 h-11 rounded-full px-6"
          >
            <div className="absolute inset-0 rounded-full ring-1 ring-inset ring-white/10 group-hover:ring-white/30 transition-all duration-500 pointer-events-none"></div>
            <Plus className="mr-2 h-5 w-5 group-hover:rotate-90 group-hover:scale-110 transition-all duration-500" />
            <span className="font-semibold text-sm">Tạo Nhóm Mới</span>
          </Button>
        </div>
      </div>

      <GlassCard className="mb-4">
        <div className="w-full overflow-auto custom-scrollbar">
          <Table>
            <TableHeader>
            <TableRow className="border-b border-border/40 hover:bg-transparent">
              <TableHead className="w-[250px] uppercase tracking-wider text-[11px] font-semibold text-muted-foreground pb-4 pl-6 lg:pl-8">Tên Nhóm</TableHead>
              <TableHead className="uppercase tracking-wider text-[11px] font-semibold text-muted-foreground pb-4">Mô tả</TableHead>
              <TableHead className="text-center uppercase tracking-wider text-[11px] font-semibold text-muted-foreground pb-4">Số lượng KH</TableHead>
              <TableHead className="text-right uppercase tracking-wider text-[11px] font-semibold text-muted-foreground pb-4 pr-6 lg:pr-8">Thao tác</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {isLoading ? (
              Array.from({ length: 3 }).map((_, i) => (
                <TableRow key={i} className="animate-pulse border-border/30">
                  <TableCell className="py-4 pl-6 lg:pl-8"><div className="h-4 bg-muted/50 rounded w-32"></div></TableCell>
                  <TableCell className="py-4"><div className="h-4 bg-muted/50 rounded w-48"></div></TableCell>
                  <TableCell className="py-4"><div className="h-4 bg-muted/50 rounded w-12 mx-auto"></div></TableCell>
                  <TableCell className="py-4 pr-6 lg:pr-8"><div className="h-8 bg-muted/50 rounded-lg w-16 ml-auto"></div></TableCell>
                </TableRow>
              ))
            ) : groups.length === 0 ? (
              <TableRow className="border-border/30">
                <TableCell colSpan={4} className="h-48 text-center">
                  <div className="flex flex-col items-center justify-center text-muted-foreground">
                    <Inbox className="h-10 w-10 mb-4 opacity-30" />
                    <p className="text-[13px] font-medium tracking-tight">Chưa có nhóm khách hàng nào.</p>
                  </div>
                </TableCell>
              </TableRow>
            ) : (
              groups.map(group => (
                <TableRow key={group.id} className="group hover:bg-muted/40 transition-colors border-border/30">
                  <TableCell className="py-4 align-top pl-6 lg:pl-8">
                    <div className="flex flex-col gap-1.5">
                      <span className="font-medium text-[13px] text-foreground tracking-tight whitespace-nowrap">
                        {group.name}
                      </span>
                      {group.isDefault && <span className="text-[10px] uppercase font-bold tracking-wider text-muted-foreground opacity-80 w-fit rounded bg-muted/50 px-1.5 py-0.5">Mặc định</span>}
                    </div>
                  </TableCell>
                  <TableCell className="py-4 align-top text-[13px] text-muted-foreground">{group.description || <span className="text-[11px] text-muted-foreground/60 font-medium">Chưa có mô tả</span>}</TableCell>
                  <TableCell className="py-4 align-top text-center">
                    <div className="flex items-center justify-center">
                      <Badge variant="outline" className="font-medium text-[11px] bg-muted/30 border-border/40 text-foreground px-2 flex items-center h-5">
                        <Users className="h-3 w-3 mr-1.5 opacity-70" />
                        {group._count?.customers || 0}
                      </Badge>
                    </div>
                  </TableCell>
                  <TableCell className="py-4 align-top pr-6 lg:pr-8 text-right">
                    <div className="flex items-center justify-end gap-2">
                      <button 
                        onClick={() => handleOpenModal(group)} 
                        className="h-8 w-8 rounded-lg shadow-sm border border-border/40 text-muted-foreground transition-all flex items-center justify-center hover:bg-white hover:text-primary"
                        title="Cập nhật"
                      >
                        <Pencil className="h-4 w-4" />
                      </button>
                      {user?.role === 'ADMIN' && (
                        <button 
                          onClick={() => setDeleteTarget({ id: group.id, name: group.name })} 
                          disabled={group.isDefault || (group._count?.customers || 0) > 0}
                          className="h-8 w-8 rounded-lg shadow-sm border border-border/40 text-muted-foreground transition-all flex items-center justify-center hover:bg-destructive/10 hover:text-destructive disabled:opacity-50 disabled:pointer-events-none"
                          title="Xóa"
                        >
                          <Trash2 className="h-4 w-4" />
                        </button>
                      )}
                    </div>
                  </TableCell>
                </TableRow>
              ))
              )}
            </TableBody>
          </Table>
        </div>
      </GlassCard>
      
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
