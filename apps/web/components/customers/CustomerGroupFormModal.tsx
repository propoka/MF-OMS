'use client';

import { useState, useEffect } from 'react';
import { crmApi, CustomerGroup } from '@/lib/api';
import { useAuth } from '@/lib/auth-context';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
  DialogDescription,
} from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Loader2, AlertCircle, Check, Tags } from 'lucide-react';

interface CustomerGroupFormModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSuccess: (group?: CustomerGroup) => void;
  group?: CustomerGroup | null; // Có data = Sửa, null = Thêm mới
}

export default function CustomerGroupFormModal({ isOpen, onClose, onSuccess, group }: CustomerGroupFormModalProps) {
  const { getToken } = useAuth();
  
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState('');

  // Form State
  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [priceType, setPriceType] = useState<'PERCENTAGE' | 'FIXED'>(group?.priceType as any || 'FIXED');

  useEffect(() => {
    if (isOpen) {
      if (group) {
        setName(group.name);
        setDescription(group.description || '');
        setPriceType(group.priceType || 'FIXED');
      } else {
        setName('');
        setDescription('');
        setPriceType('FIXED');
      }
      setError('');
    }
  }, [isOpen, group]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!name.trim()) return;
    
    setError('');
    setIsSubmitting(true);
    
    try {
      const token = getToken()!;
      const data = {
        name,
        description,
        priceType,
        // Khi tạo nhóm mới qua UI này, tự động thiết lập mặt định là FIXED
        discountPercent: 0
      };

      let savedGroup;
      if (group) {
        savedGroup = await crmApi.updateGroup(token, group.id, data);
      } else {
        savedGroup = await crmApi.createGroup(token, data);
      }
      
      onSuccess(savedGroup);
    } catch (err: any) {
      setError(err.message || 'Đã xảy ra lỗi khi lưu nhóm khách hàng');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <Dialog open={isOpen} onOpenChange={(open) => !open && onClose()}>
      <DialogContent className="sm:max-w-[600px] p-0 overflow-hidden">
        <DialogHeader className="px-6 py-4 border-b bg-muted/40">
          <DialogTitle className="text-xl">{group ? 'Cập nhật Nhóm Khách hàng' : 'Thêm Nhóm Khách hàng mới'}</DialogTitle>
          <DialogDescription>
            Điền thông tin bên dưới để thiết lập nhóm phân loại khách hàng và quy tắc giá.
          </DialogDescription>
        </DialogHeader>
        
        <form onSubmit={handleSubmit} className="px-6 py-4 max-h-[80vh] overflow-y-auto">
          {error && (
            <div className="p-3 mb-6 bg-destructive/10 text-destructive text-sm rounded-md flex items-center gap-2">
              <AlertCircle className="h-4 w-4" />
              {error}
            </div>
          )}
          
          <div className="space-y-6">
            <div className="flex items-center gap-2 text-foreground font-semibold">
              <Tags className="h-5 w-5 text-emerald-600" />
              <h3>Thông tin nhóm</h3>
            </div>
            
            <div className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="name">Tên nhóm <span className="text-destructive">*</span></Label>
                <Input 
                  id="name"
                  placeholder="VD: Sỉ cấp 1, Khách VIP..."
                  className="h-10 border-muted-foreground/20 shadow-sm"
                  value={name}
                  onChange={e => setName(e.target.value)}
                  required 
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="description">Mô tả (Tuỳ chọn)</Label>
                <Input 
                  id="description"
                  placeholder="Ghi chú về điều kiện áp dụng mức giá của nhóm này"
                  className="h-10 border-muted-foreground/20 shadow-sm"
                  value={description}
                  onChange={e => setDescription(e.target.value)}
                />
              </div>
            </div>
          </div>
          
          <DialogFooter className="pt-8 pb-2 mt-4 border-t">
            <Button type="button" variant="outline" onClick={onClose} disabled={isSubmitting}>
              Huỷ bỏ
            </Button>
            <Button type="submit" disabled={isSubmitting || !name} className="bg-emerald-600 hover:bg-emerald-700 text-white min-w-[140px]">
              {isSubmitting ? (
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
              ) : (
                <Check className="mr-2 h-4 w-4" />
              )}
              {group ? 'Lưu thay đổi' : 'Tạo nhóm mới'}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
}
