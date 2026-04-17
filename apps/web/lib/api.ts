const API_BASE = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001';

type RequestOptions = {
  method?: 'GET' | 'POST' | 'PUT' | 'PATCH' | 'DELETE';
  body?: unknown;
  token?: string;
};

export class ApiError extends Error {
  constructor(
    public status: number,
    message: string,
  ) {
    super(message);
  }
}

async function apiFetch<T>(
  path: string,
  options: RequestOptions = {},
): Promise<T> {
  const { method = 'GET', body, token } = options;

  const headers: HeadersInit = {
    'Content-Type': 'application/json',
  };

  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }

  const res = await fetch(`${API_BASE}/api${path}`, {
    method,
    headers,
    body: body ? JSON.stringify(body) : undefined,
  });

  const data = await res.json().catch(() => ({}));

  if (!res.ok) {
    if (res.status === 401 && typeof window !== 'undefined' && token) {
      window.dispatchEvent(new CustomEvent('mf_unauthorized'));
      // Prevent caller from throwing and triggering Next.js Error Overlay.
      // Hang the promise indefinitely while the app redirects to /login.
      return new Promise<T>(() => {});
    }

    const raw = data?.message;
    const message = Array.isArray(raw)
      ? raw.join(', ')
      : (raw || 'Đã xảy ra lỗi. Vui lòng thử lại.');
    throw new ApiError(res.status, message);
  }

  return data as T;
}

// ─── Auth API ────────────────────────────────────────────────────────────────

export const authApi = {
  login: (email: string, password: string) =>
    apiFetch<{ accessToken: string; refreshToken: string; user: User }>(
      '/auth/login',
      { method: 'POST', body: { email, password } },
    ),

  refresh: (refreshToken: string) =>
    apiFetch<{ accessToken: string; refreshToken: string }>('/auth/refresh', {
      method: 'POST',
      body: { refreshToken },
    }),

  me: (token: string) =>
    apiFetch<User>('/auth/me', { token }),

  logout: (token: string) =>
    apiFetch('/auth/logout', { method: 'POST', token }),
};

// ─── Users API ────────────────────────────────────────────────────────────────

export const usersApi = {
  getUsers: (token: string) =>
    apiFetch<User[]>('/users', { token }),

  createUser: (token: string, data: Partial<User> & { password?: string }) =>
    apiFetch<User>('/users', { method: 'POST', token, body: data }),

  updateUserRole: (token: string, id: string, role: string) =>
    apiFetch<User>(`/users/${id}/role`, { method: 'PATCH', token, body: { role } }),

  deleteUser: (token: string, id: string) =>
    apiFetch(`/users/${id}`, { method: 'DELETE', token }),
};

// ─── CRM API ─────────────────────────────────────────────────────────────────

export const crmApi = {
  getGroups: (token: string) =>
    apiFetch<CustomerGroup[]>(`/customer-groups?_t=${Date.now()}`, { token }),

  createGroup: (token: string, data: Partial<CustomerGroup>) =>
    apiFetch<CustomerGroup>('/customer-groups', { method: 'POST', token, body: data }),

  updateGroup: (token: string, id: string, data: Partial<CustomerGroup>) =>
    apiFetch<CustomerGroup>(`/customer-groups/${id}`, { method: 'PATCH', token, body: data }),

  deleteGroup: (token: string, id: string) =>
    apiFetch(`/customer-groups/${id}`, { method: 'DELETE', token }),

  getCustomers: (token: string, params?: { skip?: number; take?: number; search?: string; groupId?: string }) => {
    const searchParams = new URLSearchParams();
    if (params?.skip != null) searchParams.append('skip', String(params.skip));
    if (params?.take != null) searchParams.append('take', String(params.take));
    if (params?.search) searchParams.append('search', params.search);
    if (params?.groupId) searchParams.append('groupId', params.groupId);
    
    const qs = searchParams.toString();
    return apiFetch<{ total: number; data: Customer[] }>(`/customers${qs ? `?${qs}` : ''}`, { token });
  },

  getCustomer: (token: string, id: string) =>
    apiFetch<Customer>(`/customers/${id}`, { token }),

  updateCustomer: (token: string, id: string, data: Partial<Customer>) =>
    apiFetch<Customer>(`/customers/${id}`, { method: 'PATCH', token, body: data }),

  deleteCustomer: (token: string, id: string) =>
    apiFetch(`/customers/${id}`, { method: 'DELETE', token }),

  importCustomers: (token: string, customers: unknown[]) =>
    apiFetch<{ message: string, importedCount: number }>('/customers/import', { method: 'POST', token, body: customers }),
};

