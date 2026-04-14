'use client';

import { useState, useEffect } from 'react';
import { productsApi, crmApi, Product, CustomerGroup } from '@/lib/api';
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
  const [unit, setUnit] = useState('Cái');
  const [retailPrice, setRetailPrice] = useState('');
  const [costPrice, setCostPrice] = useState('');
  const [weight, setWeight] = useState('');
  const [dimensions, setDimensions] = useState('');
  const [isActive, setIsActive] = useState(true);

  // Groups and Prices
  const [groups, setGroups] = useState<CustomerGroup[]>([]);
  const [groupPrices, setGroupPrices] = useState<Record<string, string>>({}); // groupId -> fixedPrice string
  const [activeGroupIds, setActiveGroupIds] = useState<string[]>([]);
  const [isGroupModalOpen, setIsGroupModalOpen] = useState(false);

  const fetchGroupsData = async () => {
    const token = getToken();
    if (!token) return;
    try {
      const res = await crmApi.getGroups(token);
      setGroups(res.filter(g => g.priceType === 'FIXED'));
    } catch (err) {}
  };

  useEffect(() => {
    if (isOpen) {
      fetchGroupsData();
        
      if (initialData) {
        setName(initialData.name);
        setSku(initialData.sku);
        setUnit(initialData.unit);
        setRetailPrice(initialData.retailPrice.toString());
        setCostPrice(initialData.costPrice?.toString() || '');
        setWeight(initialData.weight?.toString() || '');
        setDimensions(initialData.dimensions || '');
        setIsActive(initialData.isActive);
        
        const gpMap: Record<string, string> = {};
        const activeIds: string[] = [];
        if (initialData.groupPrices) {
          initialData.groupPrices.forEach(gp => {
            gpMap[gp.groupId] = gp.fixedPrice.toString();
            activeIds.push(gp.groupId);
          });
        }
        setGroupPrices(gpMap);
        setActiveGroupIds(activeIds);
      } else {
        setName(''); setSku(''); setUnit('Cái'); setRetailPrice(''); setCostPrice('');
        setWeight(''); setDimensions(''); setIsActive(true); setGroupPrices({}); setActiveGroupIds([]);
      }
    }
  }, [isOpen, initialData, getToken]);

  const handleAddGroupPrice = () => {
    setActiveGroupIds([...activeGroupIds, '']);
  };

  const handleRemoveGroupPrice = (index: number) => {
    const newActive = [...activeGroupIds];
    const removedId = newActive.splice(index, 1)[0];
    setActiveGroupIds(newActive);
    if (removedId) {
      setGroupPrices(prev => {
        const next = { ...prev };
        delete next[removedId];
        return next;
      });
    }
  };

  const handleGroupSelect = (index: number, newGroupId: string) => {
    const newActive = [...activeGroupIds];
    newActive[index] = newGroupId;
    setActiveGroupIds(newActive);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!name || !sku || !retailPrice) return;
    
    setError('');
    setIsSubmitting(true);
    
    // Prepare payload
    const gpArray = activeGroupIds
      .filter(gid => gid.trim() !== '' && groupPrices[gid] && groupPrices[gid].trim() !== '')
      .map(gid => ({ groupId: gid, fixedPrice: Number(groupPrices[gid]) }));

    const payload: Partial<Product> = {
      name,
      sku,
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
              Điền đầy đủ thông tin bên dưới để {initialData ? 'cập nhật' : 'tạo'} danh mục sản phẩm.
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

                <div className="grid grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="sku">Mã SKU <span className="text-destructive">*</span></Label>
                    <Input 
                      id="sku"
                      placeholder="VD: SP-001"
                      className="h-10 border-muted-foreground/20 shadow-sm"
                      value={sku} 
                      onChange={e => setSku(e.target.value)} 
                      required 
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="unit">Đơn vị tính <span className="text-destructive">*</span></Label>
                    <Select value={unit} onValueChange={(val) => setUnit(val || '')}>
                      <SelectTrigger id="unit" className="h-10 border-muted-foreground/20 shadow-sm">
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
                      type="number" 
                      min="0" 
                      placeholder="0"
                      className="h-10 border-muted-foreground/20 shadow-sm font-medium text-emerald-700"
                      value={retailPrice} 
                      onChange={e => setRetailPrice(e.target.value)} 
                      required 
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="costPrice">Giá vốn (Tùy chọn)</Label>
                    <Input 
                      id="costPrice"
                      type="number" 
                      min="0" 
                      placeholder="0"
                      className="h-10 border-muted-foreground/20 shadow-sm"
                      value={costPrice} 
                      onChange={e => setCostPrice(e.target.value)} 
                    />
                  </div>
                </div>
              </div>

              {/* Sec 3: Bảng giá đại lý */}
              <div className="space-y-4 border-t pt-6">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2 text-foreground font-semibold">
                    <Tag className="h-5 w-5 text-emerald-600" />
                    <h3>Thiết lập Giá Cố định (VIP/Đại lý)</h3>
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
                <p className="text-sm text-muted-foreground">Chọn nhóm khách hàng và cấu hình mức giá bán đứt (FIXED). Bỏ trống = Giá lẻ.</p>
                
                <div className="space-y-3 mt-4">
                  {activeGroupIds.map((groupId, index) => {
                     const availableGroups = groups.filter(g => g.id === groupId || !activeGroupIds.includes(g.id));

                     return (
                       <div key={index} className="flex flex-col sm:flex-row sm:items-center gap-3 bg-muted/20 p-3 rounded-md border shadow-sm">
                         <Select 
                           value={groupId} 
                           onValueChange={(val) => handleGroupSelect(index, val || '')}
                         >
                           <SelectTrigger className="sm:w-[250px] bg-background border-muted-foreground/30 font-medium">
                             <SelectValue placeholder="-- Chọn nhóm cấu hình --">
                               {groupId ? (
                                 availableGroups.find(g => g.id === groupId)?.name || 
                                 initialData?.groupPrices?.find(p => p.groupId === groupId)?.group?.name || 
                                 'Nhóm mới tạo'
                               ) : undefined}
                             </SelectValue>
                           </SelectTrigger>
                           <SelectContent>
                             {availableGroups.map(g => (
                               <SelectItem key={g.id} value={g.id}>{g.name}</SelectItem>
                             ))}
                             {groupId && !availableGroups.some(g => g.id === groupId) && (
                               <SelectItem key={groupId} value={groupId}>
                                 {initialData?.groupPrices?.find(p => p.groupId === groupId)?.group?.name || 'Nhóm mới tạo / Tạm ẩn'}
                               </SelectItem>
                             )}
                           </SelectContent>
                         </Select>

                         <div className="relative flex-1 flex items-center">
                           <span className="absolute left-3 text-muted-foreground text-sm font-medium">₫</span>
                           <Input 
                             type="number"
                             min="0"
                             placeholder={retailPrice ? `Mặc định (${new Intl.NumberFormat('vi-VN').format(Number(retailPrice))})` : "Nhập giá cố định..."}
                             value={groupId ? (groupPrices[groupId] || '') : ''}
                             onChange={e => groupId && setGroupPrices(prev => ({...prev, [groupId]: e.target.value}))}
                             disabled={!groupId}
                             className="pl-7 bg-background font-semibold text-emerald-700 border-muted-foreground/30"
                           />
                         </div>

                         <Button 
                           type="button" 
                           variant="ghost" 
                           size="icon"
                           className="text-muted-foreground hover:bg-destructive/10 hover:text-destructive shrink-0 h-10 w-10"
                           onClick={() => handleRemoveGroupPrice(index)}
                         >
                           <Trash2 className="h-5 w-5" />
                         </Button>
                       </div>
                     );
                  })}
                </div>
                
                {groups.length > activeGroupIds.length && (
                   <Button 
                     type="button" 
                     variant="ghost" 
                     className="w-full text-emerald-600 hover:text-emerald-700 hover:bg-emerald-50 mt-2 border border-dashed border-emerald-200 shadow-sm"
                     onClick={handleAddGroupPrice}
                   >
                     <Plus className="mr-2 h-4 w-4" />
                     Thêm cấu hình giá nhóm
                   </Button>
                )}
              </div>
            </div>
            
            <DialogFooter className="pt-8 pb-2 mt-4 border-t">
              <Button type="button" variant="outline" onClick={onClose} disabled={isSubmitting}>
                Huỷ bỏ
              </Button>
              <Button type="submit" disabled={isSubmitting || !name || !sku || !retailPrice} className="bg-emerald-600 hover:bg-emerald-700 text-white min-w-[140px]">
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
          fetchGroupsData();
          
          if (newGroup) {
            // Push group directly into state to bypass any Next.js caching delays
            setGroups(prev => {
              if (prev.some(g => g.id === newGroup.id)) return prev;
              return [newGroup, ...prev];
            });
            // Automatically assign the newly created group to an empty row or create a new row
            setActiveGroupIds(prev => {
              if (prev.includes(newGroup.id)) return prev;
              const emptyIndex = prev.findIndex(id => id === '');
              if (emptyIndex !== -1) {
                const next = [...prev];
                next[emptyIndex] = newGroup.id;
                return next;
              }
              return [...prev, newGroup.id];
            });
          }
        }} 
      />
    </>
  );
}
