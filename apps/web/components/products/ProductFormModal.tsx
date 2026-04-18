'use client';

import { useState, useEffect } from 'react';
import { productsApi, crmApi, categoriesApi, settingsApi, Product, CustomerGroup, ProductCategory } from '@/lib/api';
import { useAuth } from '@/lib/auth-context';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
  DialogFooter,
} from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Switch } from "@/components/ui/switch";
import { Loader2, AlertCircle, PackageOpen, Check, DollarSign, Tag, Plus, Trash2 } from 'lucide-react';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import CustomerGroupFormModal from '../customers/CustomerGroupFormModal';

interface ProductFormModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSuccess: () => void;
  initialData: Product | null;
}

export default function ProductFormModal({ isOpen, onClose, onSuccess, initialData }: ProductFormModalProps) {
  const { getToken } = useAuth();
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState('');
  
  // Basic info
  const [name, setName] = useState('');
  const [sku, setSku] = useState('');
  const [categoryId, setCategoryId] = useState('');
  const [categories, setCategories] = useState<ProductCategory[]>([]);
  const [unit, setUnit] = useState('Cái');
  const [retailPrice, setRetailPrice] = useState('');
  const [costPrice, setCostPrice] = useState('');
  const [weight, setWeight] = useState('');
  const [dimensions, setDimensions] = useState('');
  const [isActive, setIsActive] = useState(true);

  // Groups and Prices
  const [groups, setGroups] = useState<CustomerGroup[]>([]);
  const [groupPrices, setGroupPrices] = useState<Record<string, string>>({}); // groupId -> fixedPrice string
  const [isGroupModalOpen, setIsGroupModalOpen] = useState(false);
  const [treatBlankAsZero, setTreatBlankAsZero] = useState(false);

  const fetchGroupsAndCategories = async () => {
    const token = getToken();
    if (!token) return;
    try {
      const [resGroups, resCats, resSettings] = await Promise.all([
        crmApi.getGroups(token),
        categoriesApi.getCategories(token),
        settingsApi.getCompanySettings(token)
      ]);
      const filtered = resGroups.filter(g => g.priceType === 'FIXED');
      filtered.sort((a, b) => {
        const aIsSi = a.name.toLowerCase().includes('sỉ');
        const bIsSi = b.name.toLowerCase().includes('sỉ');
        if (aIsSi && !bIsSi) return -1;
        if (!aIsSi && bIsSi) return 1;
        return (a.createdAt ?? '') > (b.createdAt ?? '') ? 1 : -1;
      });
      setGroups(filtered);
      setCategories(resCats);
      setTreatBlankAsZero(resSettings.treatBlankAsZero || false);
    } catch (err) {}
  };

  useEffect(() => {
    if (isOpen) {
      fetchGroupsAndCategories();
        
      if (initialData) {
        setName(initialData.name);
        setSku(initialData.sku);
        setCategoryId(initialData.categoryId || '');
        setUnit(initialData.unit);
        setRetailPrice(initialData.retailPrice.toString());
        setCostPrice(initialData.costPrice?.toString() || '');
        setWeight(initialData.weight?.toString() || '');
        setDimensions(initialData.dimensions || '');
        setIsActive(initialData.isActive);
        
        const gpMap: Record<string, string> = {};
        if (initialData.groupPrices) {
          initialData.groupPrices.forEach(gp => {
            gpMap[gp.groupId] = gp.fixedPrice.toString();
          });
        }
        setGroupPrices(gpMap);
      } else {
        setName(''); setSku(''); setCategoryId(''); setUnit('Cái'); setRetailPrice(''); setCostPrice('');
        setWeight(''); setDimensions(''); setIsActive(true); setGroupPrices({});
      }
    }
  }, [isOpen, initialData, getToken]);

  // Handle auto SKU generation
  useEffect(() => {
    if (isOpen && !initialData && categoryId && name.trim().length > 0) {
      const fetchSku = async () => {
        try {
          const res = await productsApi.getNextSku(getToken()!, categoryId);
          if (res.sku) setSku(res.sku);
        } catch (e) {
          console.error('Lỗi sinh SKU:', e);
        }
      };
      
      // Add slight debounce to avoid excessive requests while typing name
      const timeoutId = setTimeout(() => {
        fetchSku();
      }, 300);
      return () => clearTimeout(timeoutId);
    }
  }, [categoryId, name, initialData, isOpen, getToken]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!name || (!initialData && !categoryId) || !retailPrice) return;
    
    setError('');
    setIsSubmitting(true);
    
    // Prepare payload
    const gpArray = groups.map(g => {
      const isBlank = !groupPrices[g.id] || groupPrices[g.id].trim() === '';
      if (isBlank && !treatBlankAsZero) return null;
      return {
        groupId: g.id,
        fixedPrice: isBlank ? 0 : Number(groupPrices[g.id])
      };
    }).filter(Boolean);

    const payload: Partial<Product> = {
      name,
      sku: sku.trim() || undefined,
      categoryId,
      unit,
      retailPrice: Number(retailPrice),
      costPrice: costPrice ? Number(costPrice) : null,
      weight: weight ? Number(weight) : null,
      dimensions: dimensions || null,
      isActive,
      groupPrices: gpArray as any,
    };

    try {
      if (initialData) {
        await productsApi.updateProduct(getToken()!, initialData.id, payload);
      } else {
        await productsApi.createProduct(getToken()!, payload);
      }
      onSuccess();
    } catch (err: any) {
      setError(err.message || 'Lỗi khi lưu sản phẩm');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <>
      <Dialog open={isOpen} onOpenChange={(open) => !open && onClose()}>
        <DialogContent className="sm:max-w-[700px] p-0 border border-white/80 shadow-2xl overflow-hidden rounded-[24px] bg-[#fcfbfb] backdrop-blur-2xl">
          <DialogHeader className="px-6 py-5 border-b border-black/5">
            <DialogTitle className="text-2xl font-bold tracking-tight text-foreground flex items-center gap-2">
              {initialData ? 'Cập nhật Sản phẩm' : 'Thêm Sản phẩm mới'}
            </DialogTitle>
            <DialogDescription className="text-foreground/70 text-[13px] font-medium tracking-tight">
              Điền đầy đủ thông tin bên dưới để {initialData ? 'cập nhật' : 'tạo'} sản phẩm mới.
            </DialogDescription>
          </DialogHeader>
          
          <form onSubmit={handleSubmit} className="px-6 py-4 max-h-[75vh] overflow-y-auto custom-scrollbar">
            {error && (
              <div className="p-3 mb-6 bg-destructive/10 text-destructive text-sm rounded-md flex items-center gap-2">
                <AlertCircle className="h-4 w-4" />
                {error}
              </div>
            )}

            <div className="space-y-8">
              {/* Sec 1: Thông tin chung */}
              <div className="space-y-4">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2 text-foreground font-semibold">
                    <div className="p-1.5 rounded-lg bg-primary/10 text-primary border border-primary/20">
                      <PackageOpen className="h-4 w-4" />
                    </div>
                    <h3 className="text-[14px]">Thông tin chung</h3>
                  </div>
                  <div className="flex items-center space-x-2">
                    <Switch id="is-active" checked={isActive} onCheckedChange={setIsActive} className="data-[state=checked]:bg-primary" />
                    <Label htmlFor="is-active" className="cursor-pointer text-[12px] font-bold tracking-tight text-foreground/80">Trạng thái bán</Label>
                  </div>
                </div>
                
                <div className="space-y-2">
                  <Label htmlFor="name" className="text-[12px] font-bold tracking-tight text-foreground/80">Tên sản phẩm <span className="text-destructive">*</span></Label>
                  <Input 
                    id="name"
                    placeholder="Nhập tên sản phẩm..."
                    className="h-11 px-4 border-black/5 bg-white focus-visible:border-primary focus-visible:ring-1 focus-visible:ring-primary/20 rounded-2xl transition-all w-full text-[13px] tracking-tight font-medium placeholder:font-medium placeholder:text-muted-foreground/50"
                    value={name} 
                    onChange={e => setName(e.target.value)} 
                    required 
                  />
                </div>

                <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
                  <div className="space-y-2 md:col-span-2">
                    <Label htmlFor="category" className="text-[12px] font-bold tracking-tight text-foreground/80">Danh mục <span className="text-destructive">*</span></Label>
                    <Select value={categoryId} onValueChange={(v) => setCategoryId(v ?? '')} disabled={categories.length === 0}>
                      <SelectTrigger className="!w-full !h-11 px-4 border-black/5 bg-white focus-visible:border-primary focus-visible:ring-1 focus-visible:ring-primary/20 rounded-2xl transition-all text-[13px] tracking-tight font-medium">
                        <SelectValue placeholder={categories.length === 0 ? "Chưa có danh mục nào (Vui lòng tạo trước)" : "Chọn danh mục"}>
                          {categoryId ? categories.find(c => c.id === categoryId)?.name : undefined}
                        </SelectValue>
                      </SelectTrigger>
                      <SelectContent className="rounded-[16px] p-2 shadow-2xl border-white/60 backdrop-blur-3xl bg-white/70">
                        {categories.length > 0 && categories.map(cat => (
                          <SelectItem key={cat.id} value={cat.id} className="rounded-xl py-2 px-3 focus:bg-white/80 focus:text-primary transition-all cursor-pointer font-medium tracking-tight mb-1">{cat.name}</SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                  
                  <div className="space-y-2 md:col-span-1">
                    <Label className="text-[12px] font-bold tracking-tight text-foreground/80">Mã SKU</Label>
                    <div className="w-full h-11 px-4 flex items-center border border-black/5 rounded-2xl bg-black/5 overflow-hidden">
                      {sku ? (
                        <span className="font-semibold text-primary/90 truncate tracking-tight text-[13px]">{sku}</span>
                      ) : (
                        <span className="text-muted-foreground/50 font-medium text-[13px] truncate">Tự động sinh...</span>
                      )}
                    </div>
                  </div>

                  <div className="space-y-2 md:col-span-1">
                    <Label htmlFor="unit" className="text-[12px] font-bold tracking-tight text-foreground/80">Đơn vị tính <span className="text-destructive">*</span></Label>
                    <Select value={unit} onValueChange={(val) => setUnit(val || '')}>
                      <SelectTrigger id="unit" className="!w-full !h-11 px-4 border-black/5 bg-white focus-visible:border-primary focus-visible:ring-1 focus-visible:ring-primary/20 rounded-2xl transition-all text-[13px] tracking-tight font-medium">
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent className="rounded-[16px] p-2 shadow-2xl border-white/60 backdrop-blur-3xl bg-white/70">
                        {['Chai', 'Gói', 'Hộp', 'Túi', 'Cái', 'Bộ', 'Con', 'Set', 'Lít', 'Kg', 'Hủ'].map(u => (
                          <SelectItem key={u} value={u} className="rounded-xl py-2 px-3 focus:bg-white/80 focus:text-primary transition-all cursor-pointer font-medium tracking-tight mb-1">{u}</SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                </div>
              </div>

              {/* Sec 2: Giá & Kích thước */}
              <div className="space-y-4">
                <div className="flex items-center gap-2 text-foreground font-semibold">
                  <div className="p-1.5 rounded-lg bg-primary/10 text-primary border border-primary/20">
                    <DollarSign className="h-4 w-4" />
                  </div>
                  <h3 className="text-[14px]">Giá & Thông số (VNĐ)</h3>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="retailPrice" className="text-[12px] font-bold tracking-tight text-foreground/80">Giá bán lẻ (VNĐ) <span className="text-destructive">*</span></Label>
                    <Input 
                      id="retailPrice"
                      type="text" 
                      inputMode="numeric"
                      placeholder="0"
                      className="h-11 px-4 border-black/5 bg-white focus-visible:border-primary focus-visible:ring-1 focus-visible:ring-primary/20 rounded-2xl transition-all w-full text-[13px] tracking-tight font-semibold text-primary/90 placeholder:font-medium placeholder:text-muted-foreground/50"
                      value={retailPrice ? new Intl.NumberFormat('vi-VN').format(Number(retailPrice)) : ''} 
                      onChange={e => setRetailPrice(e.target.value.replace(/\D/g, ''))} 
                      required 
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="costPrice" className="text-[12px] font-bold tracking-tight text-foreground/80">Giá vốn (Tùy chọn)</Label>
                    <Input 
                      id="costPrice"
                      type="text" 
                      inputMode="numeric"
                      placeholder="0"
                      className="h-11 px-4 border-black/5 bg-white focus-visible:border-primary focus-visible:ring-1 focus-visible:ring-primary/20 rounded-2xl transition-all w-full text-[13px] tracking-tight font-medium placeholder:font-medium placeholder:text-muted-foreground/50"
                      value={costPrice ? new Intl.NumberFormat('vi-VN').format(Number(costPrice)) : ''} 
                      onChange={e => setCostPrice(e.target.value.replace(/\D/g, ''))} 
                    />
                  </div>
                </div>
              </div>

              {/* Sec 3: Bảng giá đại lý */}
              <div className="space-y-4 border-t border-black/5 pt-6">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2 text-foreground font-semibold">
                    <div className="p-1.5 rounded-lg bg-primary/10 text-primary border border-primary/20">
                      <Tag className="h-4 w-4" />
                    </div>
                    <h3 className="text-[14px]">Thiết lập giá nhóm</h3>
                  </div>
                  <Button 
                    variant="outline" 
                    size="sm" 
                    type="button" 
                    onClick={() => setIsGroupModalOpen(true)}
                    className="h-9 px-4 rounded-xl border border-black/5 bg-white text-[13px] font-semibold text-foreground tracking-tight hover:bg-white hover:text-primary transition-all"
                  >
                    <Plus className="mr-2 h-4 w-4 text-primary" />
                    Tạo nhóm mới
                  </Button>
                </div>
                <p className="text-[13px] font-medium tracking-tight text-foreground/70">Chọn nhóm khách hàng và cấu hình mức giá bán riêng. Bỏ trống = 0đ.</p>
                
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 mt-4">
                  {groups.map((group) => (
                    <div key={group.id} className="space-y-2 bg-white p-3 rounded-2xl border border-black/5 hover:border-primary/20 transition-all">
                      <Label className="text-[12px] font-bold tracking-tight text-foreground/80 truncate block" title={group.name}>{group.name}</Label>
                      <div className="relative flex items-center">
                        <span className="absolute left-3 text-muted-foreground/60 text-[13px] font-medium">₫</span>
                        <Input 
                          type="text"
                          inputMode="numeric"
                          placeholder="0"
                          value={groupPrices[group.id] ? new Intl.NumberFormat('vi-VN').format(Number(groupPrices[group.id])) : ''}
                          onChange={e => setGroupPrices(prev => ({...prev, [group.id]: e.target.value.replace(/\D/g, '')}))}
                          className="pl-8 h-11 border-black/5 bg-white focus-visible:border-primary focus-visible:ring-1 focus-visible:ring-primary/20 rounded-xl transition-all w-full text-[13px] tracking-tight font-semibold text-primary/90 placeholder:font-medium placeholder:text-muted-foreground/50"
                        />
                      </div>
                    </div>
                  ))}
                  {groups.length === 0 && (
                     <div className="col-span-full py-6 text-center text-foreground/70 font-medium tracking-tight text-[13px] border border-dashed border-black/10 rounded-2xl bg-white/50">
                       Chưa có nhóm cấu hình nào. Hãy tạo nhóm mới.
                     </div>
                  )}
                </div>
              </div>
            </div>
            
            <DialogFooter className="pt-8 mt-4 border-t border-black/5 bg-transparent m-0 flex items-center justify-end gap-3 px-0 pb-2">
              <Button type="button" variant="outline" onClick={onClose} disabled={isSubmitting} className="h-11 rounded-2xl px-6 bg-white border-black/10 hover:bg-neutral-100 shadow-sm text-[13px] font-bold tracking-tight transition-all">
                Huỷ bỏ
              </Button>
              <Button type="submit" disabled={isSubmitting || !name || (!initialData && !categoryId) || !retailPrice} className="group relative overflow-hidden bg-neutral-900/85 hover:bg-black/90 backdrop-blur-xl text-white border border-white/20 hover:border-white/40 shadow-[0_8px_30px_rgb(0,0,0,0.12)] hover:shadow-[0_8px_30px_rgb(0,0,0,0.2)] transition-all duration-500 font-bold px-8 h-11 rounded-2xl">
                {isSubmitting ? (
                  <Loader2 className="mr-2 h-4 w-4 animate-spin opacity-80" />
                ) : (
                  <Check className="mr-2 h-4 w-4 opacity-80 group-hover:scale-110 transition-all duration-500" />
                )}
                <span className="relative z-10 text-[13px] tracking-tight">{initialData ? 'Cập nhật' : 'Lưu sản phẩm'}</span>
                <div className="absolute inset-0 rounded-2xl ring-1 ring-inset ring-white/10 group-hover:ring-white/30 transition-all duration-500 pointer-events-none"></div>
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>

      <CustomerGroupFormModal 
        isOpen={isGroupModalOpen} 
        onClose={() => setIsGroupModalOpen(false)} 
        onSuccess={(newGroup) => {
          setIsGroupModalOpen(false);
          fetchGroupsAndCategories();
          
          if (newGroup) {
            // Push group directly into state to bypass any Next.js caching delays
            setGroups(prev => {
              if (prev.some(g => g.id === newGroup.id)) return prev;
              return [newGroup, ...prev];
            });
          }
        }} 
      />
    </>
  );
}
