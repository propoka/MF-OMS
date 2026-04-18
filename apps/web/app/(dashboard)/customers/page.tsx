'use client';

import { useState, useEffect, useCallback } from 'react';
import { crmApi, Customer } from '@/lib/api';
import { useAuth } from '@/lib/auth-context';
import CustomerFormModal from '@/components/customers/CustomerFormModal';
import Link from 'next/link';
import { 
  Table, 
  TableBody, 
  TableCell, 
  TableHead, 
  TableHeader, 
  TableRow 
} from '@/components/ui/table';
import { Card, CardContent } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Search, Plus, FileSpreadsheet, Inbox, Eye, ChevronLeft, ChevronRight, ArrowRight, Trash2, Loader2 } from 'lucide-react';
import { GlassCard } from '@/components/ui/glass-card';
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

export default function CustomersPage() {
  const { getToken, user } = useAuth();
  const [customers, setCustomers] = useState<Customer[]>([]);
  const [total, setTotal] = useState(0);
  const [isLoading, setIsLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [customerToDelete, setCustomerToDelete] = useState<string | null>(null);
  const [isDeleting, setIsDeleting] = useState(false);

  const [page, setPage] = useState(1);
  const limit = 50;

  const fetchCustomers = useCallback(async () => {
    try {
      setIsLoading(true);
      const token = getToken();
      if (!token) return;

      const skip = (page - 1) * limit;
      const res = await crmApi.getCustomers(token, { search, skip, take: limit });
      setCustomers(res.data);
      setTotal(res.total);
    } catch (err) {
      console.error(err);
    } finally {
      setIsLoading(false);
    }
  }, [getToken, search, page]);

  // Reset trang về 1 khi search thay đổi
  useEffect(() => {
    setPage(1);
  }, [search]);

  useEffect(() => {
    const timer = setTimeout(() => {
      fetchCustomers();
    }, 300);
    return () => clearTimeout(timer);
  }, [fetchCustomers]);

  const formatMoney = (amount: number) => {
    return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(amount);
  };

  const handleDeleteCustomer = async () => {
    if (!customerToDelete) return;
    try {
      setIsDeleting(true);
      await crmApi.deleteCustomer(getToken()!, customerToDelete);
      toast.success('Đã xoá khách hàng thành công.');
      setCustomerToDelete(null);
      fetchCustomers();
    } catch (e: any) {
      toast.error(e.message || 'Không thể xoá khách hàng này.');
    } finally {
      setIsDeleting(false);
    }
  };

  return (
    <div className="flex flex-col gap-6 pb-4">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold tracking-tight text-foreground flex items-center gap-2">Khách hàng</h1>
        </div>
        <div className="flex items-center gap-3">
          <Button 
            onClick={() => setIsModalOpen(true)}
            className="group relative overflow-hidden bg-neutral-900/85 hover:bg-black/90 backdrop-blur-xl text-white border border-white/20 hover:border-white/40 shadow-[0_8px_30px_rgb(0,0,0,0.12)] hover:shadow-[0_8px_30px_rgb(0,0,0,0.2)] transition-all duration-500 font-bold px-6 h-11 rounded-full"
          >
            <Plus className="mr-2 h-5 w-5 opacity-80 group-hover:rotate-90 group-hover:scale-110 transition-all duration-500" />
            <span>Thêm Khách hàng</span>
            <div className="absolute inset-0 rounded-full ring-1 ring-inset ring-white/10 group-hover:ring-white/30 transition-all duration-500 pointer-events-none"></div>
          </Button>
        </div>
      </div>

      {/* FILTER ACTION DOCK */}
      <GlassCard className="mb-6 border border-white/40 shadow-sm shadow-black/5 rounded-[24px] bg-white/40 backdrop-blur-xl p-2" contentClassName="p-0 flex flex-col xl:flex-row gap-3 items-center justify-between w-full border-none shadow-none bg-transparent">
        <div className="flex flex-col lg:flex-row gap-2 lg:gap-3 items-center w-full xl:w-auto flex-1">
          <div className="relative flex-1 w-full max-w-md">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
            <Input
              placeholder="Tìm theo Tên, Mã KH hoặc SĐT..."
              className="pl-9 h-11 border-white/40 bg-white/50 shadow-sm focus-visible:border-primary rounded-xl transition-all w-full text-[13px] tracking-tight font-medium placeholder:font-medium placeholder:text-muted-foreground/70"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
            />
          </div>
        </div>
        
        <div className="flex items-center gap-2 shrink-0 bg-white/50 border border-white/40 rounded-xl shadow-sm h-11 px-4 self-end xl:self-auto">
          <span className="text-[13px] font-medium text-muted-foreground whitespace-nowrap">Tổng hồ sơ</span>
          <span className="font-bold text-[14px] text-foreground">{total}</span>
        </div>
      </GlassCard>

      {/* DATATABLE */}
      <GlassCard className="mb-4">
        <div className="w-full overflow-auto custom-scrollbar">
          <Table>
            <TableHeader>
              <TableRow className="border-b border-border/40 hover:bg-transparent">
                <TableHead className="w-[300px] pl-6 lg:pl-8 uppercase tracking-wider text-[11px] font-semibold text-muted-foreground pb-4">Khách hàng</TableHead>
                <TableHead className="uppercase tracking-wider text-[11px] font-semibold text-muted-foreground pb-4">Số điện thoại</TableHead>
                <TableHead className="uppercase tracking-wider text-[11px] font-semibold text-muted-foreground pb-4">Nhóm / Bảng giá</TableHead>
                <TableHead className="uppercase tracking-wider text-[11px] font-semibold text-muted-foreground pb-4">Doanh số</TableHead>
                <TableHead className="text-right pr-6 lg:pr-8 uppercase tracking-wider text-[11px] font-semibold text-muted-foreground pb-4">Thao tác</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {isLoading ? (
                Array.from({ length: 5 }).map((_, i) => (
                  <TableRow key={i} className="animate-pulse">
                    <TableCell className="pl-6 lg:pl-8 py-4"><div className="h-4 bg-muted rounded w-3/4 mb-2"></div><div className="h-3 bg-muted rounded w-1/2"></div></TableCell>
                    <TableCell className="py-4"><div className="h-4 bg-muted rounded w-24"></div></TableCell>
                    <TableCell className="py-4"><div className="h-5 bg-muted rounded w-20"></div></TableCell>
                    <TableCell className="py-4"><div className="h-4 bg-muted rounded w-24"></div></TableCell>
                    <TableCell className="pr-6 lg:pr-8 py-4"><div className="h-8 bg-muted rounded w-16 ml-auto"></div></TableCell>
                  </TableRow>
                ))
              ) : customers.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={5} className="h-48 text-center">
                    <div className="flex flex-col items-center justify-center text-muted-foreground">
                      <Inbox className="h-10 w-10 mb-4 opacity-50" />
                      <p>Quản lý danh sách khách hàng dễ dàng hơn.</p>
                      <p>Bấm "Thêm Khách hàng" để bắt đầu.</p>
                    </div>
                  </TableCell>
                </TableRow>
              ) : (
                customers.map((c) => (
                  <TableRow key={c.id} className="group hover:bg-muted/40 transition-colors border-border/30">
                    <TableCell className="pl-6 lg:pl-8 py-4 align-top">
                      <div className="flex flex-col gap-1.5">
                        <div className="flex items-center gap-2">
                          <Link href={`/customers/${c.id}`} className="group/link flex items-center gap-1 font-medium text-[13px] text-foreground hover:text-primary transition-colors whitespace-nowrap w-fit">
                            <span>{c.fullName}</span>
                            <ArrowRight className="w-3.5 h-3.5 opacity-0 -translate-x-2 group-hover/link:opacity-100 group-hover/link:translate-x-0 transition-all duration-300" />
                          </Link>
                          {c.code && c.code.length < 25 && (
                            <Badge variant="outline" className="text-[10px] h-5 px-1.5 font-mono bg-muted/50 text-muted-foreground border-border/40">
                              {c.code}
                            </Badge>
                          )}
                        </div>
                        <div className="text-[11px] text-muted-foreground font-medium truncate max-w-[250px]" title={c.addressDetail || 'Chưa cập nhật địa chỉ'}>
                          {c.addressDetail || 'Chưa có địa chỉ'}
                        </div>
                      </div>
                    </TableCell>
                    <TableCell className="align-top py-4">
                      <span className="font-medium text-[13px] text-foreground tracking-tight">
                        {c.phone ? c.phone : <span className="text-[11px] text-muted-foreground/60 font-medium tracking-normal">Chưa có SĐT</span>}
                      </span>
                    </TableCell>
                    <TableCell className="align-top py-4">
                      {c.group ? (
                        <Badge variant="secondary" className="font-medium text-[11px] bg-muted text-muted-foreground border-transparent">
                          {c.group.name} {c.group.priceType === 'PERCENTAGE' && c.group.discountPercent ? `(-${c.group.discountPercent}%)` : ''}
                        </Badge>
                      ) : (
                        <span className="text-muted-foreground text-[11px] font-medium">Không có nhóm</span>
                      )}
                    </TableCell>
                    <TableCell className="align-top py-4">
                      <span className="font-bold text-[14px] text-[oklch(0.40_0.06_45)] tracking-tight whitespace-nowrap">
                        {formatMoney(c.totalRevenue || 0)}
                      </span>
                    </TableCell>
                    <TableCell className="text-right align-top py-4 pr-6 lg:pr-8">
                      <div className="flex justify-end gap-1.5 opacity-80 group-hover:opacity-100 transition-opacity">
                        <Link href={`/customers/${c.id}`}>
                          <Button variant="ghost" size="icon" className="h-8 w-8 rounded-lg hover:bg-white shadow-sm border border-border/40 text-muted-foreground hover:text-primary transition-all" title="Chi tiết">
                            <Eye className="h-4 w-4" />
                          </Button>
                        </Link>
                        {user?.role === 'ADMIN' && (
                          <Button variant="ghost" size="icon" onClick={() => setCustomerToDelete(c.id)} className="h-8 w-8 rounded-lg hover:bg-destructive/10 shadow-sm border border-border/40 text-muted-foreground hover:text-destructive transition-all" title="Xoá khách hàng">
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
      </GlassCard>

      {total > limit && (
        <div className="flex items-center justify-between pt-2">
          <div className="text-sm text-muted-foreground">
            Hiển thị {((page - 1) * limit) + 1} - {Math.min(page * limit, total)} trên tổng {total} hồ sơ
          </div>
          <div className="flex items-center gap-4">
            <Button
              variant="outline"
              size="sm"
              onClick={() => setPage(p => Math.max(1, p - 1))}
              disabled={page === 1 || isLoading}
            >
              <ChevronLeft className="h-4 w-4 mr-1" /> Trước
            </Button>
            <div className="text-sm font-medium">Trang {page} / {Math.ceil(total / limit) || 1}</div>
            <Button
              variant="outline"
              size="sm"
              onClick={() => setPage(p => p + 1)}
              disabled={page >= Math.ceil(total / limit) || isLoading}
            >
              Sau <ChevronRight className="h-4 w-4 ml-1" />
            </Button>
          </div>
        </div>
      )}

      <CustomerFormModal 
        isOpen={isModalOpen} 
        onClose={() => setIsModalOpen(false)} 
        onSuccess={() => {
          setIsModalOpen(false);
          fetchCustomers();
        }}
      />

      {/* MODAL DELETE */}
      <AlertDialog open={!!customerToDelete} onOpenChange={(open) => !open && setCustomerToDelete(null)}>
        {(() => {
          const target = customers.find(c => c.id === customerToDelete);
          return (
            <AlertDialogContent className="glass sm:max-w-[400px] border-border/40 shadow-2xl p-6">
              <AlertDialogHeader className="flex flex-col items-center text-center space-y-4">
                <div className="w-14 h-14 rounded-full bg-red-700/10 flex items-center justify-center shrink-0">
                  <Trash2 className="w-7 h-7 text-red-700" />
                </div>
                <div className="space-y-2">
                  <AlertDialogTitle className="text-xl font-bold text-foreground">
                    Xóa hồ sơ khách hàng?
                  </AlertDialogTitle>
                  <AlertDialogDescription className="text-foreground/80 leading-relaxed text-sm">
                    Bạn đang thao tác xoá khách hàng <span className="font-bold text-foreground">{target?.fullName}</span>{target?.phone ? ` (SĐT: ${target?.phone})` : ''}.
                    <br/><br/>
                    Việc này có thể xoá bỏ toàn bộ lịch sử mua hàng, công nợ hoặc dữ liệu điểm thưởng của khách hàng và <strong className="text-foreground font-semibold">không thể khôi phục</strong>.
                  </AlertDialogDescription>
                </div>
              </AlertDialogHeader>
              <AlertDialogFooter className="sm:justify-center flex-row gap-3 pt-6 w-full">
                <AlertDialogCancel className="flex-1 text-foreground font-semibold hover:bg-muted/50 border border-border/60 bg-white/50 m-0 shadow-sm transition-all" disabled={isDeleting}>
                  Hủy bỏ
                </AlertDialogCancel>
                <AlertDialogAction onClick={() => { handleDeleteCustomer(); }} className="flex-1 bg-red-700 text-white hover:bg-red-800 shadow-[0_0_15px_rgba(185,28,28,0.25)] hover:shadow-[0_0_20px_rgba(185,28,28,0.4)] transition-all duration-300 m-0" disabled={isDeleting}>
                  {isDeleting ? (
                    <span className="flex items-center gap-2">
                      <Loader2 className="w-4 h-4 animate-spin" />
                      Khai tử...
                    </span>
                  ) : 'Xác nhận Xóa'}
                </AlertDialogAction>
              </AlertDialogFooter>
            </AlertDialogContent>
          );
        })()}
      </AlertDialog>
    </div>
  );
}
