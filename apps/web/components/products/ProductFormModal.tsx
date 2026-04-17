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
        <DialogContent className="bg-background/95 backdrop-blur-xl border border-muted shadow-2xl sm:max-w-[700px] p-0 overflow-hidden">
          <DialogHeader className="px-6 py-4 border-b bg-muted/40">
            <DialogTitle className="text-xl">{initialData ? 'Cập nhật Sản phẩm' : 'Thêm Sản phẩm mới'}</DialogTitle>
            <DialogDescription>
              Điền đầy đủ thông tin bên dưới để {initialData ? 'cập nhật' : 'tạo'} sản phẩm mới.
            </DialogDescription>
          </DialogHeader>
          
          <form onSubmit={handleSubmit} className="px-6 py-4 max-h-[75vh] overflow-y-auto">
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
                    <PackageOpen className="h-5 w-5 text-emerald-600" />
                    <h3>Thông tin chung</h3>
                  </div>
                  <div className="flex items-center space-x-2">
                    <Switch id="is-active" checked={isActive} onCheckedChange={setIsActive} className="data-[state=checked]:bg-emerald-600" />
                    <Label htmlFor="is-active" className="cursor-pointer">Trạng thái bán</Label>
                  </div>
                </div>
                
                <div className="space-y-2">
                  <Label htmlFor="name">Tên sản phẩm <span className="text-destructive">*</span></Label>
                  <Input 
                    id="name"
                    placeholder="Nhập tên sản phẩm..."
                    className="h-10 border-muted-foreground/20 shadow-sm"
                    value={name} 
                    onChange={e => setName(e.target.value)} 
                    required 
                  />
                </div>

                <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
                  <div className="space-y-2 md:col-span-2">
                    <Label htmlFor="category">Danh mục <span className="text-destructive">*</span></Label>
                    <Select value={categoryId} onValueChange={setCategoryId} disabled={categories.length === 0}>
                      <SelectTrigger className="!w-full !h-10 border-muted-foreground/20 shadow-sm">
                        <SelectValue placeholder={categories.length === 0 ? "Chưa có danh mục nào (Vui lòng tạo trước)" : "Chọn danh mục"}>
                          {categoryId ? categories.find(c => c.id === categoryId)?.name : undefined}
                        </SelectValue>
                      </SelectTrigger>
                      <SelectContent>
                        {categories.length > 0 && categories.map(cat => (
                          <SelectItem key={cat.id} value={cat.id}>{cat.name}</SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                  
                  <div className="space-y-2 md:col-span-1">
                    <Label>Mã SKU</Label>
                    <div className="w-full h-10 px-3 flex items-center border border-muted-foreground/20 rounded-md bg-muted/30 shadow-sm overflow-hidden">
                      {sku ? (
                        <span className="font-semibold text-emerald-700 truncate">{sku}</span>
                      ) : (
                        <span className="text-muted-foreground text-sm truncate">Tự động sinh...</span>
                      )}
                    </div>
                  </div>

                  <div className="space-y-2 md:col-span-1">
                    <Label htmlFor="unit">Đơn vị tính <span className="text-destructive">*</span></Label>
                    <Select value={unit} onValueChange={(val) => setUnit(val || '')}>
                      <SelectTrigger id="unit" className="!w-full !h-10 border-muted-foreground/20 shadow-sm">
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        {['Chai', 'Gói', 'Hộp', 'Túi', 'Cái', 'Bộ', 'Con', 'Set', 'Lít', 'Kg', 'Hủ'].map(u => (
                          <SelectItem key={u} value={u}>{u}</SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                </div>
              </div>

              {/* Sec 2: Giá & Kích thước */}
              <div className="space-y-4">
                <div className="flex items-center gap-2 text-foreground font-semibold">
                  <DollarSign className="h-5 w-5 text-emerald-600" />
                  <h3>Giá & Thông số (VNĐ)</h3>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="retailPrice">Giá bán lẻ (VNĐ) <span className="text-destructive">*</span></Label>
                    <Input 
                      id="retailPrice"
                      type="text" 
                      inputMode="numeric"
                      placeholder="0"
                      className="h-10 border-muted-foreground/20 shadow-sm font-medium text-emerald-700"
                      value={retailPrice ? new Intl.NumberFormat('vi-VN').format(Number(retailPrice)) : ''} 
                      onChange={e => setRetailPrice(e.target.value.replace(/\D/g, ''))} 
                      required 
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="costPrice">Giá vốn (Tùy chọn)</Label>
                    <Input 
                      id="costPrice"
                      type="text" 
                      inputMode="numeric"
                      placeholder="0"
                      className="h-10 border-muted-foreground/20 shadow-sm"
                      value={costPrice ? new Intl.NumberFormat('vi-VN').format(Number(costPrice)) : ''} 
                      onChange={e => setCostPrice(e.target.value.replace(/\D/g, ''))} 
                    />
                  </div>
                </div>
              </div>

              {/* Sec 3: Bảng giá đại lý */}
              <div className="space-y-4 border-t pt-6">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2 text-foreground font-semibold">
                    <Tag className="h-5 w-5 text-emerald-600" />
                    <h3>Thiết lập giá nhóm</h3>
                  </div>
                  <Button 
                    variant="outline" 
                    size="sm" 
                    type="button" 
                    onClick={() => setIsGroupModalOpen(true)}
                    className="h-8 shadow-sm"
                  >
                    <Plus className="mr-2 h-4 w-4 text-emerald-600" />
                    Tạo nhóm mới
                  </Button>
                </div>
                <p className="text-sm text-muted-foreground">Chọn nhóm khách hàng và cấu hình mức giá bán riêng. Bỏ trống = 0đ.</p>
                
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 mt-4">
                  {groups.map((group) => (
                    <div key={group.id} className="space-y-2 bg-muted/20 p-3 rounded-md border shadow-sm">
                      <Label className="font-medium text-foreground truncate block" title={group.name}>{group.name}</Label>
                      <div className="relative flex items-center">
                        <span className="absolute left-3 text-muted-foreground text-sm font-medium">₫</span>
                        <Input 
                          type="text"
                          inputMode="numeric"
                          placeholder="0"
                          value={groupPrices[group.id] ? new Intl.NumberFormat('vi-VN').format(Number(groupPrices[group.id])) : ''}
                          onChange={e => setGroupPrices(prev => ({...prev, [group.id]: e.target.value.replace(/\D/g, '')}))}
                          className="pl-7 bg-background font-semibold text-emerald-700 border-muted-foreground/30"
                        />
                      </div>
                    </div>
                  ))}
                  {groups.length === 0 && (
                     <div className="col-span-full py-4 text-center text-muted-foreground text-sm border border-dashed rounded-md">
                       Chưa có nhóm cấu hình nào. Hãy tạo nhóm mới.
                     </div>
                  )}
                </div>
              </div>
            </div>
            
            <DialogFooter className="pt-8 pb-2 mt-4 border-t">
              <Button type="button" variant="outline" onClick={onClose} disabled={isSubmitting}>
                Huỷ bỏ
              </Button>
              <Button type="submit" disabled={isSubmitting || !name || (!initialData && !categoryId) || !retailPrice} className="bg-emerald-600 hover:bg-emerald-700 text-white min-w-[140px]">
                {isSubmitting ? (
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                ) : (
                  <Check className="mr-2 h-4 w-4" />
                )}
                {initialData ? 'Cập nhật' : 'Lưu sản phẩm'}
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
