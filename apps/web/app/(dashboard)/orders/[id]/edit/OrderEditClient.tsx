'use client';

import { useState, useEffect, useMemo } from 'react';
import { crmApi, productsApi, ordersApi, Customer, Product } from '@/lib/api';
import { useAuth } from '@/lib/auth-context';
import { useRouter, useParams } from 'next/navigation';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
import { Loader2, Plus, Trash2, ShoppingCart, CheckCircle2, PackageOpen, Check, User, X, ArrowLeft, Info, Phone, Search } from 'lucide-react';
import { Badge } from '@/components/ui/badge';
import CustomerFormModal from '@/components/customers/CustomerFormModal';
import { toast } from 'sonner';

export default function OrderEditClient() {
  const { getToken, isLoading: isAuthLoading } = useAuth();
  const router = useRouter();
  const params = useParams();
  const orderId = params?.id as string;
  
  // Master data
  const [customers, setCustomers] = useState<Customer[]>([]);
  const [products, setProducts] = useState<Product[]>([]);
  
  // Selections
  const [customerId, setCustomerId] = useState<string>('');
  const [cart, setCart] = useState<{product: Product, quantity: any, discount: number, discountType?: 'amount' | 'percent'}[]>([]);
  const [searchProduct, setSearchProduct] = useState('');

  // Pricing preview (#10)
  const [pricedItems, setPricedItems] = useState<Record<string, { unitPrice: number; source: string; note: string; lineTotal: number }>>({});
  const [pricingSubtotal, setPricingSubtotal] = useState<number | null>(null);
  
  // Combobox Customer state
  const [searchCustomer, setSearchCustomer] = useState('');
  const [showCustomerDropdown, setShowCustomerDropdown] = useState(false);
  
  // Modals
  const [isCustomerModalOpen, setIsCustomerModalOpen] = useState(false);

  // Final calculations
  const [shippingFee, setShippingFee] = useState<number>(0);
  const [orderState, setOrderState] = useState<any>(null);
  
  // Status
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    if (!orderId || isAuthLoading) return;
    async function loadData() {
      try {
        const token = getToken()!;
        const [custRes, prodRes, orderRes] = await Promise.all([
          crmApi.getCustomers(token, { take: 500 }),
          productsApi.getProducts(token, { take: 1000 }),
          ordersApi.getOrder(token, orderId)
        ]);
        
        const activeCustomers = custRes.data.filter(c => c.isActive);
        const activeProducts = prodRes.data.filter(p => p.isActive);
        
        setCustomers(activeCustomers);
        setProducts(activeProducts);
        
        const order = orderRes;
        if (order.deliveryStatus !== 'PENDING') {
            toast.warning('Chỉ đơn hàng Đang xử lý mới được phép chỉnh sửa!');
            router.push(`/orders/${orderId}`);
            return;
        }

        setCustomerId(order.customerId);
        setSearchCustomer(order.snapshotCustomerPhone || order.snapshotCustomerName);
        setShippingFee(Number(order.shippingFee) || 0);
        setOrderState(order);
        
        // Reconstruct cart
        const initialCart = order.items?.map(item => {
          const match = activeProducts.find(p => p.id === item.productId);
          return {
            product: match || { id: item.productId, name: item.snapshotProductName, sku: item.snapshotProductSku, retailPrice: item.snapshotUnitPrice, unit: item.snapshotProductUnit, isActive: true },
            quantity: Number(item.quantity) || 0,
            discount: Number(item.lineDiscount) || 0,
            discountType: 'amount' as const
          };
        }) || [];
        setCart(initialCart as any);
      } catch (err) {
        console.error(err);
        toast.error('Hệ thống bị gián đoạn, từ chối tải thông tin đơn hàng');
        router.push('/orders');
      } finally {
        setIsLoading(false);
      }
    }
    loadData();
  }, [orderId, getToken, router, isAuthLoading]);

  // Debounced pricing preview khi customer hoặc cart thay đổi
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

  const filteredProducts = useMemo(() => {
    if (!searchProduct) return products;
    const lower = searchProduct.toLowerCase();
    return products.filter(p => p.name.toLowerCase().includes(lower) || p.sku.toLowerCase().includes(lower));
  }, [products, searchProduct]);

  const filteredCustomers = useMemo(() => {
    if (!searchCustomer) return customers.slice(0, 50); // Show max 50 default
    const lower = searchCustomer.toLowerCase();
    return customers.filter(c =>
      c.fullName.toLowerCase().includes(lower) || (c.phone && c.phone.includes(lower))
    );
  }, [customers, searchCustomer]);

  const selectedCustomer = useMemo(() => customers.find(c => c.id === customerId), [customers, customerId]);

  const addToCart = (product: Product) => {
    setCart(prev => {
      const existing = prev.find(item => item.product.id === product.id);
      if (existing) {
        return prev.map(item => item.product.id === product.id ? { ...item, quantity: item.quantity + 1 } : item);
      }
      return [...prev, { product, quantity: 1, discount: 0, discountType: 'amount' as const }];
    });
  };

  const updateQuantity = (productId: string, rawQuantity: number | string) => {
    let sanitized = typeof rawQuantity === 'string' ? rawQuantity.replace(/[^0-9.,]/g, '') : rawQuantity;
    if (typeof sanitized === 'number' && sanitized < 0) return;
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
      return Math.round((item.product.retailPrice * qty) * (item.discount || 0) / 100);
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

  const tempSubtotal = pricingSubtotal != null ? pricingSubtotal : cart.reduce((acc, curr) => {
    const qty = parseQty(curr.quantity);
    return acc + Math.max(0, (curr.product.retailPrice * qty) - getAbsoluteDiscount(curr));
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
          manualDiscount: getAbsoluteDiscount(c)
        })),
        discountAmount: 0,
        shippingFee,
        notes: ''
      };
      await ordersApi.updateOrder(getToken()!, orderId, payload);
      toast.success('Lưu phiên bản mới của đơn hàng hoàn tất!');
      router.push(`/orders/${orderId}`);
    } catch (err: any) {
      toast.error(err.message || 'Lỗi thao tác, hệ thống từ chối lưu thay đổi');
      setIsSubmitting(false);
    }
  };

  if (isLoading) {
    return (
      <div className="flex h-[calc(100vh-100px)] items-center justify-center bg-background">
        <Loader2 className="h-8 w-8 animate-spin text-primary" />
      </div>
    );
  }

  return (
    <div className="flex flex-col gap-6 h-[calc(100vh-96px)] lg:h-[calc(100vh-112px)] overflow-hidden">
        {/* Header */}
        <div className="text-left shrink-0 flex items-center gap-4">
          <Button variant="outline" size="icon" onClick={() => router.back()} className="h-10 w-10 shrink-0 bg-background hover:bg-muted shadow-sm">
            <ArrowLeft className="h-5 w-5 text-muted-foreground" />
          </Button>
          <div className="flex-1 min-w-0">
            <h1 className="text-3xl font-bold tracking-tight text-foreground flex items-center gap-3">
              Chỉnh sửa Hóa đơn {orderState?.orderNumber || '...'}
              <Badge variant="outline" className="bg-yellow-50 text-yellow-700 border-yellow-200 shadow-sm px-3 py-1">Đang xử lý</Badge>
            </h1>
            <p className="text-sm text-muted-foreground mt-1">
              Ngày lập: {orderState ? new Date(orderState.createdAt).toLocaleString('vi-VN') : '...'} <span className="mx-1">•</span> Thu ngân: {orderState?.createdBy?.fullName || 'Hệ thống'}
            </p>
          </div>
        </div>
        
        {/* Content */}
        <div className="flex-1 overflow-y-auto pb-4 flex flex-col gap-6 text-sm">
          <div className="flex flex-col lg:flex-row gap-6 h-full flex-1 min-h-0">

            {/* LEFT: Customer + Product Search */}
            <div className="w-full lg:w-1/3 flex flex-col gap-6">
              <div className="space-y-4 p-5 bg-card border rounded-xl shadow-sm">
                <div className="flex items-center gap-2 text-foreground font-semibold justify-between border-b pb-3">
                  <div className="flex items-center gap-2">
                    <User size={18} className="text-primary shrink-0" />
                    <h3>1. Khách hàng</h3>
                  </div>
                  <Button variant="ghost" size="sm" onClick={() => setIsCustomerModalOpen(true)} className="h-8 px-2 text-primary hover:text-primary hover:bg-primary/10 focus-visible:ring-0">
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
                  <div className="bg-primary/10 w-full p-2.5 px-3 rounded-lg border border-primary/30 flex items-center justify-between shadow-sm">
                    <div className="flex flex-col min-w-0 flex-1 pr-3">
                      <div className="flex flex-wrap items-center gap-2">
                        <strong className="text-primary text-sm truncate max-w-full">{selectedCustomer.fullName}</strong>
                        <Badge variant="secondary" className="bg-primary/20/80 text-primary hover:bg-primary/30/80 px-2 py-0 mx-1">{selectedCustomer.group?.name || 'Khách lẻ'}</Badge>
                      </div>
                      <div className="text-xs text-primary/80 mt-0.5">{selectedCustomer.phone}</div>
                    </div>
                    <Button variant="ghost" size="sm" onClick={() => {setCustomerId(''); setSearchCustomer('');}} className="h-7 w-7 p-0 shrink-0 text-primary hover:text-primary hover:bg-primary/20 rounded-full focus-visible:ring-0">
                      <X size={16} />
                    </Button>
                  </div>
                )}
              </div>

              <div className="space-y-4 p-5 bg-card border rounded-xl shadow-sm flex-1 flex flex-col min-h-[300px]">
                <div className="flex items-center gap-2 text-foreground font-semibold border-b pb-3">
                  <PackageOpen size={18} className="text-primary shrink-0" />
                  <h3>2. Tìm Sản phẩm</h3>
                </div>
                <div className="relative">
                  <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground" />
                  <Input 
                    placeholder="Nhấn chuỗi SKU hoặc tên..." 
                    className="h-10 border-muted-foreground/20 shadow-sm pl-9"
                    value={searchProduct}
                    onChange={e => setSearchProduct(e.target.value)}
                  />
                </div>
                
                <div className="flex flex-col gap-2 overflow-y-auto pr-1 flex-1 content-start mt-2">
                  {filteredProducts.map(p => (
                    <div 
                      key={p.id} 
                      className="border border-muted/60 bg-card p-2.5 px-3 rounded-lg flex items-center justify-between hover:border-primary hover:bg-primary/10 cursor-pointer transition-colors group shadow-sm" 
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

            {/* RIGHT: Cart Table */}
            <div className="w-full lg:w-2/3 border rounded-xl shadow-sm flex flex-col bg-card overflow-hidden h-full max-h-[calc(100vh-230px)]">
              <div className="p-4 border-b bg-muted/40 text-foreground font-semibold flex items-center justify-between shrink-0">
                <div className="flex items-center gap-2">
                  <ShoppingCart size={18} className="text-primary" />
                  <h3>Giỏ hàng đang sửa ({cart.length} mục - Tổng SL: {cart.reduce((acc, curr) => acc + parseQty(curr.quantity), 0)})</h3>
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
                             <div className="flex items-center mx-auto w-[120px] bg-background border shadow-sm rounded-md focus-within:ring-1 focus-within:ring-primary overflow-hidden text-sm">
                                <Input 
                                  type="text" 
                                  value={c.discount === 0 ? '' : (c.discountType === 'percent' ? c.discount : new Intl.NumberFormat('vi-VN').format(c.discount))} 
                                  onChange={e => {
                                    let val = e.target.value.replace(/\D/g, '');
                                    if (c.discountType === 'percent') {
                                      let n = Number(val);
                                      if (n > 100) n = 100;
                                      updateDiscount(c.product.id, isNaN(n) ? 0 : n);
                                    } else {
                                      updateDiscount(c.product.id, Number(val));
                                    }
                                  }} 
                                  placeholder="0" 
                                  className="h-8 border-0 shadow-none text-right focus-visible:ring-0 pr-1 rounded-none flex-1 min-w-0" 
                                />
                                <div className="flex shrink-0 border-l bg-muted/60">
                                  <button 
                                    title="Tính theo %"
                                    className={`px-1.5 py-1 text-[11px] font-semibold transition-colors ${c.discountType === 'percent' ? 'bg-primary/20 text-primary' : 'text-muted-foreground hover:bg-muted'}`}
                                    onClick={() => updateDiscountType(c.product.id, 'percent')}
                                  >%</button>
                                  <button 
                                    title="Tính theo VNĐ"
                                    className={`px-1.5 py-1 text-[11px] font-semibold transition-colors ${c.discountType !== 'percent' ? 'bg-primary/20 text-primary' : 'text-muted-foreground hover:bg-muted'}`}
                                    onClick={() => updateDiscountType(c.product.id, 'amount')}
                                  >đ</button>
                                </div>
                             </div>
                          </td>
                          <td className="p-3 text-right font-bold text-primary">
                            {(() => {
                               const priced = pricedItems[c.product.id];
                               if (priced) {
                                 return formatMoney(priced.lineTotal);
                               }
                               const qty = parseQty(c.quantity);
                               return formatMoney(Math.max(0, (c.product.retailPrice * qty) - getAbsoluteDiscount(c)));
                            })()}
                          </td>
                          <td className="p-3 px-4 text-center">
                            <Button variant="ghost" size="icon" className="h-7 w-7 text-muted-foreground hover:text-destructive hover:bg-destructive/10 rounded-full" onClick={() => handleRemoveItem(c.product.id)}>
                              <Trash2 size={14} />
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
                      className="h-8 text-sm text-right pr-6 bg-background shadow-sm font-semibold border-primary/30 focus-visible:ring-primary" 
                    />
                    <span className="absolute right-2 top-1/2 -translate-y-1/2 text-muted-foreground text-xs font-medium text-primary">đ</span>
                  </div>
                </div>

                <div className="flex items-baseline gap-2 bg-primary/5 p-1.5 px-3 rounded-lg border border-primary/20">
                  <span className="font-bold text-primary text-sm tracking-wide">Tổng cộng:</span>
                  <span className="font-extrabold text-lg text-primary tracking-tight">{formatMoney(tempTotal)}</span>
                </div>
              </div>
            </div>

          </div>
        </div>
        
        {/* Sticky Bottom Bar */}
        <div className="py-3 border-t bg-background shrink-0 text-sm z-10 w-full relative shadow-[0_-5px_15px_-5px_rgba(0,0,0,0.05)]">
          <div className="flex flex-col sm:flex-row w-full justify-between items-center gap-4">
            <div className="text-muted-foreground hidden sm:flex items-center gap-2 bg-muted/50 px-3 py-1.5 rounded-full text-xs">
                {!customerId ? <><Info size={14}/> Chọn khách hàng trước làm phiếu sửa</> : 
                 cart.length === 0 ? <><Info size={14}/> Giỏ hàng trống</> : 
                 <><CheckCircle2 size={14} className="text-primary"/> Sẵn sàng lưu thay đổi</>
                }
            </div>
            <div className="flex items-center gap-3 w-full sm:w-auto">
              <Button variant="outline" onClick={() => router.back()} disabled={isSubmitting} className="h-10 px-6 font-medium shadow-sm w-full sm:w-auto">
                Huỷ bỏ
              </Button>
              <Button onClick={handleSubmit} disabled={isSubmitting || !customerId || cart.length === 0} className="min-w-[140px] shadow-lg h-10 w-full sm:w-auto font-semibold">
                {isSubmitting ? (
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                ) : (
                  <Check className="mr-2 h-4 w-4" />
                )}
                Cập nhật
              </Button>
            </div>
          </div>
        </div>

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
        }}
      />
    </div>
  );
}
