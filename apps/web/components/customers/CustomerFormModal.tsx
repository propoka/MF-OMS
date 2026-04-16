'use client';

import { useState, useEffect, useRef } from 'react';
import { CustomerGroup, crmApi, addressApi } from '@/lib/api';
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
import { Loader2, AlertCircle, Search, Check, ChevronDown, User, MapPin } from 'lucide-react';

const SearchableSelect = ({
  options,
  value,
  onChange,
  placeholder,
  disabled
}: {
  options: { code: string; name: string }[];
  value: string;
  onChange: (val: string) => void;
  placeholder: string;
  disabled?: boolean;
}) => {
  const [open, setOpen] = useState(false);
  const [search, setSearch] = useState('');
  const containerRef = useRef<HTMLDivElement>(null);
  
  useEffect(() => {
    const handleOutsideClick = (event: MouseEvent) => {
      if (containerRef.current && !containerRef.current.contains(event.target as Node)) {
        setOpen(false);
      }
    };
    if (open) document.addEventListener('mousedown', handleOutsideClick);
    return () => document.removeEventListener('mousedown', handleOutsideClick);
  }, [open]);

  const filtered = options.filter(o => o.name.toLowerCase().includes(search.toLowerCase()));
  const selectedName = options.find(o => o.code === value)?.name || '';

  return (
    <div className="relative w-full" ref={containerRef}>
      <button
        type="button"
        disabled={disabled}
        onClick={() => setOpen(!open)}
        className="flex h-10 w-full items-center justify-between rounded-md border border-input bg-background px-3 py-2 text-sm shadow-sm transition-colors hover:bg-muted focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:cursor-not-allowed disabled:opacity-50"
      >
        <span className={`truncate ${!selectedName ? 'text-muted-foreground' : 'text-foreground'}`}>
          {selectedName || placeholder}
        </span>
        <ChevronDown className="h-4 w-4 opacity-50" />
      </button>
      
      {open && (
        <div className="absolute z-50 mt-1 w-full rounded-md border bg-popover text-popover-foreground shadow-md animate-in fade-in-80 zoom-in-95">
          <div className="flex items-center border-b px-3">
            <Search className="mr-2 h-4 w-4 shrink-0 opacity-50" />
            <input
              className="flex h-10 w-full rounded-md bg-transparent py-3 text-sm outline-none placeholder:text-muted-foreground"
              placeholder="Tìm kiếm nhanh..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              autoFocus
            />
          </div>
          <div className="max-h-60 overflow-y-auto p-1">
            {filtered.length === 0 ? (
              <p className="py-6 text-center text-sm text-muted-foreground">Không tìm thấy kết quả.</p>
            ) : (
              filtered.map((opt) => (
                <div
                  key={opt.code}
                  className={`relative flex w-full cursor-pointer select-none items-center rounded-sm py-2 pl-8 pr-2 text-sm outline-none hover:bg-accent hover:text-accent-foreground ${value === opt.code ? 'bg-accent text-accent-foreground font-medium' : ''}`}
                  onClick={() => {
                    onChange(opt.code);
                    setOpen(false);
                    setSearch('');
                  }}
                >
                  <span className="absolute left-2 flex h-3.5 w-3.5 items-center justify-center">
                    {value === opt.code && <Check className="h-4 w-4 text-emerald-600" />}
                  </span>
                  {opt.name}
                </div>
              ))
            )}
          </div>
        </div>
      )}
    </div>
  );
};

interface CustomerFormModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSuccess: (customer?: any) => void;
  customer?: any; // The customer object being edited
}

