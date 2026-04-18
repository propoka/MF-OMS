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
import { createPortal } from 'react-dom';

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
  const dropdownRef = useRef<HTMLDivElement>(null);
  const [dropdownStyle, setDropdownStyle] = useState<React.CSSProperties>({ top: 0, left: 0, width: 0 });
  
  useEffect(() => {
    const handleOutsideClick = (event: MouseEvent) => {
      if (
        containerRef.current?.contains(event.target as Node) || 
        dropdownRef.current?.contains(event.target as Node)
      ) {
        return;
      }
      setOpen(false);
    };
    
    // Auto-close on any scroll to securely anchor portal, BUT ignore internal scrolling
    const handleScrollOrResize = (event: Event) => {
      if (
        open && 
        dropdownRef.current && 
        event.target instanceof Node && 
        dropdownRef.current.contains(event.target)
      ) {
        return; // Ignore scroll events inside the dropdown list itself
      }
      if (open) setOpen(false);
    };

    if (open) {
      document.addEventListener('mousedown', handleOutsideClick);
      window.addEventListener('scroll', handleScrollOrResize, true); 
      window.addEventListener('resize', handleScrollOrResize);
    }
    
    return () => {
      document.removeEventListener('mousedown', handleOutsideClick);
      window.removeEventListener('scroll', handleScrollOrResize, true);
      window.removeEventListener('resize', handleScrollOrResize);
    };
  }, [open]);

  const toggleDropdown = () => {
    if (!open && containerRef.current) {
      const rect = containerRef.current.getBoundingClientRect();
      const availableSpaceBottom = window.innerHeight - rect.bottom;
      
      let style: React.CSSProperties = {
        left: rect.left,
        width: rect.width,
        top: rect.bottom + 6,
      };

      // Smart positioning: switch to drop upwards if bottom hits clamp
      if (availableSpaceBottom < 320 && rect.top > 320) {
        style = {
           left: rect.left,
           width: rect.width,
           bottom: window.innerHeight - rect.top + 6,
        };
      }

      setDropdownStyle(style);
      setSearch(''); 
    }
    setOpen(!open);
  };

  const filtered = options.filter(o => o.name.toLowerCase().includes(search.toLowerCase()));
  const selectedName = options.find(o => o.code === value)?.name || '';

  const dropdownContent = (
    <div 
      ref={dropdownRef}
      style={dropdownStyle}
      className="fixed z-[9999] rounded-2xl border border-black/10 bg-white/95 backdrop-blur-3xl p-2 text-foreground shadow-2xl animate-in fade-in-80 zoom-in-95"
    >
      <div className="flex items-center border-b border-black/5 px-2 pb-2">
        <Search className="mr-2 h-4 w-4 shrink-0 text-muted-foreground" />
        <input
          className="flex h-10 w-full rounded-md bg-transparent text-[13px] font-medium tracking-tight outline-none placeholder:text-muted-foreground/70"
          placeholder="Tìm kiếm nhanh..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          autoFocus
        />
      </div>
      <div className="max-h-[250px] overflow-y-auto custom-scrollbar mt-2 pr-1">
        {filtered.length === 0 ? (
          <p className="py-6 text-center text-[13px] text-muted-foreground/70 font-medium tracking-tight">Không tìm thấy kết quả.</p>
        ) : (
          filtered.map((opt) => (
            <div
              key={opt.code}
              className={`relative flex w-full cursor-pointer select-none items-center rounded-xl py-2.5 pl-8 pr-2 text-[13px] tracking-tight outline-none hover:bg-black/5 hover:text-foreground transition-all mb-1 last:mb-0 ${value === opt.code ? 'bg-primary/5 font-bold text-primary' : 'text-foreground/80 font-medium'}`}
              onClick={() => {
                onChange(opt.code);
                setOpen(false);
                setSearch('');
              }}
            >
              <span className="absolute left-2 flex h-3.5 w-3.5 items-center justify-center">
                {value === opt.code && <Check className="h-4 w-4 text-primary" />}
              </span>
              {opt.name}
            </div>
          ))
        )}
      </div>
    </div>
  );

  return (
    <div className="relative w-full" ref={containerRef}>
      <button
        type="button"
        disabled={disabled}
        onClick={toggleDropdown}
        className="flex h-11 w-full items-center justify-between rounded-2xl border border-black/5 bg-white px-4 py-2 text-[13px] font-medium tracking-tight transition-all hover:bg-white focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-primary/20 focus-visible:border-primary disabled:cursor-not-allowed disabled:opacity-50"
      >
        <span className={`truncate ${!selectedName ? 'text-muted-foreground/50 font-medium' : 'text-foreground font-semibold'}`}>
          {selectedName || placeholder}
        </span>
        <ChevronDown className="h-4 w-4 opacity-50" />
      </button>
      
      {open && typeof document !== 'undefined' && createPortal(dropdownContent, document.body)}
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
      <DialogContent className="sm:max-w-[700px] p-0 border border-white/80 shadow-2xl overflow-hidden rounded-[24px] bg-[#fcfbfb] backdrop-blur-2xl">
        <DialogHeader className="px-6 py-5 border-b border-black/5">
          <DialogTitle className="text-2xl font-bold tracking-tight text-foreground flex items-center gap-2">
            {customer ? 'Cập nhật Khách hàng' : 'Thêm Khách hàng mới'}
          </DialogTitle>
          <DialogDescription className="text-foreground/70 text-[13px] font-medium tracking-tight">
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
                <div className="p-1.5 rounded-lg bg-emerald-600/10 text-emerald-600 border border-emerald-600/20">
                  <User className="h-4 w-4" />
                </div>
                <h3 className="text-[14px]">Thông tin liên lạc</h3>
              </div>
              
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="fullName" className="text-[12px] font-bold tracking-tight text-foreground/80">Họ và tên <span className="text-destructive">*</span></Label>
                  <Input 
                    id="fullName"
                    placeholder="Nhập họ và tên..."
                    className="h-11 px-4 border-black/5 bg-white focus-visible:border-primary focus-visible:ring-1 focus-visible:ring-primary/20 rounded-2xl transition-all w-full text-[13px] tracking-tight font-medium placeholder:font-medium placeholder:text-muted-foreground/50"
                    value={fullName}
                    onChange={e => setFullName(e.target.value)}
                    required 
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="phone" className="text-[12px] font-bold tracking-tight text-foreground/80">Số điện thoại</Label>
                  <Input 
                    id="phone"
                    type="tel" 
                    placeholder="VD: 0901234567" 
                    className="h-11 px-4 border-black/5 bg-white focus-visible:border-primary focus-visible:ring-1 focus-visible:ring-primary/20 rounded-2xl transition-all w-full text-[13px] tracking-tight font-medium placeholder:font-medium placeholder:text-muted-foreground/50"
                    value={phone}
                    onChange={e => setPhone(e.target.value)}
                  />
                </div>
              </div>

              <div className="space-y-2">
                <Label htmlFor="groupId" className="text-[12px] font-bold tracking-tight text-foreground/80">Nhóm khách hàng <span className="text-destructive">*</span></Label>
                <select 
                  id="groupId"
                  disabled={isLoadingGroups} 
                  value={groupId} 
                  onChange={(e) => setGroupId(e.target.value)}
                  className="flex h-11 w-full rounded-2xl border border-black/5 bg-white px-4 py-2 text-[13px] font-medium tracking-tight transition-all focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-primary/20 focus-visible:border-primary disabled:cursor-not-allowed disabled:opacity-50"
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
                <div className="p-1.5 rounded-lg bg-emerald-600/10 text-emerald-600 border border-emerald-600/20">
                  <MapPin className="h-4 w-4" />
                </div>
                <h3 className="text-[14px]">Khu vực & Địa chỉ</h3>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="provinceCode" className="text-[12px] font-bold tracking-tight text-foreground/80">Tỉnh / Thành phố </Label>
                  <SearchableSelect 
                    options={provinces}
                    value={provinceCode}
                    onChange={setProvinceCode}
                    placeholder="Chọn Tỉnh/Thành phố"
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="wardCode" className="text-[12px] font-bold tracking-tight text-foreground/80">Quận / Huyện</Label>
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
                <Label htmlFor="addressDetail" className="text-[12px] font-bold tracking-tight text-foreground/80">Địa chỉ chi tiết (Không bắt buộc)</Label>
                <Input 
                  id="addressDetail"
                  placeholder="Số nhà, tên đường, tên toà nhà..." 
                  className="h-11 px-4 border-black/5 bg-white focus-visible:border-primary focus-visible:ring-1 focus-visible:ring-primary/20 rounded-2xl transition-all w-full text-[13px] tracking-tight font-medium placeholder:font-medium placeholder:text-muted-foreground/50"
                  value={addressDetail}
                  onChange={e => setAddressDetail(e.target.value)}
                />
              </div>
            </div>
          </div>
          
          <DialogFooter className="px-6 py-4 border-t border-black/5 bg-transparent m-0 flex items-center justify-end gap-3 mt-8">
            <Button type="button" variant="outline" onClick={onClose} disabled={isSubmitting} className="h-11 rounded-2xl px-6 bg-white border-black/10 hover:bg-neutral-100 shadow-sm text-[13px] font-bold tracking-tight transition-all">
              Huỷ bỏ
            </Button>
            <Button type="submit" disabled={isSubmitting || !fullName || !groupId} className="group relative overflow-hidden bg-neutral-900/85 hover:bg-black/90 backdrop-blur-xl text-white border border-white/20 hover:border-white/40 shadow-[0_8px_30px_rgb(0,0,0,0.12)] hover:shadow-[0_8px_30px_rgb(0,0,0,0.2)] transition-all duration-500 font-bold px-8 h-11 rounded-2xl">
              {isSubmitting ? (
                <Loader2 className="mr-2 h-4 w-4 animate-spin opacity-80" />
              ) : (
                <Check className="mr-2 h-4 w-4 opacity-80 group-hover:scale-110 transition-all duration-500" />
              )}
              <span className="relative z-10 text-[13px] tracking-tight">Lưu khách hàng</span>
              <div className="absolute inset-0 rounded-2xl ring-1 ring-inset ring-white/10 group-hover:ring-white/30 transition-all duration-500 pointer-events-none"></div>
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
}