// ─── Address Proxy API ───────────────────────────────────────────────────────

export const addressApi = {
  getProvinces: () =>
    apiFetch<{ code: string; name: string }[]>('/address/provinces'),
  
  getDistricts: (code: string) =>
    apiFetch<{ code: string; name: string }[]>(`/address/provinces/${code}/districts`),
};

// ─── Products API ────────────────────────────────────────────────────────────

export const productsApi = {
  getProducts: (token: string, params?: { skip?: number; take?: number; search?: string }) => {
    const searchParams = new URLSearchParams();
    if (params?.skip != null) searchParams.append('skip', String(params.skip));
    if (params?.take != null) searchParams.append('take', String(params.take));
    if (params?.search) searchParams.append('search', params.search);
    
    const qs = searchParams.toString();
    return apiFetch<{ total: number; data: Product[] }>(`/products${qs ? `?${qs}` : ''}`, { token });
  },

  getProduct: (token: string, id: string) =>
    apiFetch<Product>(`/products/${id}`, { token }),

  createProduct: (token: string, data: Partial<Product>) =>
    apiFetch<Product>('/products', { method: 'POST', token, body: data }),

  updateProduct: (token: string, id: string, data: Partial<Product>) =>
    apiFetch<Product>(`/products/${id}`, { method: 'PATCH', token, body: data }),

  deleteProduct: (token: string, id: string) =>
    apiFetch(`/products/${id}`, { method: 'DELETE', token }),

  importProducts: (token: string, products: unknown[]) =>
    apiFetch<{ successCount: number, totalTried: number }>('/products/import', { method: 'POST', token, body: products }),

  getNextSku: (token: string, categoryId: string) =>
    apiFetch<{ sku: string }>(`/products/next-sku/${categoryId}`, { token }),
};

// ─── Product Categories API ──────────────────────────────────────────────────

export const categoriesApi = {
  getCategories: (token: string) =>
    apiFetch<ProductCategory[]>('/product-categories', { token }),

  createCategory: (token: string, data: Partial<ProductCategory>) =>
    apiFetch<ProductCategory>('/product-categories', { method: 'POST', token, body: data }),

  updateCategory: (token: string, id: string, data: Partial<ProductCategory>) =>
    apiFetch<ProductCategory>(`/product-categories/${id}`, { method: 'PATCH', token, body: data }),

  deleteCategory: (token: string, id: string) =>
    apiFetch(`/product-categories/${id}`, { method: 'DELETE', token }),

  migrateSkus: (token: string) =>
    apiFetch<{ totalMigrated: number }>('/product-categories/migrate-skus', { method: 'POST', token }),
};

// ─── Orders API ──────────────────────────────────────────────────────────────