export default function CustomerFormModal({ isOpen, onClose, onSuccess, customer }: CustomerFormModalProps) {
  const { getToken } = useAuth();
  
  const [groups, setGroups] = useState<CustomerGroup[]>([]);
  const [isLoadingGroups, setIsLoadingGroups] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState('');

  // Form State
  const [fullName, setFullName] = useState('');
  const [phone, setPhone] = useState('');
  const [groupId, setGroupId] = useState('');
  const [provinceCode, setProvinceCode] = useState('');
  const [wardCode, setWardCode] = useState('');
  const [addressDetail, setAddressDetail] = useState('');
  
  // Data Tỉnh/Huyện
  const [provinces, setProvinces] = useState<{code: string; name: string}[]>([]);
  const [wards, setWards] = useState<{code: string; name: string}[]>([]);

  const selectedProvinceName = provinces.find(p => p.code === provinceCode)?.name || '';
  const selectedWardName = wards.find(w => w.code === wardCode)?.name || '';

  // Load Provinces & Sort A-Z
  useEffect(() => {
    if (isOpen) {
      addressApi.getProvinces().then(data => {
        const sorted = [...data].sort((a,b) => a.name.localeCompare(b.name, 'vi'));
        setProvinces(sorted);
      }).catch(console.error);
    }
  }, [isOpen]);

  // Load existing customer data if editing
  useEffect(() => {
    if (isOpen) {
      if (customer) {
        setFullName(customer.fullName || '');
        setPhone(customer.phone || '');
        setGroupId(customer.groupId || '');
        setProvinceCode(customer.provinceCode || '');
        setWardCode(customer.wardCode || '');
        setAddressDetail(customer.addressDetail || '');
      } else {
        setFullName('');
        setPhone('');
        setProvinceCode('');
        setWardCode('');
        setAddressDetail('');
        // NOTE: groupId is set in groups load effect
      }
      setError('');
    }
  }, [isOpen, customer]);

  // Load Wards/Districts and Sort A-Z
  useEffect(() => {
    if (provinceCode) {
      addressApi.getDistricts(provinceCode).then(data => {
        const sorted = [...data].sort((a,b) => a.name.localeCompare(b.name, 'vi'));
        setWards(sorted);
      }).catch(console.error);
    } else {
      setWards([]);
    }
    setWardCode('');
  }, [provinceCode]);

  useEffect(() => {
    if (isOpen && groups.length === 0) {
      const loadGroups = async () => {
        setIsLoadingGroups(true);
        try {
          const res = await crmApi.getGroups(getToken()!);
          setGroups(res);
          const defGroup = res.find(g => g.isDefault);
          if (defGroup) setGroupId(defGroup.id);
          else if (res.length > 0) setGroupId(res[0].id);
        } catch (e) {
          console.error(e);
        } finally {
          setIsLoadingGroups(false);
        }
      };
      loadGroups();
    }
  }, [isOpen, groups.length, getToken]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!fullName || !groupId) return;
    
    setError('');
    setIsSubmitting(true);
    
    try {
      const token = getToken();
      if (!token) throw new Error("Chưa xác thực");

      const payload = {
        fullName,
        ...(phone.trim() !== '' ? { phone: phone.trim() } : {}),
        groupId,
        provinceCode,
        provinceName: selectedProvinceName || undefined,
        wardCode,
        wardName: selectedWardName || undefined,
        addressDetail
      };

      if (customer) {
        const updated = await crmApi.updateCustomer(token, customer.id, payload);
        onSuccess(updated);
      } else {
        const res = await fetch(`${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'}/api/customers`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}`
          },
          body: JSON.stringify(payload),
        });
        const data = await res.json();
        if (!res.ok) throw new Error(data.message || 'Đã xảy ra lỗi khi tạo khách hàng');
        onSuccess(data);
      }
    } catch (err: any) {
      setError(err.message || 'Lỗi lưu thông tin');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <Dialog open={isOpen} onOpenChange={(open) => !open && onClose()}>
      <DialogContent className="sm:max-w-[700px] p-0 overflow-hidden">
        <DialogHeader className="px-6 py-4 border-b bg-muted/40">
          <DialogTitle className="text-xl">{customer ? 'Cập nhật Khách hàng' : 'Thêm Khách hàng mới'}</DialogTitle>
          <DialogDescription>
            Điền đầy đủ thông tin bên dưới để {customer ? 'cập nhật' : 'tạo'} hồ sơ quản lý khách hàng.
          </DialogDescription>
        </DialogHeader>
        
        <form onSubmit={handleSubmit} className="px-6 py-4 max-h-[80vh] overflow-y-auto">
          {error && (
            <div className="p-3 mb-6 bg-destructive/10 text-destructive text-sm rounded-md flex items-center gap-2">
              <AlertCircle className="h-4 w-4" />
              {error}
            </div>
          )}
          
          <div className="space-y-8">
            {/* Sec 1: Thông tin liên hệ */}
            <div className="space-y-4">
              <div className="flex items-center gap-2 text-foreground font-semibold">
                <User className="h-5 w-5 text-emerald-600" />
                <h3>Thông tin liên lạc</h3>
              </div>
              
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="fullName">Họ và tên <span className="text-destructive">*</span></Label>
                  <Input 
                    id="fullName"
                    placeholder="Nhập họ và tên..."
                    className="h-10 border-muted-foreground/20 shadow-sm"
                    value={fullName}
                    onChange={e => setFullName(e.target.value)}
                    required 
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="phone">Số điện thoại</Label>
                  <Input 
                    id="phone"
                    type="tel" 
                    placeholder="VD: 0901234567" 
                    className="h-10 border-muted-foreground/20 shadow-sm"
                    value={phone}
                    onChange={e => setPhone(e.target.value)}
                  />
                </div>
              </div>

              <div className="space-y-2">
                <Label htmlFor="groupId">Nhóm khách hàng <span className="text-destructive">*</span></Label>
                <select 
                  id="groupId"
                  disabled={isLoadingGroups} 
                  value={groupId} 
                  onChange={(e) => setGroupId(e.target.value)}
                  className="flex h-10 w-full rounded-md border border-muted-foreground/20 bg-background px-3 py-1 text-sm shadow-sm transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:cursor-not-allowed disabled:opacity-50"
                >
                  <option value="" disabled>Chọn nhóm báo giá...</option>
                  {groups.map(g => (
                    <option key={g.id} value={g.id}>{g.name}</option>
                  ))}
                </select>
              </div>
            </div>

            {/* Sec 2: Địa chỉ */}
            <div className="space-y-4">
              <div className="flex items-center gap-2 text-foreground font-semibold">
                <MapPin className="h-5 w-5 text-emerald-600" />
                <h3>Khu vực & Địa chỉ</h3>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="provinceCode">Tỉnh / Thành phố </Label>
                  <SearchableSelect 
                    options={provinces}
                    value={provinceCode}
                    onChange={setProvinceCode}
                    placeholder="Chọn Tỉnh/Thành phố"
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="wardCode">Quận / Huyện</Label>
                  <SearchableSelect 
                    options={wards}
                    value={wardCode}
                    onChange={setWardCode}
                    placeholder="Chọn Quận/Huyện"
                    disabled={!provinceCode}
                  />
                </div>
              </div>
              
              <div className="space-y-2">
                <Label htmlFor="addressDetail">Địa chỉ chi tiết (Không bắt buộc)</Label>
                <Input 
                  id="addressDetail"
                  placeholder="Số nhà, tên đường, tên toà nhà..." 
                  className="h-10 border-muted-foreground/20 shadow-sm"
                  value={addressDetail}
                  onChange={e => setAddressDetail(e.target.value)}
                />
              </div>
            </div>
          </div>
          
          <DialogFooter className="pt-8 pb-2 mt-4 border-t">
            <Button type="button" variant="outline" onClick={onClose} disabled={isSubmitting}>
              Huỷ bỏ
            </Button>
            <Button type="submit" disabled={isSubmitting || !fullName || !groupId} className="bg-emerald-600 hover:bg-emerald-700 text-white min-w-[140px]">
              {isSubmitting ? (
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
              ) : (
                <Check className="mr-2 h-4 w-4" />
              )}
              Lưu khách hàng
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
}
