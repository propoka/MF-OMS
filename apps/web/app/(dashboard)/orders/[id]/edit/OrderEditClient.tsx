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
  const [cart, setCart] = useState<{product: Product, quantity: number, discount: number}[]>([]);
  const [searchProduct, setSearchProduct] = useState('');
  
  // Combobox Customer state
  const [searchCustomer, setSearchCustomer] = useState('');
  const [showCustomerDropdown, setShowCustomerDropdown] = useState(false);
  
  // Modals
  const [isCustomerModalOpen, setIsCustomerModalOpen] = useState(false);

  // Final calculations
  const [shippingFee, setShippingFee] = useState<number>(0);
  
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
        
        // Reconstruct cart
        const initialCart = order.items?.map(item => {
          const match = activeProducts.find(p => p.id === item.productId);
          return {
            product: match || { id: item.productId, name: item.snapshotProductName, sku: item.snapshotProductSku, retailPrice: item.snapshotUnitPrice, unit: item.snapshotProductUnit, isActive: true },
            quantity: Number(item.quantity) || 0,
            discount: Number(item.lineDiscount) || 0
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
  
  const updateDiscount = (productId: string, rawDiscount: number | string) => {
    let discount = typeof rawDiscount === 'string' ? parseInt(rawDiscount.replace(/\D/g, '')) : rawDiscount;
    if (isNaN(discount)) discount = 0;
    setCart(prev => prev.map(item => item.product.id === productId ? { ...item, discount } : item));
  };

  const handleRemoveItem = (productId: string) => {
    setCart(prev => prev.filter(c => c.product.id !== productId));
  };

  const tempSubtotal = cart.reduce((acc, curr) => {
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
    <div className="flex flex-col h-[calc(100vh-80px)] overflow-hidden">
        {/* Header */}
        <div className="px-6 py-4 border-b bg-muted/30 text-left shrink-0 flex items-center justify-between">
          <div className="flex items-center gap-4">
            <Button variant="ghost" size="icon" onClick={() => router.back()} className="h-8 w-8 rounded-full border shadow-sm bg-background hover:bg-muted">
              <ArrowLeft className="h-4 w-4" />
            </Button>
            <div>
              <h1 className="text-2xl font-bold text-foreground tracking-tight">Chỉnh sửa Đơn Hàng</h1>
              <p className="text-sm text-muted-foreground mt-0.5">Thay đổi chi tiết số lượng sản phẩm, giá hoặc trạng thái khách hàng.</p>
            </div>
          </div>
        </div>
        
        {/* Content */}
        <div className="flex-1 overflow-y-auto py-4 px-6 flex flex-col gap-6">
          <div className="flex flex-col lg:flex-row gap-6 h-full flex-1 min-h-0">

            {/* LEFT: Customer + Product Search */}
            <div className="w-full lg:w-1/3 flex flex-col gap-5">

              {/* Customer Card */}
              <Card className="glass border-muted/50 shadow-sm">
                <CardHeader className="bg-muted/30 border-b py-3 px-4 flex flex-row items-center justify-between space-y-0">
                  <CardTitle className="text-sm font-semibold flex items-center gap-2">
                    <User size={16} className="text-primary" />
                    1. Khách hàng
                  </CardTitle>
                  <Button variant="ghost" size="sm" onClick={() => setIsCustomerModalOpen(true)} className="h-7 px-2 text-primary hover:text-primary hover:bg-primary/10 focus-visible:ring-0 text-xs">
                    <Plus size={14} className="mr-1" /> Thêm mới
                  </Button>
                </CardHeader>
                <CardContent className="p-4">
                  {!selectedCustomer ? (
                    <div className="relative">
                      <Input
                        placeholder="Tìm theo tên hoặc SĐT..."
                        className="h-10 border-input shadow-sm"
                        value={searchCustomer}
                        onChange={e => {
                          setSearchCustomer(e.target.value);
                          setShowCustomerDropdown(true);
                        }}
                        onFocus={() => setShowCustomerDropdown(true)}
                      />
                      {showCustomerDropdown && (
                        <div className="absolute z-50 mt-1 w-full bg-popover border border-border rounded-lg shadow-lg max-h-60 overflow-auto">
                          {filteredCustomers.length === 0 ? (
                            <div className="p-3 text-sm text-muted-foreground text-center">Không tìm thấy</div>
                          ) : (
                            filteredCustomers.map(c => (
                              <div 
                                key={c.id} 
                                className="p-3 hover:bg-muted/50 cursor-pointer flex flex-col border-b border-border/30 last:border-0 transition-colors"
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
                    <div className="bg-primary/5 w-full p-3 rounded-lg border border-primary/20 flex items-center justify-between">
                      <div className="flex items-center gap-3 min-w-0 flex-1 pr-3">
                        <div className="h-9 w-9 rounded-full bg-primary/10 text-primary flex items-center justify-center font-bold text-sm border border-primary/20 shrink-0">
                          {selectedCustomer.fullName.charAt(0).toUpperCase()}
                        </div>
                        <div className="flex flex-col min-w-0">
                          <div className="flex flex-wrap items-center gap-1.5">
                            <strong className="text-foreground text-sm truncate">{selectedCustomer.fullName}</strong>
                            <Badge variant="secondary" className="text-[10px] font-medium px-1.5 py-0">{selectedCustomer.group?.name || 'Khách lẻ'}</Badge>
                          </div>
                          <div className="text-xs text-muted-foreground mt-0.5 flex items-center gap-1">
                            <Phone size={10} />
                            {selectedCustomer.phone}
                          </div>
                        </div>
                      </div>
                      <Button variant="ghost" size="sm" onClick={() => {setCustomerId(''); setSearchCustomer('');}} className="h-7 w-7 p-0 shrink-0 text-muted-foreground hover:text-destructive hover:bg-destructive/10 rounded-full focus-visible:ring-0">
                        <X size={14} />
                      </Button>
                    </div>
                  )}
                </CardContent>
              </Card>

              {/* Product Search Card */}
              <Card className="glass border-muted/50 shadow-sm flex-1 flex flex-col min-h-[300px] overflow-hidden">
                <CardHeader className="bg-muted/30 border-b py-3 px-4">
                  <CardTitle className="text-sm font-semibold flex items-center gap-2">
                    <PackageOpen size={16} className="text-primary" />
                    2. Tìm Sản phẩm
                  </CardTitle>
                </CardHeader>
                <CardContent className="p-4 flex-1 flex flex-col overflow-hidden">
                  <div className="relative mb-3">
                    <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground" />
                    <Input 
                      placeholder="Nhấn chuỗi SKU hoặc tên..." 
                      className="h-10 border-input shadow-sm pl-9"
                      value={searchProduct}
                      onChange={e => setSearchProduct(e.target.value)}
                    />
                  </div>
                  
                  <div className="flex flex-col gap-1.5 overflow-y-auto pr-1 flex-1 content-start">
                    {filteredProducts.map(p => (
                      <div 
                        key={p.id} 
                        className="border border-muted/50 bg-background p-2.5 px-3 rounded-lg flex items-center justify-between hover:border-primary/40 hover:bg-primary/5 cursor-pointer transition-all group" 
                        onClick={() => addToCart(p)}
                      >
                        <div className="flex flex-col min-w-0 pr-3 flex-1">
                          <div className="text-sm font-medium truncate group-hover:text-primary transition-colors" title={p.name}>{p.name}</div>
                          <div className="text-xs text-muted-foreground mt-0.5 truncate">{p.sku}</div>
                        </div>
                        <div className="flex items-center gap-2.5 shrink-0">
                          <span className="text-[13px] font-bold text-foreground">{formatMoney(p.retailPrice)}</span>
                          <div className="bg-muted/50 group-hover:bg-primary group-hover:text-primary-foreground text-muted-foreground rounded-full p-1.5 transition-all">
                            <Plus size={14} />
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                </CardContent>
              </Card>
            </div>

            {/* RIGHT: Cart Table */}
            <Card className="w-full lg:w-2/3 glass border-muted/50 shadow-sm flex flex-col overflow-hidden h-full max-h-[calc(100vh-230px)]">
              <CardHeader className="bg-muted/30 border-b py-3 px-5 flex flex-row items-center justify-between space-y-0 shrink-0">
                <CardTitle className="text-sm font-semibold flex items-center gap-2">
                  <ShoppingCart size={16} className="text-primary" />
                  Giỏ hàng đang sửa
                </CardTitle>
                <Badge variant="outline" className="bg-background font-semibold">
                  {cart.length} mục
                </Badge>
              </CardHeader>

              <div className="flex-1 overflow-auto relative">
                {cart.length === 0 ? (
                  <div className="h-full flex flex-col items-center justify-center text-muted-foreground/40 py-20">
                     <ShoppingCart size={48} className="mb-4" />
                     <p className="font-medium">Chưa có sản phẩm nào</p>
                     <p className="text-sm mt-1">Tìm và thêm sản phẩm từ panel bên trái</p>
                  </div>
                ) : (
                  <table className="w-full text-sm">
                    <thead className="bg-muted/40 sticky top-0 z-20 shadow-sm">
                      <tr>
                        <th className="text-left font-semibold p-3 px-5 border-b text-muted-foreground">STT</th>
                        <th className="text-left font-semibold p-3 border-b text-muted-foreground">Sản phẩm</th>
                        <th className="text-center font-semibold p-3 border-b text-muted-foreground w-[60px]">ĐVT</th>
                        <th className="text-right font-semibold p-3 border-b text-muted-foreground">Đơn giá</th>
                        <th className="text-center font-semibold p-3 border-b text-muted-foreground w-[120px]">Số lượng</th>
                        <th className="text-center font-semibold p-3 border-b text-muted-foreground w-[120px]">Chiết khấu</th>
                        <th className="text-right font-semibold p-3 border-b text-muted-foreground">Thành tiền</th>
                        <th className="text-center font-semibold p-3 px-5 border-b text-muted-foreground w-[50px]"></th>
                      </tr>
                    </thead>
                    <tbody>
                      {cart.map((c, idx) => (
                        <tr key={c.product.id} className="border-b border-muted/30 last:border-0 hover:bg-muted/20 transition-colors">
                          <td className="p-3 px-5 text-muted-foreground text-center">{idx + 1}</td>
                          <td className="p-3">
                            <div className="font-medium line-clamp-2 text-foreground">{c.product.name}</div>
                            <div className="text-xs text-muted-foreground">{c.product.sku}</div>
                          </td>
                          <td className="p-3 text-center text-muted-foreground text-xs">{c.product.unit}</td>
                          <td className="p-3 text-right text-muted-foreground">{formatMoney(c.product.retailPrice)}</td>
                          <td className="p-3">
                            <div className="flex items-center justify-center gap-0.5 border rounded-lg p-0.5 max-w-[110px] mx-auto bg-background shadow-sm">
                              <Button variant="ghost" size="icon" className="h-7 w-7 rounded-md font-bold text-lg text-muted-foreground hover:text-foreground" onClick={() => updateQuantity(c.product.id, parseQty(c.quantity) - 1)}>-</Button>
                              <Input 
                                type="text" 
                                className="h-7 w-10 text-center p-0 border-0 shadow-none focus-visible:ring-0 text-sm font-bold bg-transparent" 
                                value={c.quantity === 0 ? '' : c.quantity} 
                                onChange={e => {
                                  updateQuantity(c.product.id, e.target.value);
                                }}
                              />
                              <Button variant="ghost" size="icon" className="h-7 w-7 rounded-md font-bold text-lg text-primary" onClick={() => updateQuantity(c.product.id, parseQty(c.quantity) + 1)}>+</Button>
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
                                className="h-8 max-w-[100px] mx-auto text-right bg-background shadow-sm text-sm rounded-lg" 
                              />
                          </td>
                          <td className="p-3 text-right font-bold text-foreground">
                            {formatMoney(Math.max(0, (c.product.retailPrice * (Number(c.quantity) || 0)) - (c.discount || 0)))}
                          </td>
                          <td className="p-3 px-5 text-center">
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

              {/* Summary Footer */}
              <div className="border-t bg-muted/20 p-3 px-5 shrink-0 flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <span className="text-muted-foreground text-xs font-medium">Tạm tính:</span>
                  <span className="font-semibold text-foreground text-base">{formatMoney(tempSubtotal)}</span>
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
                      className="h-9 text-sm text-right pr-6 bg-background shadow-sm font-semibold border-input rounded-lg" 
                    />
                    <span className="absolute right-2.5 top-1/2 -translate-y-1/2 text-muted-foreground text-xs font-medium">đ</span>
                  </div>
                </div>

                <div className="flex items-baseline gap-2 bg-primary/5 p-2 px-4 rounded-xl border border-primary/20 shadow-sm">
                  <span className="font-bold text-foreground text-sm tracking-wide">Tổng cộng:</span>
                  <span className="font-extrabold text-xl text-primary tracking-tight">{formatMoney(tempTotal)}</span>
                </div>
              </div>
            </Card>

          </div>
        </div>
        
        {/* Sticky Bottom Bar */}
        <div className="px-6 py-4 border-t bg-background shrink-0 text-sm shadow-[0_-4px_16px_-4px_rgba(0,0,0,0.06)] z-10 w-full relative">
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
              <Button onClick={handleSubmit} disabled={isSubmitting || !customerId || cart.length === 0} className="min-w-[200px] shadow-lg h-10 w-full sm:w-auto font-semibold">
                {isSubmitting ? (
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                ) : (
                  <Check className="mr-2 h-4 w-4" />
                )}
                Lưu Thay Đổi (Cập nhật Kho)
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
