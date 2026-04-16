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
import { Search, Plus, FileSpreadsheet, Inbox, Eye, ChevronLeft, ChevronRight } from 'lucide-react';

export default function CustomersPage() {
  const { getToken } = useAuth();
  const [customers, setCustomers] = useState<Customer[]>([]);
  const [total, setTotal] = useState(0);
  const [isLoading, setIsLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [isModalOpen, setIsModalOpen] = useState(false);

  const [page, setPage] = useState(1);
  const limit = 10;

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

  return (
    <div className="flex flex-col gap-6 pb-4">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold tracking-tight text-foreground">Khách hàng</h1>
        </div>
        <div className="flex items-center gap-3">
          <Button 
            onClick={() => setIsModalOpen(true)}
            className="shadow-md hover:shadow-lg transition-all duration-200 font-semibold px-5"
          >
            <Plus className="mr-2 h-5 w-5" />
            Thêm Khách hàng
          </Button>
        </div>
      </div>

      <Card className="glass shadow-sm border-muted/50 overflow-hidden">
        <CardContent className="p-0">
          <div className="p-6 border-b border-muted/30 flex items-center bg-muted/10">
            <div className="relative flex-1 max-w-md shadow-sm">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
              <Input
                placeholder="Tìm theo Tên, Mã KH hoặc SĐT..."
                className="pl-9 border-muted-foreground/30 bg-background h-10 transition-colors focus-visible:border-primary"
                value={search}
                onChange={(e) => setSearch(e.target.value)}
              />
            </div>
          </div>
          <div className="w-full overflow-auto">
        <Table>
          <TableHeader className="bg-muted/50">
            <TableRow>
              <TableHead className="w-[300px] px-6 text-foreground font-semibold">Khách hàng</TableHead>
              <TableHead className="px-6 text-foreground font-semibold">Số điện thoại</TableHead>
              <TableHead className="px-6 text-foreground font-semibold">Nhóm / Bảng giá</TableHead>
              <TableHead className="px-6 text-foreground font-semibold">Doanh số</TableHead>
              <TableHead className="text-right px-6 text-foreground font-semibold">Thao tác</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {isLoading ? (
              Array.from({ length: 5 }).map((_, i) => (
                <TableRow key={i} className="animate-pulse">
                  <TableCell className="px-6"><div className="h-4 bg-muted rounded w-3/4 mb-2"></div><div className="h-3 bg-muted rounded w-1/2"></div></TableCell>
                  <TableCell className="px-6"><div className="h-4 bg-muted rounded w-24"></div></TableCell>
                  <TableCell className="px-6"><div className="h-5 bg-muted rounded w-20"></div></TableCell>
                  <TableCell className="px-6"><div className="h-4 bg-muted rounded w-24"></div></TableCell>
                  <TableCell className="px-6"><div className="h-8 bg-muted rounded w-16 ml-auto"></div></TableCell>
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
                <TableRow key={c.id}>
                  <TableCell className="px-6 py-4">
                    <div className="flex items-center gap-2 mb-1">
                      <span className="font-medium text-foreground">{c.fullName}</span>
                      {c.code && (
                        <Badge variant="outline" className="text-[10px] h-5 px-1.5 font-mono bg-muted/50 text-muted-foreground">
                          {c.code}
                        </Badge>
                      )}
                    </div>
                    <div className="text-xs text-muted-foreground truncate max-w-[250px]" title={c.addressDetail || 'Chưa cập nhật địa chỉ'}>
                      {c.addressDetail || 'Chưa có địa chỉ'}
                    </div>
                  </TableCell>
                  <TableCell className="px-6 font-medium text-muted-foreground">
                    {c.phone ? c.phone : <span className="italic text-muted-foreground/50 text-sm">Chưa có SĐT</span>}
                  </TableCell>
                  <TableCell className="px-6">
                    {c.group ? (
                      <Badge variant="secondary" className="font-medium">
                        {c.group.name} {c.group.priceType === 'PERCENTAGE' && c.group.discountPercent ? `(-${c.group.discountPercent}%)` : ''}
                      </Badge>
                    ) : (
                      <span className="text-muted-foreground italic text-sm">Không có nhóm</span>
                    )}
                  </TableCell>
                  <TableCell className="px-6 font-medium text-primary">
                    {formatMoney(c.totalRevenue || 0)}
                  </TableCell>
                  <TableCell className="px-6 text-right">
                    <Link href={`/customers/${c.id}`}>
                      <Button variant="outline" size="sm" className="hover:text-primary transition-colors">
                        <Eye className="mr-2 h-4 w-4" /> Chi tiết
                      </Button>
                    </Link>
                  </TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
        </div>
        </CardContent>
      </Card>

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
    </div>
  );
}
