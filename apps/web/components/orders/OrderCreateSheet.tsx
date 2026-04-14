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

interface OrderCreateSheetProps {
  isOpen: boolean;
  onClose: () => void;
  onSuccess: () => void;
}

export default function OrderCreateSheet({ isOpen, onClose, onSuccess }: OrderCreateSheetProps) {
  const { getToken } = useAuth();
  
  // Master data
  const [customers, setCustomers] = useState<Customer[]>([]);
  const [products, setProducts] = useState<Product[]>([]);
  
  // Selections
  const [customerId, setCustomerId] = useState<string>('');
  const [cart, setCart] = useState<{product: Product, quantity: number, discount: number}[]>([]);
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
      crmApi.getCustomers(token, { take: 500 }).then(res => {
        setCustomers(res.data.filter(c => c.isActive));
      }).catch(console.error);
      productsApi.getProducts(token, { take: 1000 }).then(res => setProducts(res.data.filter(p => p.isActive))).catch(console.error);
      
      // Reset state
      setCustomerId('');
      setCart([]);
      setShippingFee(0);
      setSearchCustomer('');
      setShowCustomerDropdown(false);
      setPricedItems({});
      setPricingSubtotal(null);
    }
  }, [isOpen, getToken]);

  const filteredProducts = useMemo(() => {
    if (!searchProduct) return products;
    const lower = searchProduct.toLowerCase();
    return products.filter(p => p.name.toLowerCase().includes(lower) || p.sku.toLowerCase().includes(lower));
  }, [products, searchProduct]);

  const filteredCustomers = useMemo(() => {
    if (!searchCustomer) return customers.slice(0, 50); // Show max 50 default
    const lower = searchCustomer.toLowerCase();
    return customers.filter(c =>
      c.fullName.toLowerCase().includes(lower) || c.phone.includes(lower)
    );
  }, [customers, searchCustomer]);

  const selectedCustomer = useMemo(() => customers.find(c => c.id === customerId), [customers, customerId]);

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
            manualDiscount: c.discount || 0,
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
        return prev.map(item => item.product.id === product.id ? { ...item, quantity: item.quantity + 1 } : item);
      }
      return [{ product, quantity: 1, discount: 0 }, ...prev];
    });
  };

  const updateQuantity = (productId: string, rawQuantity: number | string) => {
    // Sanitize string to allow only digits, comma, period
    let sanitized = typeof rawQuantity === 'string' ? rawQuantity.replace(/[^0-9.,]/g, '') : rawQuantity;
    
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
  
  const updateDiscount = (productId: string, rawDiscount: number | string) => {
    let discount = typeof rawDiscount === 'string' ? parseInt(rawDiscount.replace(/\D/g, '')) : rawDiscount;
    if (isNaN(discount)) discount = 0;
    setCart(prev => prev.map(item => item.product.id === productId ? { ...item, discount } : item));
  };

  const handleRemoveItem = (productId: string) => {
    setCart(prev => prev.filter(c => c.product.id !== productId));
  };

  // Quick Calcs — ưu tiên pricing engine nếu có
  const tempSubtotal = pricingSubtotal != null ? pricingSubtotal : cart.reduce((acc, curr) => {
    const qty = parseQty(curr.quantity);
    return acc + Math.max(0, (curr.product.retailPrice * qty) - (curr.discount || 0));
  }, 0);
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
          manualDiscount: c.discount || 0
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
        <SheetContent className="!w-[95vw] !max-w-[1500px] p-0 overflow-hidden bg-background flex flex-col h-full" side="right">
          <SheetHeader className="px-6 py-4 border-b bg-muted/40 text-left">
          <SheetTitle className="text-xl">Tạo Đơn Hàng Mới</SheetTitle>
          <SheetDescription>
            Tìm khách hàng và chọn sản phẩm để lên đơn hàng trực tiếp tại đây.
          </SheetDescription>
        </SheetHeader>
        
        <div className="flex-1 overflow-y-auto py-4 px-6 flex flex-col gap-6">
          
          {/* STEP 1: Khách & Hàng */}
          <div className="flex flex-col lg:flex-row gap-6 h-full flex-1 min-h-0">
            
            {/* Lọc Khách hàng & Sản phẩm */}
            <div className="w-full lg:w-1/3 flex flex-col gap-6">
              <div className="space-y-4 p-5 bg-card border rounded-xl shadow-sm">
                <div className="flex items-center gap-2 text-foreground font-semibold justify-between border-b pb-3">
                  <div className="flex items-center gap-2">
                    <User size={18} className="text-emerald-600 shrink-0" />
                    <h3>1. Khách hàng</h3>
                  </div>
                  <Button variant="ghost" size="sm" onClick={() => setIsCustomerModalOpen(true)} className="h-8 px-2 text-emerald-600 hover:text-emerald-700 hover:bg-emerald-50 focus-visible:ring-0">
                    <Plus size={16} className="mr-1" /> Thêm mới
                  </Button>
                </div>
                
                {!selectedCustomer ? (
                  <div className="relative">
                    <Input
                      placeholder="Tìm theo tên hoặc SĐT..."
                      className="h-10 border-muted-foreground/20 shadow-sm"
                      value={searchCustomer}
                      onChange={e => {
                        setSearchCustomer(e.target.value);
                        setShowCustomerDropdown(true);
                      }}
                      onFocus={() => setShowCustomerDropdown(true)}
                    />
                    {showCustomerDropdown && (
                      <div className="absolute z-50 mt-1 w-full bg-popover border border-border rounded-md shadow-lg max-h-60 overflow-auto">
                        {filteredCustomers.length === 0 ? (
                          <div className="p-3 text-sm text-muted-foreground text-center">Không tìm thấy</div>
                        ) : (
                          filteredCustomers.map(c => (
                            <div 
                              key={c.id} 
                              className="p-3 hover:bg-muted cursor-pointer flex flex-col border-b last:border-0"
                              onClick={() => {
                                setCustomerId(c.id);
                                setSearchCustomer(c.phone);
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
                  <div className="bg-emerald-50 w-full p-2.5 px-3 rounded-lg border border-emerald-200 flex items-center justify-between shadow-sm">
                    <div className="flex flex-col min-w-0 flex-1 pr-3">
                      <div className="flex flex-wrap items-center gap-2">
                        <strong className="text-emerald-800 text-sm truncate max-w-full">{selectedCustomer.fullName}</strong>
                        <Badge variant="secondary" className="bg-emerald-100/80 text-emerald-800 hover:bg-emerald-200/80 px-2 py-0 mx-1">{selectedCustomer.group?.name || 'Khách lẻ'}</Badge>
                      </div>
                      <div className="text-xs text-emerald-600/80 mt-0.5">{selectedCustomer.phone}</div>
                    </div>
                    <Button variant="ghost" size="sm" onClick={() => {setCustomerId(''); setSearchCustomer('');}} className="h-7 w-7 p-0 shrink-0 text-emerald-600 hover:text-emerald-700 hover:bg-emerald-100 rounded-full focus-visible:ring-0">
                      <X size={16} />
                    </Button>
                  </div>
                )}
              </div>

              <div className="space-y-4 p-5 bg-card border rounded-xl shadow-sm flex-1 flex flex-col min-h-[300px]">
                <div className="flex items-center gap-2 text-foreground font-semibold border-b pb-3">
                  <PackageOpen size={18} className="text-emerald-600 shrink-0" />
                  <h3>2. Tìm Sản phẩm</h3>
                </div>
                <Input 
                  placeholder="Nhấn chuỗi SKU hoặc tên..." 
                  className="h-10 border-muted-foreground/20 shadow-sm"
                  value={searchProduct}
                  onChange={e => setSearchProduct(e.target.value)}
                />
                
                <div className="flex flex-col gap-2 overflow-y-auto pr-1 flex-1 content-start mt-2">
                  {filteredProducts.map(p => (
                    <div 
                      key={p.id} 
                      className="border border-muted/60 bg-card p-2.5 px-3 rounded-lg flex items-center justify-between hover:border-emerald-500 hover:bg-emerald-50 cursor-pointer transition-colors group shadow-sm" 
                      onClick={() => addToCart(p)}
                    >
                      <div className="flex flex-col min-w-0 pr-3 flex-1">
                        <div className="text-sm font-medium truncate group-hover:text-emerald-800 transition-colors" title={p.name}>{p.name}</div>
                        <div className="text-xs text-muted-foreground mt-0.5 truncate">{p.sku}</div>
                      </div>
                      <div className="flex items-center gap-3 shrink-0">
                        <span className="text-[13px] font-bold text-foreground group-hover:text-emerald-700">{formatMoney(p.retailPrice)}</span>
                        <div className="bg-muted/50 group-hover:bg-emerald-600 group-hover:text-white text-muted-foreground rounded-full p-1.5 transition-all">
                          <Plus size={14} />
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>

            {/* Cột bên phải hiển thị giỏ hàng (Danh sách) & Thanh toán */}
            <div className="w-full lg:w-2/3 border rounded-xl shadow-sm flex flex-col bg-card overflow-hidden h-full max-h-full">
              <div className="p-4 border-b bg-muted/40 text-foreground font-semibold flex items-center justify-between shrink-0">
                <div className="flex items-center gap-2">
                  <ShoppingCart size={18} className="text-emerald-600" />
                  <h3>Giỏ hàng ({cart.length} mục)</h3>
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
                    <thead className="bg-muted sticky top-0 z-20 text-muted-foreground shadow-sm">
                      <tr>
                        <th className="text-left font-semibold p-3 px-4 border-b">STT</th>
                        <th className="text-left font-semibold p-3 border-b">Sản phẩm</th>
                        <th className="text-center font-semibold p-3 border-b">Đ/V</th>
                        <th className="text-right font-semibold p-3 border-b">Đơn giá tạm</th>
                        <th className="text-center font-semibold p-3 border-b w-[120px]">Số lượng</th>
                        <th className="text-center font-semibold p-3 border-b w-[120px]">Chiết khấu</th>
                        <th className="text-right font-semibold p-3 border-b">Thành tiền</th>
                        <th className="text-center font-semibold p-3 px-4 border-b w-[60px]">X</th>
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
                                    <Badge variant="secondary" className={`text-[10px] px-1.5 py-0 ${priced.source === 'SPECIAL' ? 'bg-purple-100 text-purple-700' : 'bg-blue-100 text-blue-700'}`}
                                      title={priced.note}
                                    >{priced.source === 'SPECIAL' ? 'Giá ĐB' : 'Nhóm'}</Badge>
                                  )}
                                </div>
                              );
                            })()}
                          </td>
                          <td className="p-3">
                            <div className="flex items-center justify-center gap-1 border rounded-md p-0.5 max-w-[100px] mx-auto">
                              <Button variant="ghost" size="icon" className="h-6 w-6 rounded-sm" onClick={() => updateQuantity(c.product.id, parseQty(c.quantity) - 1)}>-</Button>
                              <Input 
                                type="text" 
                                className="h-6 w-10 text-center p-0 border-0 shadow-none focus-visible:ring-0 text-sm" 
                                value={c.quantity === 0 ? '' : c.quantity} 
                                onChange={e => {
                                  updateQuantity(c.product.id, e.target.value);
                                }}
                              />
                              <Button variant="ghost" size="icon" className="h-6 w-6 rounded-sm" onClick={() => updateQuantity(c.product.id, parseQty(c.quantity) + 1)}>+</Button>
                            </div>
                          </td>
                          <td className="p-3 text-center">
                             <Input 
                                type="text" 
                                value={c.discount === 0 ? '' : new Intl.NumberFormat('vi-VN').format(c.discount)} 
                                onChange={e => {
                                  const numericValue = Number(e.target.value.replace(/\D/g, ''));
                                  updateDiscount(c.product.id, numericValue);
                                }} 
                                placeholder="0" 
                                className="h-8 max-w-[100px] mx-auto text-right bg-background shadow-sm text-sm" 
                              />
                          </td>
                          <td className="p-3 text-right font-bold text-emerald-600">
                            {(() => {
                              const priced = pricedItems[c.product.id];
                              if (priced) return formatMoney(priced.lineTotal);
                              return formatMoney(Math.max(0, (c.product.retailPrice * (Number(c.quantity) || 0)) - (c.discount || 0)));
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
              <div className="border-t bg-muted/20 p-3 px-5 shrink-0 flex items-center justify-between shadow-[0_-5px_15px_-5px_rgba(0,0,0,0.05)] z-30">
                
                <div className="flex items-center gap-2">
                  <span className="text-muted-foreground text-xs font-medium">Tạm tính:</span>
                  <span className="font-semibold text-foreground text-sm">{formatMoney(tempSubtotal)}</span>
                </div>
                
                <div className="flex items-center gap-2">
                  <Label className="text-muted-foreground text-xs font-semibold">Phí Ship (+)</Label>
                  <div className="relative w-28">
                    <Input 
                      type="text" 
                      value={!shippingFee ? '' : new Intl.NumberFormat('vi-VN').format(shippingFee)} 
                      onChange={e => {
                        const numericValue = Number(e.target.value.replace(/\D/g, ''));
                        setShippingFee(isNaN(numericValue) ? 0 : numericValue);
                      }} 
                      placeholder="0" 
                      className="h-8 text-sm text-right pr-6 bg-background shadow-sm font-semibold border-emerald-200 focus-visible:ring-emerald-500" 
                    />
                    <span className="absolute right-2 top-1/2 -translate-y-1/2 text-muted-foreground text-xs font-medium text-emerald-600">đ</span>
                  </div>
                </div>

                <div className="flex items-baseline gap-2 bg-emerald-50/50 p-1.5 px-3 rounded-lg border border-emerald-100">
                  <span className="font-bold text-emerald-800 text-sm tracking-wide">Tổng đơn:</span>
                  <span className="font-extrabold text-lg text-emerald-600 tracking-tight">{formatMoney(tempTotal)}</span>
                </div>

              </div>

            </div>
          </div>
        </div>
        
        <SheetFooter className="px-6 py-4 border-t bg-muted/10 shrink-0 text-sm">
          <div className="flex flex-col sm:flex-row w-full justify-between items-center gap-4">
            <div className="text-muted-foreground hidden sm:flex items-center gap-2">
                {!customerId ? <><Info size={16}/> Vui lòng chọn khách hàng để lưu đơn</> : 
                 cart.length === 0 ? <><Info size={16}/> Giỏ hàng trống</> : 
                 <><CheckCircle2 size={16} className="text-emerald-500"/> Đã có thể xuất đơn</>
                }
            </div>
            <div className="flex items-center gap-3 w-full sm:w-auto">
              <Button variant="outline" onClick={onClose} disabled={isSubmitting} className="h-10 px-6 font-medium shadow-sm w-full sm:w-auto">
                Huỷ bỏ
              </Button>
              <Button onClick={handleSubmit} disabled={isSubmitting || !customerId || cart.length === 0} className="bg-emerald-600 hover:bg-emerald-700 text-white min-w-[180px] shadow-md h-10 w-full sm:w-auto">
                {isSubmitting ? (
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                ) : (
                  <Check className="mr-2 h-4 w-4" />
                )}
                Chốt Đơn
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
      <DialogContent className="glass sm:max-w-md text-center">
        <div className="flex flex-col items-center justify-center py-6">
          <CheckCircle2 className="h-16 w-16 text-emerald-500 mb-4" />
          <DialogTitle className="text-2xl font-bold text-emerald-600 mb-2">Chốt đơn thành công!</DialogTitle>
          <DialogDescription className="text-base">
            Đơn hàng của bạn đã được ghi nhận vào hệ thống.
          </DialogDescription>
        </div>
        <DialogFooter className="sm:justify-center flex-col sm:flex-row gap-2">
          <Button variant="outline" onClick={() => { 
            setShowSuccessModal(false); 
            setCart([]); 
            setCustomerId(''); 
            setShippingFee(0); 
            setSearchCustomer('');
          }}>
            Tạo đơn mới
          </Button>
          <Button className="bg-emerald-600 hover:bg-emerald-700 text-white" onClick={() => { setShowSuccessModal(false); onSuccess(); }}>
            Về danh sách
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  </>
  );
}
