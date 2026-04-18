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
      <DialogContent className="sm:max-w-[600px] p-0 border border-white/80 shadow-2xl overflow-hidden rounded-[24px] bg-[#fcfbfb] backdrop-blur-2xl">
        <DialogHeader className="px-6 py-5 border-b border-black/5">
          <DialogTitle className="text-2xl font-bold tracking-tight text-foreground flex items-center gap-2">
            {group ? 'Cập nhật Nhóm Khách hàng' : 'Thêm Nhóm Khách hàng mới'}
          </DialogTitle>
          <DialogDescription className="text-foreground/70 text-[13px] font-medium tracking-tight">
            Điền thôngত্তিn bên dưới để thiết lập nhóm phân loại khách hàng và quy tắc giá.
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
              <div className="p-1.5 rounded-lg bg-primary/10 text-primary border border-primary/20">
                <Tags className="h-4 w-4" />
              </div>
              <h3 className="text-[14px]">Thông tin nhóm</h3>
            </div>
            
            <div className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="name" className="text-[12px] font-bold tracking-tight text-foreground/80">Tên nhóm <span className="text-destructive">*</span></Label>
                <Input 
                  id="name"
                  placeholder="VD: Sỉ cấp 1, Khách VIP..."
                  className="h-11 px-4 border-black/5 bg-white focus-visible:border-primary focus-visible:ring-1 focus-visible:ring-primary/20 rounded-2xl transition-all w-full text-[13px] tracking-tight font-medium placeholder:font-medium placeholder:text-muted-foreground/50"
                  value={name}
                  onChange={e => setName(e.target.value)}
                  required 
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="description" className="text-[12px] font-bold tracking-tight text-foreground/80">Mô tả (Tuỳ chọn)</Label>
                <Input 
                  id="description"
                  placeholder="Ghi chú về điều kiện áp dụng mức giá của nhóm này"
                  className="h-11 px-4 border-black/5 bg-white focus-visible:border-primary focus-visible:ring-1 focus-visible:ring-primary/20 rounded-2xl transition-all w-full text-[13px] tracking-tight font-medium placeholder:font-medium placeholder:text-muted-foreground/50"
                  value={description}
                  onChange={e => setDescription(e.target.value)}
                />
              </div>
            </div>
          </div>
          
          <DialogFooter className="px-6 py-4 border-t border-black/5 bg-transparent m-0 flex items-center justify-end gap-3 mt-8">
            <Button type="button" variant="outline" onClick={onClose} disabled={isSubmitting} className="h-11 rounded-2xl px-6 bg-white border-black/10 hover:bg-neutral-100 shadow-sm text-[13px] font-bold tracking-tight transition-all">
              Huỷ bỏ
            </Button>
            <Button type="submit" disabled={isSubmitting || !name} className="group relative overflow-hidden bg-neutral-900/85 hover:bg-black/90 backdrop-blur-xl text-white border border-white/20 hover:border-white/40 shadow-[0_8px_30px_rgb(0,0,0,0.12)] hover:shadow-[0_8px_30px_rgb(0,0,0,0.2)] transition-all duration-500 font-bold px-8 h-11 rounded-2xl">
              {isSubmitting ? (
                <Loader2 className="mr-2 h-4 w-4 animate-spin opacity-80" />
              ) : (
                <Check className="mr-2 h-4 w-4 opacity-80 group-hover:scale-110 transition-all duration-500" />
              )}
              <span className="relative z-10 text-[13px] tracking-tight">{group ? 'Lưu thay đổi' : 'Tạo nhóm mới'}</span>
              <div className="absolute inset-0 rounded-2xl ring-1 ring-inset ring-white/10 group-hover:ring-white/30 transition-all duration-500 pointer-events-none"></div>
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
}