export const ordersApi = {
  getOrders: (token: string, params?: { skip?: number; take?: number; search?: string; status?: string }) => {
    const searchParams = new URLSearchParams();
    if (params?.skip != null) searchParams.append('skip', String(params.skip));
    if (params?.take != null) searchParams.append('take', String(params.take));
    if (params?.search) searchParams.append('search', params.search);
    if (params?.status) searchParams.append('status', params.status);
    
    const qs = searchParams.toString();
    return apiFetch<{ total: number; data: Order[] }>(`/orders${qs ? `?${qs}` : ''}`, { token });
  },

  getOrder: (token: string, id: string) =>
    apiFetch<Order>(`/orders/${id}`, { token }),

  previewPricing: (token: string, data: { customerId: string; items: { productId: string; quantity: number; manualDiscount?: number }[] }) =>
    apiFetch<{
      customerSnapshot: { snapshotCustomerName: string; snapshotCustomerPhone: string };
      items: { productId: string; snapshotProductName: string; snapshotUnitPrice: number; priceSource: string; pricingNote: string; lineDiscount: number; lineTotal: number }[];
      subtotal: number;
    }>('/orders/preview-pricing', { method: 'POST', token, body: data }),

  createOrder: (token: string, data: { customerId: string; items: { productId: string; quantity: number, manualDiscount?: number }[]; discountAmount?: number; shippingFee?: number; notes?: string }) =>
    apiFetch<Order>('/orders', { method: 'POST', token, body: data }),

  updateOrder: (token: string, id: string, data: { customerId: string; items: { productId: string; quantity: number, manualDiscount?: number }[]; discountAmount?: number; shippingFee?: number; notes?: string }) =>
    apiFetch<Order>(`/orders/${id}`, { method: 'PATCH', token, body: data }),

  updateStatus: (token: string, id: string, data: { deliveryStatus?: string; cancelReasonId?: string; cancelNotes?: string }) =>
    apiFetch<Order>(`/orders/${id}/status`, { method: 'PATCH', token, body: data }),

  deleteOrder: (token: string, id: string) =>
    apiFetch(`/orders/${id}`, { method: 'DELETE', token }),

  importOrders: (token: string, orders: unknown[]) =>
    apiFetch<{ successCount: number, totalTried: number }>('/orders/import', { method: 'POST', token, body: orders }),
};

// ─── Dashboard API ───────────────────────────────────────────────────────────

export const dashboardApi = {
  getKpis: (token: string, days: number = 7) =>
    apiFetch<{
      revenue: { total: number; thisMonth: number; today: number; growthRate?: number };
      orders: { total: number; active: number; today: number };
      customers: { total: number; newThisMonth: number };
      debt: { total: number };
      revenueChart: { date: string; revenue: number; orders: number }[];
      topProducts: { name: string; sku: string; totalRevenue: number; totalSold: number }[];
      topCustomers: { name: string; phone: string; totalRevenue: number; totalOrders: number }[];
    }>(`/dashboard/kpis?days=${days}`, { token }),

  getReport: (token: string, startDate?: string, endDate?: string) => {
    const searchParams = new URLSearchParams();
    if (startDate) searchParams.append('startDate', startDate);
    if (endDate) searchParams.append('endDate', endDate);
    searchParams.append('_t', Date.now().toString());
    const qs = searchParams.toString();
    return apiFetch<{
      summary: { 
        totalOrders: number; 
        completedOrdersCount: number; 
        grossRevenue: number; 
        netRevenue: number; 
        totalShippingFee: number; 
        totalDiscount: number; 
        aov: number; 
        cancelRate: number; 
      };
      overview: {
        statusBreakdown: Record<string, { count: number; revenue: number }>;
        topCustomers: { name: string; phone: string; revenue: number; orderCount: number }[];
        topProducts: { name: string; sku: string; revenue: number; sold: number }[];
      };
      orders: Order[];
    }>(`/dashboard/report${qs ? `?${qs}` : ''}`, { token });
  },
};

// ─── Settings API ────────────────────────────────────────────────────────────

export const settingsApi = {
  getCompanySettings: (token: string) =>
    apiFetch<CompanySettings>('/settings/company', { token }),

  updateCompanySettings: (token: string, data: Partial<CompanySettings>) =>
    apiFetch<CompanySettings>('/settings/company', { method: 'PATCH', token, body: data }),

  getCancelReasons: (token: string) =>
    apiFetch<CancelReason[]>('/settings/cancel-reasons', { token }),

  createCancelReason: (token: string, data: Partial<CancelReason>) =>
    apiFetch<CancelReason>('/settings/cancel-reasons', { method: 'POST', token, body: data }),

  updateCancelReason: (token: string, id: string, data: Partial<CancelReason>) =>
    apiFetch<CancelReason>(`/settings/cancel-reasons/${id}`, { method: 'PATCH', token, body: data }),

  deleteCancelReason: (token: string, id: string) =>
    apiFetch(`/settings/cancel-reasons/${id}`, { method: 'DELETE', token }),
};

