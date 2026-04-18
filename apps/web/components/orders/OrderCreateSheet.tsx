'use client';

import { useState, useEffect, useMemo } from 'react';
import { crmApi, productsApi, ordersApi, Customer, Product } from '@/lib/api';
import { useAuth } from '@/lib/auth-context';
import {
  Sheet,
  SheetContent,
  SheetHeader,
  SheetTitle,
  SheetFooter,
  SheetDescription,
} from '@/components/ui/sheet';
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
import { Loader2, Plus, Trash2, Search, ShoppingCart, Info, CheckCircle2, PackageOpen, Check, User, X } from 'lucide-react';
import { Badge } from '@/components/ui/badge';
import CustomerFormModal from '../customers/CustomerFormModal';
import { toast } from 'sonner';
import { GenerativeAvatar } from '@/components/ui/generative-avatar';

interface OrderCreateSheetProps {
  isOpen: boolean;
  initialCustomerId?: string;
  onClose: () => void;
  onSuccess: () => void;
}

export default function OrderCreateSheet({ isOpen, initialCustomerId, onClose, onSuccess }: OrderCreateSheetProps) {
  const { getToken } = useAuth();
  
  // Master data
  const [customers, setCustomers] = useState<Customer[]>([]);
  const [products, setProducts] = useState<Product[]>([]);
  const [selectedCustomerObj, setSelectedCustomerObj] = useState<Customer | null>(null);
  
  // Selections
  const [customerId, setCustomerId] = useState<string>('');
  const [cart, setCart] = useState<{product: Product, quantity: any, discount: number, discountType?: 'amount' | 'percent'}[]>([]);
  const [searchProduct, setSearchProduct] = useState('');
  
  // Combobox Customer state
  const [searchCustomer, setSearchCustomer] = useState('');
  const [showCustomerDropdown, setShowCustomerDropdown] = useState(false);
  
  // Modal states
  const [showSuccessModal, setShowSuccessModal] = useState(false);
  
  // Modals
  const [isCustomerModalOpen, setIsCustomerModalOpen] = useState(false);

  // Final calculations
  const [shippingFee, setShippingFee] = useState<number>(0);
  
  // Status
  const [isSubmitting, setIsSubmitting] = useState(false);

  // Pricing preview (#10)
  const [pricedItems, setPricedItems] = useState<Record<string, { unitPrice: number; source: string; note: string; lineTotal: number }>>({});
  const [pricingSubtotal, setPricingSubtotal] = useState<number | null>(null);

  useEffect(() => {
    if (isOpen) {
      const token = getToken()!;
      const startSearch = undefined;
      crmApi.getCustomers(token, { take: 500, search: initialCustomerId ? undefined : undefined }).then(res => {
        let activeCustomers = res.data.filter(c => c.isActive);
        if (initialCustomerId) {
          crmApi.getCustomer(token, initialCustomerId).then(match => {
            if (match) {
              if (!activeCustomers.some(c => c.id === match.id)) {
                 activeCustomers = [match, ...activeCustomers];
              }
              setCustomers(activeCustomers);
              setCustomerId(match.id);
              setSelectedCustomerObj(match);
              setSearchCustomer(match.phone || match.fullName);
            }
          }).catch(console.error);
        } else {
          setCustomers(activeCustomers);
        }
      }).catch(console.error);
      productsApi.getProducts(token, { take: 500 }).then(res => setProducts(res.data.filter(p => p.isActive))).catch(console.error);
      
      // Reset state
      if (!initialCustomerId) {
        setCustomerId('');
        setSearchCustomer('');
        setSelectedCustomerObj(null);
      } else {
        setCustomerId(initialCustomerId);
      }
      setCart([]);
      setShippingFee(0);
      setShowCustomerDropdown(false);
      setPricedItems({});
      setPricingSubtotal(null);
    }
  }, [isOpen, initialCustomerId, getToken]);

  // Async search for products
  useEffect(() => {
    if (!isOpen) return;
    const timer = setTimeout(() => {
      productsApi.getProducts(getToken()!, { search: searchProduct, take: 500 }).then(res => setProducts(res.data.filter(p => p.isActive))).catch(() => {});
    }, 300);
    return () => clearTimeout(timer);
  }, [searchProduct, getToken, isOpen]);

  // Async search for customers
  useEffect(() => {
    if (!isOpen) return;
    const timer = setTimeout(() => {
      crmApi.getCustomers(getToken()!, { search: searchCustomer, take: 500 }).then(res => setCustomers(res.data.filter(c => c.isActive))).catch(() => {});
    }, 300);
    return () => clearTimeout(timer);
  }, [searchCustomer, getToken, isOpen]);

  const selectedCustomer = selectedCustomerObj;

  // Fix #10: Debounced pricing preview khi customer hoặc cart thay đổi
  useEffect(() => {
    if (!customerId || cart.length === 0) {
      setPricedItems({});
      setPricingSubtotal(null);
      return;
    }

    const validItems = cart.filter(c => parseQty(c.quantity) > 0);
    if (validItems.length === 0) {
      setPricedItems({});
      setPricingSubtotal(null);
      return;
    }

    const timer = setTimeout(async () => {
      try {
        const token = getToken()!;
        const res = await ordersApi.previewPricing(token, {
          customerId,
          items: validItems.map(c => ({
            productId: c.product.id,
            quantity: parseQty(c.quantity),
            manualDiscount: getAbsoluteDiscount(c),
          }))
        });
        const map: Record<string, { unitPrice: number; source: string; note: string; lineTotal: number }> = {};
        res.items.forEach(item => {
          map[item.productId] = {
            unitPrice: item.snapshotUnitPrice,
            source: item.priceSource,
            note: item.pricingNote,
            lineTotal: item.lineTotal,
          };
        });
        setPricedItems(map);
        setPricingSubtotal(res.subtotal);
      } catch {
        // Fallback: dùng giá retail nếu preview fail
      }
    }, 600);

    return () => clearTimeout(timer);
  }, [customerId, cart, getToken]);

  const addToCart = (product: Product) => {
    setCart(prev => {
      const existing = prev.find(item => item.product.id === product.id);
      if (existing) {
        return prev.map(item => item.product.id === product.id ? { ...item, quantity: parseQty(item.quantity) + 1 } : item);
      }
      return [...prev, { product, quantity: 1, discount: 0, discountType: 'amount' as const }];
    });
  };

  const updateQuantity = (productId: string, rawQuantity: number | string) => {
    // Sanitize string to allow only digits, comma, period
    const sanitized = typeof rawQuantity === 'string' ? rawQuantity.replace(/[^0-9.,]/g, '') : rawQuantity;
    
    // Prevent negative numbers if it's somehow passed as number
    if (typeof sanitized === 'number' && sanitized < 0) return;
    
    // Check if it's completely empty or parses to 0 -> allow to stay as string to type further
    setCart(prev => prev.map(item => item.product.id === productId ? { ...item, quantity: sanitized as any } : item));
  };
  
  const parseQty = (val: any) => {
    if (!val) return 0;
    const str = String(val).replace(',', '.');
    const parsed = parseFloat(str);
    return isNaN(parsed) ? 0 : parsed;
  };
  
  const getAbsoluteDiscount = (item: { product: Product, quantity: any, discount: number, discountType?: 'amount' | 'percent' }) => {
    if (item.discountType === 'percent') {
      const qty = parseQty(item.quantity);
      const actualUnitPrice = pricedItems[item.product.id]?.unitPrice ?? item.product.retailPrice;
      return Math.round((actualUnitPrice * qty) * (item.discount || 0) / 100);
    }
    return item.discount || 0;
  };
  
  const updateDiscountType = (productId: string, type: 'amount' | 'percent') => {
    setCart(prev => prev.map(item => item.product.id === productId ? { 
      ...item, 
      discountType: type,
      discount: 0 // Reset value when switching types
    } : item));
  };
  
  const updateDiscount = (productId: string, rawDiscount: number | string) => {
    let discount = typeof rawDiscount === 'string' ? parseInt(rawDiscount.replace(/\D/g, '')) : rawDiscount;
    if (isNaN(discount)) discount = 0;
    setCart(prev => prev.map(item => item.product.id === productId ? { ...item, discount } : item));
  };

  const handleRemoveItem = (productId: string) => {
    setCart(prev => prev.filter(c => c.product.id !== productId));
  };

  // Quick Calcs — ưu tiên pricing engine nếu có
  const { grossSubtotal, totalDiscount, tempSubtotal } = useMemo(() => {
    let gross = 0;
    let discount = 0;
    cart.forEach(curr => {
      const qty = parseQty(curr.quantity);
      const unit = pricedItems[curr.product.id]?.unitPrice ?? curr.product.retailPrice;
      gross += unit * qty;
      discount += getAbsoluteDiscount(curr);
    });
    const sub = pricingSubtotal != null ? pricingSubtotal : Math.max(0, gross - discount);
    return { grossSubtotal: gross, totalDiscount: discount, tempSubtotal: sub };
  }, [cart, pricedItems, pricingSubtotal]);

  const tempTotal = tempSubtotal + (shippingFee || 0);

  const formatMoney = (amount: number) => {
    if (isNaN(amount)) return '0 đ';
    return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(amount);
  };

  const handleSubmit = async () => {
    if (!customerId || cart.length === 0) return;
    setIsSubmitting(true);
    try {
      const payload = {
        customerId,
        items: cart.filter(c => parseQty(c.quantity) > 0).map(c => ({ 
          productId: c.product.id, 
          quantity: parseQty(c.quantity), 
          manualDiscount: getAbsoluteDiscount(c)
        })),
        discountAmount: 0,
        shippingFee,
        notes: ''
      };
      await ordersApi.createOrder(getToken()!, payload);
      setShowSuccessModal(true);
    } catch (err: any) {
      toast.error(err.message || 'Lỗi thao tác, từ chối khai báo đơn hàng');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <>
      <Sheet open={isOpen} onOpenChange={(open) => !open && onClose()}>
        <SheetContent className="!w-[95vw] !max-w-[1500px] p-0 overflow-hidden bg-[#F8F9FA] flex flex-col h-full" side="right">
          <SheetHeader className="px-8 pt-8 pb-2 text-left z-10 border-none bg-transparent flex flex-row items-center justify-between gap-4">
          <div className="flex flex-col">
            <SheetTitle className="text-3xl font-bold tracking-tight text-foreground">Tạo đơn hàng mới</SheetTitle>
            <SheetDescription className="text-muted-foreground mt-1 text-sm font-medium">
              Tìm khách hàng và chọn sản phẩm để lên đơn hàng trực tiếp tại đây.
            </SheetDescription>
          </div>
        </SheetHeader>
        
        <div className="flex-1 overflow-y-auto py-4 px-6 flex flex-col gap-6">
          
          {/* STEP 1: Khách & Hàng */}
          <div className="flex flex-col lg:flex-row gap-6 h-full flex-1 min-h-0">
            
            {/* Lọc Khách hàng & Sản phẩm */}
            <div className="w-full lg:w-1/3 flex flex-col gap-6">
              <div className="relative z-20 bg-card border border-border/50 shadow-none rounded-[24px] flex flex-col">
                <div className="flex flex-row items-center justify-between p-5 pb-2">
                  <div className="text-sm font-semibold text-foreground">1. Khách hàng</div>
                  <Button variant="ghost" size="sm" onClick={() => setIsCustomerModalOpen(true)} className="h-8 px-2 text-primary hover:bg-primary/10">
                    <Plus size={16} className="mr-1" /> Thêm mới
                  </Button>
                </div>
                
                <div className="p-5 pt-2 space-y-4">
                {!selectedCustomer ? (
                  <div className="relative">
                    <Input
                      placeholder="Tìm theo tên hoặc SĐT..."
                      className="h-10 px-4 border-border/40 shadow-none bg-background/50 focus-visible:bg-background"
                      value={searchCustomer}
                      onChange={e => {
                        setSearchCustomer(e.target.value);
                        setShowCustomerDropdown(true);
                      }}
                      onFocus={() => setShowCustomerDropdown(true)}
                    />
                    {showCustomerDropdown && (
                      <div className="absolute z-50 mt-1 w-full bg-popover border border-border rounded-md shadow-lg max-h-60 overflow-auto">
                        {customers.length === 0 ? (
                          <div className="p-3 text-sm text-muted-foreground text-center">Không tìm thấy</div>
                        ) : (
                          customers.map(c => (
                            <div 
                              key={c.id} 
                              className="p-3 hover:bg-muted cursor-pointer flex flex-col border-b last:border-0"
                              onClick={() => {
                                setCustomerId(c.id);
                                setSelectedCustomerObj(c);
                                setSearchCustomer(c.phone || '');
                                setShowCustomerDropdown(false);
                              }}
                            >
                              <span className="font-medium text-sm">{c.fullName}</span>
                              <span className="text-xs text-muted-foreground">{c.phone} • Nhóm: {c.group?.name || 'Mặc định'}</span>
                            </div>
                          ))
                        )}
                      </div>
                    )}
                    {showCustomerDropdown && (
                      <div className="fixed inset-0 z-40" onClick={() => setShowCustomerDropdown(false)} />
                    )}
                  </div>
                ) : (
                  <div className="bg-transparent w-full p-2.5 rounded-[16px] border border-white/60 flex items-center justify-between">
                    <div className="flex items-center gap-3 min-w-0 pr-3 flex-1">
                      <div className="shrink-0">
                        <GenerativeAvatar name={selectedCustomer.fullName || 'User'} size={40} />
                      </div>
                      <div className="flex flex-col min-w-0 gap-1.5 flex-1">
                        <span className="font-semibold text-foreground leading-tight truncate">{selectedCustomer.fullName}</span>
                        {selectedCustomer.group?.name && (
                           <Badge variant="secondary" className="font-medium text-[10.5px] w-fit px-1.5 py-0 bg-primary/5 text-primary border-primary/10">
                             {selectedCustomer.group.name}
                           </Badge>
                        )}
                      </div>
                    </div>
                    <Button variant="ghost" size="sm" onClick={() => {setCustomerId(''); setSelectedCustomerObj(null); setSearchCustomer('');}} className="h-8 w-8 p-0 shrink-0 text-muted-foreground hover:bg-muted/50 hover:text-foreground rounded-full focus-visible:ring-0">
                      <X size={16} />
                    </Button>
                  </div>
                )}
                </div>
              </div>

              <div className="bg-card border border-border/50 shadow-none rounded-[24px] flex-1 flex flex-col min-h-[300px]">
                <div className="flex flex-row items-center justify-between p-5 pb-2">
                  <div className="text-sm font-semibold text-foreground">2. Tìm Sản phẩm</div>
                </div>
                
                <div className="p-5 pt-2 space-y-4 flex-1 flex flex-col overflow-hidden">
                <Input 
                  placeholder="Nhấn chuỗi SKU hoặc tên..." 
                  className="h-10 px-4 border-border/40 shadow-none bg-background/50 focus-visible:bg-background"
                  value={searchProduct}
                  onChange={e => setSearchProduct(e.target.value)}
                />
                
                <div className="flex flex-col gap-2 overflow-y-auto pr-1 flex-1 content-start mt-2">
                  {products.map(p => (
                    <div 
                      key={p.id} 
                      className="border border-transparent hover:border-border/60 bg-transparent p-2.5 px-4 rounded-xl flex items-center justify-between hover:bg-muted/50 cursor-pointer transition-all group" 
                      onClick={() => addToCart(p)}
                    >
                      <div className="flex flex-col min-w-0 pr-3 flex-1">
                        <div className="text-sm font-medium truncate group-hover:text-primary transition-colors" title={p.name}>{p.name}</div>
                        <div className="text-xs text-muted-foreground mt-0.5 truncate">{p.sku}</div>
                      </div>
                      <div className="flex items-center gap-3 shrink-0">
                        <span className="text-[13px] font-bold text-foreground group-hover:text-primary">{formatMoney(p.retailPrice)}</span>
                        <div className="bg-muted/50 group-hover:bg-primary group-hover:text-white text-muted-foreground rounded-full p-1.5 transition-all">
                          <Plus size={14} />
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
                </div>
              </div>
            </div>

            {/* Cột bên phải hiển thị giỏ hàng (Danh sách) & Thanh toán */}
            <div className="w-full lg:w-2/3 border border-border/50 shadow-none rounded-[24px] flex flex-col bg-card overflow-hidden h-full max-h-full">
              <div className="flex flex-row items-center justify-between p-5 pb-4 border-b border-border/40 shrink-0">
                <div className="text-sm font-semibold text-foreground">Giỏ hàng</div>
                <div className="text-sm text-muted-foreground font-medium flex items-center">
                  <span className="tabular-nums">{cart.length}</span> <span className="ml-1">sản phẩm</span>
                  <span className="mx-2 opacity-40">•</span> 
                  <span>Tổng số lượng:</span> <span className="ml-1 tabular-nums">{cart.reduce((acc, curr) => acc + parseQty(curr.quantity), 0)}</span>
                </div>
              </div>
              <div className="flex-1 overflow-auto relative">
                {cart.length === 0 ? (
                  <div className="h-full flex flex-col items-center justify-center text-muted-foreground opacity-50 py-20">
                     <ShoppingCart size={48} className="mb-4" />
                     <p>Chưa có sản phẩm nào</p>
                  </div>
                ) : (
                  <table className="w-full text-sm">
                    <thead className="bg-card sticky top-0 z-20">
                      <tr className="border-b border-border/40">
                        <th className="text-left uppercase tracking-wider text-[11px] font-semibold text-muted-foreground pb-4 pt-4 px-4">STT</th>
                        <th className="text-left uppercase tracking-wider text-[11px] font-semibold text-muted-foreground pb-4 pt-4">Sản phẩm</th>
                        <th className="text-center uppercase tracking-wider text-[11px] font-semibold text-muted-foreground pb-4 pt-4">Đ/V</th>
                        <th className="text-right uppercase tracking-wider text-[11px] font-semibold text-muted-foreground pb-4 pt-4">Đơn giá tạm</th>
                        <th className="text-center uppercase tracking-wider text-[11px] font-semibold text-muted-foreground pb-4 pt-4 w-[120px]">Số lượng</th>
                        <th className="text-center uppercase tracking-wider text-[11px] font-semibold text-muted-foreground pb-4 pt-4 w-[120px]">Chiết khấu</th>
                        <th className="text-right uppercase tracking-wider text-[11px] font-semibold text-muted-foreground pb-4 pt-4">Thành tiền</th>
                        <th className="text-center uppercase tracking-wider text-[11px] font-semibold text-muted-foreground pb-4 pt-4 px-4 w-[60px]"></th>
                      </tr>
                    </thead>
                    <tbody>
                      {cart.map((c, idx) => (
                        <tr key={c.product.id} className="border-b last:border-0 hover:bg-muted/10 transition-colors">
                          <td className="p-3 px-4 text-muted-foreground text-center">{idx + 1}</td>
                          <td className="p-3">
                            <div className="font-medium line-clamp-2">{c.product.name}</div>
                            <div className="text-xs text-muted-foreground">{c.product.sku}</div>
                          </td>
                          <td className="p-3 text-center text-muted-foreground">{c.product.unit}</td>
                          <td className="p-3 text-right">
                            {(() => {
                              const priced = pricedItems[c.product.id];
                              const displayPrice = priced ? priced.unitPrice : c.product.retailPrice;
                              return (
                                <div className="flex flex-col items-end gap-0.5">
                                  <span>{formatMoney(displayPrice)}</span>
                                  {priced && priced.source !== 'RETAIL' && (
                                    <Badge variant="outline" className={`text-[9px] uppercase tracking-wider px-1.5 py-0 shadow-none font-bold border-border/50 ${priced.source === 'SPECIAL' ? 'bg-foreground/5 text-foreground' : 'bg-muted/30 text-muted-foreground'}`}
                                      title={priced.note}
                                    >{priced.source === 'SPECIAL' ? 'Giá ĐB' : 'Nhóm'}</Badge>
                                  )}
                                </div>
                              );
                            })()}
                          </td>
                          <td className="py-2 px-3">
                            <div className="flex items-center justify-center gap-0.5 border border-transparent bg-muted/30 rounded-lg p-0.5 max-w-[100px] mx-auto transition-all hover:bg-muted/40 focus-within:bg-background focus-within:border-border/50 focus-within:shadow-sm">
                              <Button variant="ghost" size="icon" className="h-7 w-7 rounded-md hover:bg-background hover:shadow-sm text-muted-foreground focus-visible:ring-0" onClick={() => updateQuantity(c.product.id, parseQty(c.quantity) - 1)}>-</Button>
                              <Input 
                                type="text" 
                                className="h-7 w-10 text-center p-0 border-0 bg-transparent shadow-none focus-visible:ring-0 text-sm font-medium" 
                                value={c.quantity === 0 ? '' : c.quantity} 
                                onChange={e => {
                                  updateQuantity(c.product.id, e.target.value);
                                }}
                              />
                              <Button variant="ghost" size="icon" className="h-7 w-7 rounded-md hover:bg-background hover:shadow-sm text-muted-foreground focus-visible:ring-0" onClick={() => updateQuantity(c.product.id, parseQty(c.quantity) + 1)}>+</Button>
                            </div>
                          </td>
                          <td className="py-2 px-3 text-center">
                             <div className="flex items-center mx-auto w-[130px] border border-transparent bg-muted/30 rounded-lg p-0.5 transition-all focus-within:bg-background focus-within:border-border/50 focus-within:shadow-sm">
                                <Input 
                                  type="text" 
                                  value={c.discount === 0 ? '' : (c.discountType === 'percent' ? c.discount : new Intl.NumberFormat('vi-VN').format(c.discount))} 
                                  onChange={e => {
                                    const val = e.target.value.replace(/\D/g, '');
                                    if (c.discountType === 'percent') {
                                      let n = Number(val);
                                      if (n > 100) n = 100;
                                      updateDiscount(c.product.id, isNaN(n) ? 0 : n);
                                    } else {
                                      updateDiscount(c.product.id, Number(val));
                                    }
                                  }} 
                                  placeholder="0" 
                                  className="h-7 border-0 shadow-none bg-transparent text-right focus-visible:ring-0 px-2 rounded flex-1 min-w-0 font-medium" 
                                />
                                <div className="flex items-center gap-0.5 bg-muted/50 p-0.5 rounded-full shrink-0">
                                  <button 
                                    title="Tính theo %"
                                    className={`w-7 h-7 flex items-center justify-center rounded-full text-[11px] font-bold transition-all ${c.discountType === 'percent' ? 'bg-background text-foreground shadow-sm' : 'text-muted-foreground hover:text-foreground'}`}
                                    onClick={() => updateDiscountType(c.product.id, 'percent')}
                                  >%</button>
                                  <button 
                                    title="Tính theo VNĐ"
                                    className={`w-7 h-7 flex items-center justify-center rounded-full text-[11px] font-bold transition-all ${c.discountType !== 'percent' ? 'bg-background text-foreground shadow-sm' : 'text-muted-foreground hover:text-foreground'}`}
                                    onClick={() => updateDiscountType(c.product.id, 'amount')}
                                  >đ</button>
                                </div>
                             </div>
                          </td>
                          <td className="p-3 text-right font-bold text-primary">
                            {(() => {
                              const priced = pricedItems[c.product.id];
                              if (priced) return formatMoney(priced.lineTotal);
                              return formatMoney(Math.max(0, (c.product.retailPrice * (Number(c.quantity) || 0)) - getAbsoluteDiscount(c)));
                            })()}
                          </td>
                          <td className="p-3 px-4 text-center">
                            <Button variant="ghost" size="icon" className="h-8 w-8 text-destructive hover:bg-destructive/10 rounded-full" onClick={() => handleRemoveItem(c.product.id)}>
                              <Trash2 size={16} />
                            </Button>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                )}
              </div>

              {/* DOCKED CHECKOUT FOOTER (1 LINE) */}
              <div className="border-t border-border/40 bg-card p-4 px-6 shrink-0 flex items-center justify-between z-30">
                
                <div className="flex items-center gap-2">
                  <span className="text-muted-foreground text-[13px] font-medium">Tiền hàng:</span>
                  <span className="font-semibold text-foreground text-sm tabular-nums">{formatMoney(grossSubtotal)}</span>
                </div>

                {totalDiscount > 0 && (
                  <div className="flex items-center gap-2">
                    <span className="text-muted-foreground text-[13px] font-medium">Chiết khấu (-):</span>
                    <span className="font-bold text-red-600 text-[13px] tabular-nums">-{formatMoney(totalDiscount)}</span>
                  </div>
                )}
                
                <div className="flex items-center gap-2">
                  <Label className="text-muted-foreground text-[13px] font-medium">Phí Ship (+)</Label>
                  <div className="relative w-28 flex items-center bg-muted/20 border border-transparent focus-within:bg-background focus-within:border-border/50 focus-within:shadow-sm rounded-lg p-0.5 transition-all">
                    <Input 
                      type="text" 
                      value={!shippingFee ? '' : new Intl.NumberFormat('vi-VN').format(shippingFee)} 
                      onChange={e => {
                        const numericValue = Number(e.target.value.replace(/\D/g, ''));
                        setShippingFee(isNaN(numericValue) ? 0 : numericValue);
                      }} 
                      placeholder="0" 
                      className="h-7 border-0 bg-transparent shadow-none text-sm text-right pr-6 focus-visible:ring-0 font-semibold" 
                    />
                    <span className="absolute right-2.5 top-1/2 -translate-y-1/2 text-muted-foreground text-[11px] font-bold">đ</span>
                  </div>
                </div>

                <div className="flex items-center gap-2 border-l border-border/40 pl-6 h-6">
                  <span className="font-semibold text-muted-foreground text-sm">Tổng đơn:</span>
                  <span className="font-bold text-xl text-primary tracking-tight tabular-nums">{formatMoney(tempTotal)}</span>
                </div>

              </div>

            </div>
          </div>
        </div>
        
        <SheetFooter className="px-8 py-5 border-t border-border/40 bg-muted/20 shrink-0 text-sm">
          <div className="flex flex-col sm:flex-row w-full justify-between items-center gap-4">
            <div className="text-muted-foreground hidden sm:flex items-center gap-2">
                {!customerId ? <><Info size={16}/> Vui lòng chọn khách hàng để lưu đơn</> : 
                 cart.length === 0 ? <><Info size={16}/> Giỏ hàng trống</> : 
                 <><CheckCircle2 size={16} className="text-primary"/> Đã có thể xuất đơn</>
                }
            </div>
            <div className="flex items-center gap-3 w-full sm:w-auto">
              <Button variant="outline" onClick={onClose} disabled={isSubmitting} className="h-11 px-6 font-medium bg-white/50 border-border/40 hover:bg-white shadow-sm w-full sm:w-auto rounded-full transition-all duration-300">
                Huỷ bỏ
              </Button>
              <Button 
                onClick={handleSubmit} 
                disabled={isSubmitting || !customerId || cart.length === 0} 
                className="group relative overflow-hidden bg-neutral-950 hover:bg-black text-white shadow-[0_4px_14px_0_rgb(0,0,0,0.1)] hover:shadow-[0_6px_20px_rgba(0,0,0,0.23)] transition-all duration-300 font-bold px-8 h-11 rounded-full min-w-[180px] w-full sm:w-auto disabled:opacity-50 disabled:pointer-events-none"
              >
                {isSubmitting ? (
                  <Loader2 className="mr-2 h-5 w-5 animate-spin opacity-80" />
                ) : (
                  <Check className="mr-2 h-5 w-5 opacity-90 group-hover:rotate-[360deg] transition-all duration-700 ease-out" />
                )}
                <span>Tạo đơn hàng</span>
              </Button>
            </div>
          </div>
        </SheetFooter>
      </SheetContent>
    </Sheet>
    <CustomerFormModal 
      isOpen={isCustomerModalOpen} 
      onClose={() => setIsCustomerModalOpen(false)}
      onSuccess={(newCustomer) => {
        setIsCustomerModalOpen(false);
        if (newCustomer) {
          setCustomers(prev => {
            if (prev.some(c => c.id === newCustomer.id)) return prev;
            return [newCustomer, ...prev];
          });
          setCustomerId(newCustomer.id);
          setSelectedCustomerObj(newCustomer);
          setSearchCustomer(newCustomer.phone || newCustomer.fullName);
          setShowCustomerDropdown(false);
        }
        // Silent refetch to sync background data
        crmApi.getCustomers(getToken()!, { take: 500 })
          .then(res => setCustomers(res.data.filter(c => c.isActive)))
          .catch(console.error);
      }}
    />
    <Dialog open={showSuccessModal} onOpenChange={setShowSuccessModal}>
      <DialogContent className="sm:max-w-md bg-card border-border/50 shadow-2xl p-8 sm:rounded-[24px] text-center">
        <div className="flex flex-col items-center justify-center py-2">
          <div className="h-20 w-20 bg-green-500/10 rounded-full flex items-center justify-center mb-6">
            <Check className="h-10 w-10 text-green-600" strokeWidth={3} />
          </div>
          <DialogTitle className="text-xl font-bold text-foreground mb-2">Đã tạo đơn hàng thành công</DialogTitle>
          <DialogDescription className="text-[15px] text-muted-foreground leading-relaxed">
            Đơn hàng mới đã được lưu thành công vào hệ thống.
          </DialogDescription>
        </div>
        <div className="flex sm:justify-center flex-col sm:flex-row gap-3 mt-4">
          <Button variant="outline" className="h-11 rounded-full px-8 bg-muted/20 border-border/50 hover:bg-muted/50 font-medium w-full sm:w-auto" onClick={() => { 
            setShowSuccessModal(false); 
            setCart([]); 
            setCustomerId(''); 
            setSelectedCustomerObj(null);
            setShippingFee(0); 
            setSearchCustomer('');
          }}>
            Tạo đơn mới
          </Button>
          <Button className="h-11 rounded-full px-8 bg-neutral-950 hover:bg-black text-white font-semibold shadow-md w-full sm:w-auto" onClick={() => { setShowSuccessModal(false); onSuccess(); }}>
            Về danh sách
          </Button>
        </div>
      </DialogContent>
    </Dialog>
  </>
  );
}