// ─── Advanced API ────────────────────────────────────────────────────────────

export const advancedApi = {
  deleteAllProducts: (token: string) =>
    apiFetch('/settings/advanced/delete-all/products', { method: 'DELETE', token }),
  deleteAllCustomers: (token: string) =>
    apiFetch('/settings/advanced/delete-all/customers', { method: 'DELETE', token }),
  deleteAllOrders: (token: string) =>
    apiFetch('/settings/advanced/delete-all/orders', { method: 'DELETE', token }),
  deleteAllCustomerGroups: (token: string) =>
    apiFetch('/settings/advanced/delete-all/customer-groups', { method: 'DELETE', token }),
  deleteAllProductCategories: (token: string) =>
    apiFetch('/settings/advanced/delete-all/product-categories', { method: 'DELETE', token }),
  seedLocalData: (token: string) =>
    apiFetch<{ message: string }>('/settings/advanced/seed-local', { method: 'POST', token }),
};

// ─── Types ───────────────────────────────────────────────────────────────────

export interface User {
  id: string;
  email: string;
  fullName: string;
  role: 'ADMIN' | 'STAFF';
}

export interface CustomerGroup {
  id: string;
  name: string;
  description?: string;
  priceType: 'PERCENTAGE' | 'FIXED';
  discountPercent?: number;
  isDefault: boolean;
  createdAt?: string;
  updatedAt?: string;
  _count?: { customers: number };
}

export interface ProductCategory {
  id: string;
  name: string;
  code: string;
  description?: string;
  isActive: boolean;
  _count?: { products: number };
}

export interface Customer {
  id: string;
  code?: string;
  phone?: string;
  fullName: string;
  groupId: string;
  provinceName?: string;
  wardName?: string;
  addressDetail?: string;
  isActive: boolean;
  totalRevenue?: number; // Computed field
  group?: { name: string; discountPercent: number; priceType: string };
  orders?: {
    id: string;
    orderNumber: string;
    deliveryStatus: string;
    subtotal: number;
    totalAmount: number;
    createdAt: string;
  }[];
}

export interface ProductGroupPrice {
  id?: string;
  groupId: string;
  fixedPrice: number;
  group?: { name: string };
}

export interface Product {
  id: string;
  name: string;
  sku: string;
  categoryId: string;
  category?: ProductCategory;
  unit: string;
  retailPrice: number;
  costPrice?: number | null;
  weight?: number | null;
  dimensions?: string | null;
  isActive: boolean;
  groupPrices?: ProductGroupPrice[];
}

export interface OrderItem {
  id: string;
  orderId: string;
  productId: string;
  snapshotProductName: string;
  snapshotProductSku: string;
  snapshotProductUnit: string;
  snapshotUnitPrice: number;
  priceSource: string;
  pricingNote?: string;
  quantity: number;
  lineDiscount: number;
  lineTotal: number;
}

export interface Order {
  id: string;
  orderNumber: string;
  customerId: string;
  snapshotCustomerName: string;
  snapshotCustomerPhone: string;
  deliveryStatus: string;
  subtotal: number;
  discountAmount: number;
  shippingFee: number;
  totalAmount: number;
  notes?: string;
  createdAt: string;
  items?: OrderItem[];
  customer?: any;
  createdBy?: { fullName: string };
  cancelReason?: CancelReason;
  auditLogs?: {
    id: string;
    action: string;
    oldData?: any;
    newData?: any;
    createdAt: string;
    user?: { fullName: string };
  }[];
}

export interface CompanySettings {
  id: string;
  name: string;
  address?: string;
  phone?: string;
  email?: string;
  taxCode?: string;
  logoUrl?: string;
  bankInfo?: string;
  invoiceFooter?: string;
  treatBlankAsZero?: boolean;
}

export interface CancelReason {
  id: string;
  label: string;
  isActive: boolean;
  sortOrder: number;
}

export { apiFetch };

