import * as bcrypt from 'bcryptjs';

type AnyRecord = Record<string, any>;

function clone<T>(value: T): T {
  return structuredClone(value);
}

function normalizeScalar(value: any) {
  if (value && typeof value === 'object' && typeof value.toNumber === 'function') {
    return value.toNumber();
  }
  return value;
}

function normalizeData<T>(value: T): T {
  if (Array.isArray(value)) {
    return value.map((item) => normalizeData(item)) as T;
  }

  if (value && typeof value === 'object') {
    const normalized: AnyRecord = {};
    for (const [key, nested] of Object.entries(value as AnyRecord)) {
      normalized[key] = normalizeData(normalizeScalar(nested));
    }
    return normalized as T;
  }

  return normalizeScalar(value);
}

function sortRecords<T extends AnyRecord>(records: T[], orderBy?: AnyRecord) {
  if (!orderBy) {
    return [...records];
  }

  const [[field, direction]] = Object.entries(orderBy);
  const dir = direction === 'desc' ? -1 : 1;

  return [...records].sort((left, right) => {
    if (left[field] < right[field]) return -1 * dir;
    if (left[field] > right[field]) return 1 * dir;
    return 0;
  });
}

function matchesWhere(record: AnyRecord, where?: AnyRecord): boolean {
  if (!where || Object.keys(where).length === 0) {
    return true;
  }

  if (Array.isArray(where.OR)) {
    return where.OR.some((condition: AnyRecord) => matchesWhere(record, condition));
  }

  return Object.entries(where).every(([field, condition]) => {
    if (field === 'OR') {
      return true;
    }

    const value = record[field];

    if (condition && typeof condition === 'object' && !Array.isArray(condition)) {
      if ('contains' in condition) {
        const haystack = String(value ?? '');
        const needle = String(condition.contains ?? '');
        if (condition.mode === 'insensitive') {
          return haystack.toLowerCase().includes(needle.toLowerCase());
        }
        return haystack.includes(needle);
      }

      if ('startsWith' in condition) {
        return String(value ?? '').startsWith(String(condition.startsWith ?? ''));
      }

      if ('in' in condition) {
        return Array.isArray(condition.in) && condition.in.includes(value);
      }

      if ('notIn' in condition) {
        return Array.isArray(condition.notIn) && !condition.notIn.includes(value);
      }

      if ('gte' in condition || 'lte' in condition || 'lt' in condition) {
        const comparableValue =
          value instanceof Date ? value.getTime() : Number(value);
        const gteValue =
          condition.gte instanceof Date ? condition.gte.getTime() : Number(condition.gte);
        const lteValue =
          condition.lte instanceof Date ? condition.lte.getTime() : Number(condition.lte);
        const ltValue =
          condition.lt instanceof Date ? condition.lt.getTime() : Number(condition.lt);

        if (condition.gte !== undefined && comparableValue < gteValue) {
          return false;
        }

        if (condition.lte !== undefined && comparableValue > lteValue) {
          return false;
        }

        if (condition.lt !== undefined && comparableValue >= ltValue) {
          return false;
        }

        return true;
      }
    }

    return value === condition;
  });
}

export class InMemoryPrismaService {
  private sequence = 100;

  private users: AnyRecord[] = [];

  private customerGroups: AnyRecord[] = [];

  private customers: AnyRecord[] = [];

  private customerSpecialPrices: AnyRecord[] = [];

  private productCategories: AnyRecord[] = [];

  private products: AnyRecord[] = [];

  private productGroupPrices: AnyRecord[] = [];

  private orders: AnyRecord[] = [];

  private orderItems: AnyRecord[] = [];

  private cancelReasons: AnyRecord[] = [];

  private auditLogs: AnyRecord[] = [];

  private companySettingsRows: AnyRecord[] = [];

  static async create() {
    const prisma = new InMemoryPrismaService();
    await prisma.seed();
    return prisma;
  }

  private nextId(prefix: string) {
    this.sequence += 1;
    return `${prefix}_${this.sequence}`;
  }

  private findGroupById(id: string) {
    return this.customerGroups.find((group) => group.id === id) || null;
  }

  private findCategoryById(id: string) {
    return this.productCategories.find((category) => category.id === id) || null;
  }

  private decorateUser(user: AnyRecord, args?: AnyRecord) {
    if (!user) {
      return null;
    }

    if (args?.select) {
      const selected: AnyRecord = {};
      for (const [key, enabled] of Object.entries(args.select)) {
        if (enabled) {
          selected[key] = user[key];
        }
      }
      return clone(selected);
    }

    return clone(user);
  }

  private decorateCustomer(customer: AnyRecord, args?: AnyRecord) {
    if (!customer) {
      return null;
    }

    const result = clone(customer);

    if (args?.include?.group) {
      const group = this.findGroupById(customer.groupId);
      if (args.include.group.select) {
        const selected: AnyRecord = {};
        for (const [key, enabled] of Object.entries(args.include.group.select)) {
          if (enabled && group) {
            selected[key] = group[key];
          }
        }
        result.group = selected;
      } else {
        result.group = clone(group);
      }
    }

    if (args?.include?.specialPrices) {
      const where = args.include.specialPrices.where;
      const prices = this.customerSpecialPrices
        .filter((item) => item.customerId === customer.id)
        .filter((item) => {
          if (!where?.productId?.in) {
            return true;
          }
          return where.productId.in.includes(item.productId);
        });
      result.specialPrices = clone(prices);
    }

    if (args?.include?.orders) {
      const config = args.include.orders;
      const orders = this.orders
        .filter((order) => order.customerId === customer.id)
        .filter((order) => matchesWhere(order, config.where))
        .map((order) => {
          if (!config.select) {
            return clone(order);
          }

          const selected: AnyRecord = {};
          for (const [key, enabled] of Object.entries(config.select)) {
            if (enabled) {
              selected[key] = order[key];
            }
          }
          return selected;
        });

      result.orders = config.orderBy ? sortRecords(orders, config.orderBy) : orders;
    }

    if (args?.include?._count?.select?.orders) {
      result._count = {
        orders: this.orders.filter((order) => order.customerId === customer.id).length,
      };
    }

    return result;
  }

  private decorateProduct(product: AnyRecord, args?: AnyRecord) {
    if (!product) {
      return null;
    }

    if (args?.select) {
      const selected: AnyRecord = {};
      for (const [key, enabled] of Object.entries(args.select)) {
        if (enabled) {
          selected[key] = product[key];
        }
      }
      return clone(selected);
    }

    const result = clone(product);

    if (args?.include?.category) {
      const category = this.findCategoryById(product.categoryId);
      if (args.include.category.select) {
        const selected: AnyRecord = {};
        for (const [key, enabled] of Object.entries(args.include.category.select)) {
          if (enabled && category) {
            selected[key] = category[key];
          }
        }
        result.category = selected;
      } else {
        result.category = clone(category);
      }
    }

    if (args?.include?.groupPrices) {
      const config = args.include.groupPrices;
      const prices = this.productGroupPrices
        .filter((item) => item.productId === product.id)
        .filter((item) => matchesWhere(item, config.where))
        .map((item) => {
          const price = clone(item);
          if (config.include?.group?.select) {
            const group = this.findGroupById(item.groupId);
            const selected: AnyRecord = {};
            for (const [key, enabled] of Object.entries(config.include.group.select)) {
              if (enabled && group) {
                selected[key] = group[key];
              }
            }
            price.group = selected;
          }
          return price;
        });
      result.groupPrices = prices;
    }

    if (args?.include?._count?.select?.orderItems) {
      result._count = {
        orderItems: this.orderItems.filter((item) => item.productId === product.id).length,
      };
    }

    return result;
  }

  private decorateOrder(order: AnyRecord, args?: AnyRecord) {
    if (!order) {
      return null;
    }

    const result = clone(order);

    if (args?.include?.items) {
      result.items = clone(this.orderItems.filter((item) => item.orderId === order.id));
    }

    if (args?.include?.createdBy) {
      const user = this.users.find((candidate) => candidate.id === order.createdById) || null;
      if (args.include.createdBy.select) {
        const selected: AnyRecord = {};
        for (const [key, enabled] of Object.entries(args.include.createdBy.select)) {
          if (enabled && user) {
            selected[key] = user[key];
          }
        }
        result.createdBy = selected;
      } else {
        result.createdBy = clone(user);
      }
    }

    if (args?.include?.customer) {
      const customer = this.customers.find((candidate) => candidate.id === order.customerId) || null;
      if (args.include.customer.include?.group) {
        result.customer = this.decorateCustomer(customer, {
          include: {
            group: args.include.customer.include.group,
          },
        });
      } else {
        result.customer = clone(customer);
      }
    }

    if (args?.include?.cancelReason) {
      result.cancelReason =
        this.cancelReasons.find((candidate) => candidate.id === order.cancelReasonId) || null;
    }

    return result;
  }

  private async seed() {
    const now = new Date();
    const adminPasswordHash = await bcrypt.hash('Admin2026@', 10);
    const staffPasswordHash = await bcrypt.hash('Staff2026@', 10);

    const admin = {
      id: 'user_admin',
      email: 'admin@mf.local',
      passwordHash: adminPasswordHash,
      fullName: 'QA Admin',
      role: 'ADMIN',
      isActive: true,
      refreshTokenHash: null,
      createdAt: now,
      updatedAt: now,
    };

    const staff = {
      id: 'user_staff',
      email: 'staff@mf.local',
      passwordHash: staffPasswordHash,
      fullName: 'QA Staff',
      role: 'STAFF',
      isActive: true,
      refreshTokenHash: null,
      createdAt: new Date(now.getTime() + 1000),
      updatedAt: new Date(now.getTime() + 1000),
    };

    this.users.push(admin, staff);

    const retailGroup = {
      id: 'group_retail',
      name: 'Khách lẻ',
      description: 'Nhóm mặc định',
      priceType: 'PERCENTAGE',
      discountPercent: 0,
      isDefault: true,
      createdAt: now,
      updatedAt: now,
    };

    const wholesaleGroup = {
      id: 'group_wholesale',
      name: 'Sỉ cấp 1',
      description: 'Nhóm giá cố định',
      priceType: 'FIXED',
      discountPercent: 0,
      isDefault: false,
      createdAt: now,
      updatedAt: now,
    };

    const vipGroup = {
      id: 'group_vip',
      name: 'VIP',
      description: 'Nhóm chiết khấu phần trăm',
      priceType: 'PERCENTAGE',
      discountPercent: 10,
      isDefault: false,
      createdAt: now,
      updatedAt: now,
    };

    this.customerGroups.push(retailGroup, wholesaleGroup, vipGroup);

    const customerRetail = {
      id: 'customer_retail',
      code: 'KH000001',
      phone: '0912345678',
      fullName: 'Khách Lẻ Mẫu',
      groupId: retailGroup.id,
      provinceCode: '62',
      provinceName: 'Kon Tum',
      wardCode: '1001',
      wardName: 'Thắng Lợi',
      addressDetail: '1 Trần Hưng Đạo',
      notes: 'Khách bán lẻ',
      isActive: true,
      createdAt: now,
      updatedAt: now,
    };

    const customerWholesale = {
      id: 'customer_wholesale',
      code: 'KH000002',
      phone: '0912345679',
      fullName: 'Khách Sỉ Mẫu',
      groupId: wholesaleGroup.id,
      provinceCode: '62',
      provinceName: 'Kon Tum',
      wardCode: '1002',
      wardName: 'Quyết Thắng',
      addressDetail: '2 Phan Đình Phùng',
      notes: 'Khách sỉ',
      isActive: true,
      createdAt: now,
      updatedAt: now,
    };

    const customerSpecial = {
      id: 'customer_special',
      code: 'KH000003',
      phone: '0912345680',
      fullName: 'Khách Giá Đặc Biệt',
      groupId: wholesaleGroup.id,
      provinceCode: '62',
      provinceName: 'Kon Tum',
      wardCode: '1003',
      wardName: 'Thống Nhất',
      addressDetail: '3 Nguyễn Huệ',
      notes: 'Có giá đặc biệt',
      isActive: true,
      createdAt: now,
      updatedAt: now,
    };

    this.customers.push(customerRetail, customerWholesale, customerSpecial);

    const category = {
      id: 'category_nsk',
      name: 'Nông sản khô',
      code: 'NSK',
      description: 'Hàng mẫu',
      isActive: true,
      createdAt: now,
      updatedAt: now,
    };

    this.productCategories.push(category);

    const products = [
      {
        id: 'product_retail',
        name: 'Mít sấy retail',
        sku: 'NSK01',
        categoryId: category.id,
        unit: 'Gói',
        retailPrice: 100000,
        costPrice: 70000,
        weight: 100,
        dimensions: '10x10x5',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      },
      {
        id: 'product_group',
        name: 'Chuối sấy group',
        sku: 'NSK02',
        categoryId: category.id,
        unit: 'Gói',
        retailPrice: 120000,
        costPrice: 80000,
        weight: 100,
        dimensions: '10x10x5',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      },
      {
        id: 'product_special',
        name: 'Xoài sấy special',
        sku: 'NSK03',
        categoryId: category.id,
        unit: 'Gói',
        retailPrice: 150000,
        costPrice: 95000,
        weight: 100,
        dimensions: '10x10x5',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      },
    ];

    this.products.push(...products);

    this.productGroupPrices.push(
      {
        id: 'pgp_1',
        productId: 'product_group',
        groupId: wholesaleGroup.id,
        fixedPrice: 90000,
        createdAt: now,
        updatedAt: now,
      },
      {
        id: 'pgp_2',
        productId: 'product_special',
        groupId: wholesaleGroup.id,
        fixedPrice: 110000,
        createdAt: now,
        updatedAt: now,
      },
    );

    this.customerSpecialPrices.push({
      id: 'csp_1',
      customerId: customerSpecial.id,
      productId: 'product_special',
      price: 70000,
      notes: 'Ưu đãi đại lý chiến lược',
      createdAt: now,
      updatedAt: now,
    });

    this.cancelReasons.push({
      id: 'cancel_reason_1',
      label: 'Sai số điện thoại',
      isActive: true,
      sortOrder: 1,
      createdAt: now,
    });

    this.companySettingsRows.push({
      id: 'company_1',
      name: 'Mountain Farmers QA',
      address: 'Kon Tum',
      phone: '02603888888',
      email: 'ops@mf.local',
      taxCode: '0102030405',
      logoUrl: null,
      bankInfo: 'VCB 123456',
      invoiceFooter: 'Cảm ơn quý khách',
      treatBlankAsZero: false,
      updatedAt: now,
    });
  }

  readonly $transaction = async (input: any) => {
    if (typeof input === 'function') {
      return input(this);
    }

    if (Array.isArray(input)) {
      return Promise.all(input);
    }

    return input;
  };

  readonly auditLog: AnyRecord = {};

  readonly user: AnyRecord = {};

  readonly customerGroup: AnyRecord = {};

  readonly customer: AnyRecord = {};

  readonly customerSpecialPrice: AnyRecord = {};

  readonly productCategory: AnyRecord = {};

  readonly productGroupPrice: AnyRecord = {};

  readonly product: AnyRecord = {};

  readonly companySettings: AnyRecord = {};

  readonly cancelReason: AnyRecord = {};

  readonly orderItem: AnyRecord = {};

  readonly order: AnyRecord = {};

  bind() {
    this.auditLog.create = async ({ data }: AnyRecord) => {
      const auditLog = {
        id: this.nextId('audit'),
        ...normalizeData(data),
        createdAt: new Date(),
      };
      this.auditLogs.push(auditLog);
      return clone(auditLog);
    };

    this.auditLog.findMany = async ({ where, include, orderBy }: AnyRecord = {}) => {
      return sortRecords(
        this.auditLogs
          .filter((auditLog) => matchesWhere(auditLog, where))
          .map((auditLog) => {
            const item = clone(auditLog);
            if (include?.user?.select) {
              const user = this.users.find((candidate) => candidate.id === auditLog.userId) || null;
              const selected: AnyRecord = {};
              for (const [key, enabled] of Object.entries(include.user.select)) {
                if (enabled && user) {
                  selected[key] = user[key];
                }
              }
              item.user = selected;
            }
            return item;
          }),
        orderBy,
      );
    };

    this.user.findUnique = async (args: AnyRecord) => {
      const user =
        this.users.find((item) => {
          if (args.where.id) return item.id === args.where.id;
          if (args.where.email) return item.email === args.where.email;
          return false;
        }) || null;
      return this.decorateUser(user, args);
    };

    this.user.findMany = async (args: AnyRecord = {}) => {
      const users = sortRecords(this.users, args.orderBy).map((user) =>
        this.decorateUser(user, args),
      );
      return clone(users);
    };

    this.user.update = async ({ where, data, select }: AnyRecord) => {
      const user = this.users.find((item) => item.id === where.id);
      if (!user) return null;
      Object.assign(user, normalizeData(data), { updatedAt: new Date() });
      return this.decorateUser(user, { select });
    };

    this.user.create = async ({ data, select }: AnyRecord) => {
      if (this.users.some((user) => user.email === data.email)) {
        throw { code: 'P2002' };
      }

      const user = {
        id: this.nextId('user'),
        isActive: true,
        refreshTokenHash: null,
        createdAt: new Date(),
        updatedAt: new Date(),
        ...normalizeData(data),
      };
      this.users.push(user);
      return this.decorateUser(user, { select });
    };

    this.user.delete = async ({ where }: AnyRecord) => {
      const index = this.users.findIndex((user) => user.id === where.id);
      if (index >= 0) {
        this.users.splice(index, 1);
      }
      return { id: where.id };
    };

    this.customerGroup.findFirst = async ({ where }: AnyRecord = {}) => {
      return (
        clone(this.customerGroups.find((group) => matchesWhere(group, where)) || null)
      );
    };

    this.customerGroup.findMany = async (args: AnyRecord = {}) => {
      return sortRecords(
        this.customerGroups.filter((group) => matchesWhere(group, args.where)).map((group) => {
          const item = clone(group);
          if (args.include?._count?.select?.customers) {
            item._count = {
              customers: this.customers.filter((customer) => customer.groupId === group.id).length,
            };
          }
          return item;
        }),
        args.orderBy,
      );
    };

    this.customerGroup.findUnique = async ({ where }: AnyRecord) => {
      const group =
        this.customerGroups.find((item) => {
          if (where.id) return item.id === where.id;
          if (where.name) return item.name === where.name;
          return false;
        }) || null;
      return clone(group);
    };

    this.customerGroup.create = async ({ data }: AnyRecord) => {
      if (this.customerGroups.some((group) => group.name === data.name)) {
        throw { code: 'P2002' };
      }

      const group = {
        id: this.nextId('group'),
        createdAt: new Date(),
        updatedAt: new Date(),
        ...normalizeData(data),
      };
      this.customerGroups.push(group);
      return clone(group);
    };

    this.customerGroup.update = async ({ where, data }: AnyRecord) => {
      const group = this.customerGroups.find((item) => item.id === where.id);
      if (!group) return null;
      Object.assign(group, normalizeData(data), { updatedAt: new Date() });
      return clone(group);
    };

    this.customerGroup.delete = async ({ where }: AnyRecord) => {
      this.customerGroups = this.customerGroups.filter((group) => group.id !== where.id);
      return { id: where.id };
    };

    this.customerGroup.deleteMany = async ({ where }: AnyRecord = {}) => {
      const before = this.customerGroups.length;
      this.customerGroups = this.customerGroups.filter((group) => !matchesWhere(group, where));
      return { count: before - this.customerGroups.length };
    };

    this.customer.count = async ({ where }: AnyRecord = {}) => {
      return this.customers.filter((customer) => matchesWhere(customer, where)).length;
    };

    this.customer.findMany = async (args: AnyRecord = {}) => {
      const customers = sortRecords(
        this.customers.filter((customer) => matchesWhere(customer, args.where)),
        args.orderBy,
      )
        .slice(args.skip || 0, (args.skip || 0) + (args.take ?? this.customers.length))
        .map((customer) => this.decorateCustomer(customer, args));

      return clone(customers);
    };

    this.customer.findUnique = async (args: AnyRecord) => {
      const { where } = args;
      const customer =
        this.customers.find((item) => {
          if (where.id) return item.id === where.id;
          if (where.phone) return item.phone === where.phone;
          if (where.code) return item.code === where.code;
          return false;
        }) || null;

      return this.decorateCustomer(customer, args);
    };

    this.customer.create = async ({ data }: AnyRecord) => {
      if (
        data.phone &&
        this.customers.some((customer) => customer.phone === data.phone)
      ) {
        throw { code: 'P2002' };
      }

      const customer = {
        id: this.nextId('customer'),
        createdAt: new Date(),
        updatedAt: new Date(),
        isActive: true,
        ...normalizeData(data),
      };
      this.customers.push(customer);
      return clone(customer);
    };

    this.customer.createMany = async ({ data, skipDuplicates }: AnyRecord) => {
      let count = 0;
      for (const item of data) {
        const duplicate = this.customers.some(
          (customer) =>
            (item.phone && customer.phone === item.phone) ||
            (item.code && customer.code === item.code),
        );

        if (duplicate && skipDuplicates) {
          continue;
        }

        const customer = {
          id: this.nextId('customer'),
          createdAt: new Date(),
          updatedAt: new Date(),
          code: item.code || this.nextId('code'),
          ...normalizeData(item),
        };
        this.customers.push(customer);
        count += 1;
      }
      return { count };
    };

    this.customer.update = async ({ where, data }: AnyRecord) => {
      const customer = this.customers.find((item) => item.id === where.id);
      if (!customer) return null;

      if (
        data.phone &&
        this.customers.some(
          (item) => item.id !== where.id && item.phone === data.phone,
        )
      ) {
        throw { code: 'P2002' };
      }

      Object.assign(customer, normalizeData(data), { updatedAt: new Date() });
      return clone(customer);
    };

    this.customer.delete = async ({ where }: AnyRecord) => {
      this.customers = this.customers.filter((customer) => customer.id !== where.id);
      return { id: where.id };
    };

    this.customerSpecialPrice.findMany = async ({ where, include }: AnyRecord) => {
      return this.customerSpecialPrices
        .filter((price) => matchesWhere(price, where))
        .map((price) => {
          const item = clone(price);
          if (include?.product?.select) {
            const product = this.products.find((candidate) => candidate.id === price.productId) || null;
            const selected: AnyRecord = {};
            for (const [key, enabled] of Object.entries(include.product.select)) {
              if (enabled && product) {
                selected[key] = product[key];
              }
            }
            item.product = selected;
          }
          return item;
        });
    };

    this.customerSpecialPrice.upsert = async ({ where, update, create }: AnyRecord) => {
      const existing = this.customerSpecialPrices.find(
        (price) =>
          price.customerId === where.customerId_productId.customerId &&
          price.productId === where.customerId_productId.productId,
      );

      if (existing) {
        Object.assign(existing, normalizeData(update), { updatedAt: new Date() });
        return clone(existing);
      }

      const price = {
        id: this.nextId('csp'),
        createdAt: new Date(),
        updatedAt: new Date(),
        ...normalizeData(create),
      };
      this.customerSpecialPrices.push(price);
      return clone(price);
    };

    this.customerSpecialPrice.delete = async ({ where }: AnyRecord) => {
      this.customerSpecialPrices = this.customerSpecialPrices.filter(
        (price) =>
          !(
            price.customerId === where.customerId_productId.customerId &&
            price.productId === where.customerId_productId.productId
          ),
      );
      return { ...where.customerId_productId };
    };

    this.customerSpecialPrice.deleteMany = async ({ where }: AnyRecord = {}) => {
      const before = this.customerSpecialPrices.length;
      this.customerSpecialPrices = this.customerSpecialPrices.filter(
        (price) => !matchesWhere(price, where),
      );
      return { count: before - this.customerSpecialPrices.length };
    };

    this.productCategory.findFirst = async ({ where }: AnyRecord = {}) => {
      return (
        clone(this.productCategories.find((category) => matchesWhere(category, where)) || null)
      );
    };

    this.productCategory.findMany = async (args: AnyRecord = {}) => {
      return sortRecords(
        this.productCategories
          .filter((category) => matchesWhere(category, args.where))
          .map((category) => {
            const item = clone(category);
            if (args.include?._count?.select?.products) {
              item._count = {
                products: this.products.filter((product) => product.categoryId === category.id).length,
              };
            }
            return item;
          }),
        args.orderBy,
      );
    };

    this.productCategory.findUnique = async ({ where }: AnyRecord) => {
      const category =
        this.productCategories.find((item) => {
          if (where.id) return item.id === where.id;
          if (where.code) return item.code === where.code;
          if (where.name) return item.name === where.name;
          return false;
        }) || null;
      return clone(category);
    };

    this.productCategory.create = async ({ data }: AnyRecord) => {
      if (
        this.productCategories.some(
          (category) => category.name === data.name || category.code === data.code,
        )
      ) {
        throw { code: 'P2002' };
      }

      const category = {
        id: this.nextId('category'),
        createdAt: new Date(),
        updatedAt: new Date(),
        isActive: true,
        ...normalizeData(data),
      };
      this.productCategories.push(category);
      return clone(category);
    };

    this.productCategory.update = async ({ where, data }: AnyRecord) => {
      const category = this.productCategories.find((item) => item.id === where.id);
      if (!category) return null;
      Object.assign(category, normalizeData(data), { updatedAt: new Date() });
      return clone(category);
    };

    this.productCategory.delete = async ({ where }: AnyRecord) => {
      this.productCategories = this.productCategories.filter(
        (category) => category.id !== where.id,
      );
      return { id: where.id };
    };

    this.productCategory.deleteMany = async ({ where }: AnyRecord = {}) => {
      const before = this.productCategories.length;
      this.productCategories = this.productCategories.filter(
        (category) => !matchesWhere(category, where),
      );
      return { count: before - this.productCategories.length };
    };

    this.productGroupPrice.deleteMany = async ({ where }: AnyRecord = {}) => {
      const before = this.productGroupPrices.length;
      this.productGroupPrices = this.productGroupPrices.filter(
        (price) => !matchesWhere(price, where),
      );
      return { count: before - this.productGroupPrices.length };
    };

    this.productGroupPrice.createMany = async ({ data }: AnyRecord) => {
      for (const item of data) {
        this.productGroupPrices.push({
          id: this.nextId('pgp'),
          createdAt: new Date(),
          updatedAt: new Date(),
          ...normalizeData(item),
        });
      }
      return { count: data.length };
    };

    this.product.count = async ({ where }: AnyRecord = {}) => {
      return this.products.filter((product) => matchesWhere(product, where)).length;
    };

    this.product.findMany = async (args: AnyRecord = {}) => {
      return sortRecords(
        this.products
          .filter((product) => matchesWhere(product, args.where))
          .slice(args.skip || 0, (args.skip || 0) + (args.take ?? this.products.length))
          .map((product) => this.decorateProduct(product, args)),
        args.orderBy,
      );
    };

    this.product.findUnique = async (args: AnyRecord) => {
      const { where } = args;
      const product =
        this.products.find((item) => {
          if (where.id) return item.id === where.id;
          if (where.sku) return item.sku === where.sku;
          return false;
        }) || null;
      return this.decorateProduct(product, args);
    };

    this.product.create = async ({ data, include }: AnyRecord) => {
      if (this.products.some((product) => product.sku === data.sku)) {
        throw { code: 'P2002' };
      }

      const { groupPrices, ...productData } = normalizeData(data);
      const product = {
        id: this.nextId('product'),
        createdAt: new Date(),
        updatedAt: new Date(),
        isActive: true,
        ...productData,
      };

      this.products.push(product);

      if (groupPrices?.create?.length) {
        for (const price of groupPrices.create) {
          this.productGroupPrices.push({
            id: this.nextId('pgp'),
            productId: product.id,
            createdAt: new Date(),
            updatedAt: new Date(),
            ...normalizeData(price),
          });
        }
      }

      return this.decorateProduct(product, { include });
    };

    this.product.update = async ({ where, data }: AnyRecord) => {
      const product = this.products.find((item) => item.id === where.id);
      if (!product) return null;

      if (
        data.sku &&
        this.products.some((item) => item.id !== where.id && item.sku === data.sku)
      ) {
        throw { code: 'P2002' };
      }

      Object.assign(product, normalizeData(data), { updatedAt: new Date() });
      return this.decorateProduct(product);
    };

    this.product.delete = async ({ where }: AnyRecord) => {
      this.products = this.products.filter((product) => product.id !== where.id);
      this.productGroupPrices = this.productGroupPrices.filter(
        (price) => price.productId !== where.id,
      );
      return { id: where.id };
    };

    this.companySettings.findFirst = async () => {
      return clone(this.companySettingsRows[0] || null);
    };

    this.companySettings.create = async ({ data }: AnyRecord) => {
      const settings = {
        id: this.nextId('company'),
        updatedAt: new Date(),
        ...normalizeData(data),
      };
      this.companySettingsRows = [settings];
      return clone(settings);
    };

    this.companySettings.update = async ({ where, data }: AnyRecord) => {
      const settings = this.companySettingsRows.find((item) => item.id === where.id);
      if (!settings) return null;
      Object.assign(settings, normalizeData(data), { updatedAt: new Date() });
      return clone(settings);
    };

    this.cancelReason.findMany = async ({ orderBy }: AnyRecord = {}) => {
      return sortRecords(this.cancelReasons, orderBy).map((reason) => clone(reason));
    };

    this.cancelReason.findUnique = async ({ where, include }: AnyRecord) => {
      const reason =
        this.cancelReasons.find((item) => {
          if (where.id) return item.id === where.id;
          if (where.label) return item.label === where.label;
          return false;
        }) || null;

      if (!reason) {
        return null;
      }

      const item = clone(reason);
      if (include?._count?.select?.orders) {
        item._count = {
          orders: this.orders.filter((order) => order.cancelReasonId === reason.id).length,
        };
      }
      return item;
    };

    this.cancelReason.create = async ({ data }: AnyRecord) => {
      if (this.cancelReasons.some((reason) => reason.label === data.label)) {
        throw { code: 'P2002' };
      }

      const reason = {
        id: this.nextId('cancel'),
        createdAt: new Date(),
        isActive: true,
        sortOrder: 0,
        ...normalizeData(data),
      };
      this.cancelReasons.push(reason);
      return clone(reason);
    };

    this.cancelReason.update = async ({ where, data }: AnyRecord) => {
      const reason = this.cancelReasons.find((item) => item.id === where.id);
      if (!reason) return null;
      Object.assign(reason, normalizeData(data));
      return clone(reason);
    };

    this.cancelReason.delete = async ({ where }: AnyRecord) => {
      this.cancelReasons = this.cancelReasons.filter((reason) => reason.id !== where.id);
      return { id: where.id };
    };

    this.orderItem.deleteMany = async ({ where }: AnyRecord = {}) => {
      const before = this.orderItems.length;
      this.orderItems = this.orderItems.filter((item) => !matchesWhere(item, where));
      return { count: before - this.orderItems.length };
    };

    this.orderItem.count = async ({ where }: AnyRecord = {}) => {
      return this.orderItems.filter((item) => matchesWhere(item, where)).length;
    };

    this.order.count = async ({ where }: AnyRecord = {}) => {
      return this.orders.filter((order) => matchesWhere(order, where)).length;
    };

    this.order.findMany = async (args: AnyRecord = {}) => {
      return sortRecords(
        this.orders
          .filter((order) => matchesWhere(order, args.where))
          .slice(args.skip || 0, (args.skip || 0) + (args.take ?? this.orders.length))
          .map((order) => this.decorateOrder(order, args)),
        args.orderBy,
      );
    };

    this.order.findUnique = async (args: AnyRecord) => {
      const order = this.orders.find((item) => item.id === args.where.id) || null;
      return this.decorateOrder(order, args);
    };

    this.order.create = async ({ data, include }: AnyRecord) => {
      const normalized = normalizeData(data);
      const order = {
        id: this.nextId('order'),
        createdAt: new Date(),
        updatedAt: new Date(),
        ...normalized,
      };

      delete order.items;
      this.orders.push(order);

      for (const item of normalized.items?.create || []) {
        this.orderItems.push({
          id: this.nextId('order_item'),
          orderId: order.id,
          ...normalizeData(item),
        });
      }

      return this.decorateOrder(order, { include });
    };

    this.order.update = async ({ where, data, include }: AnyRecord) => {
      const order = this.orders.find((item) => item.id === where.id);
      if (!order) return null;

      const normalized = normalizeData(data);
      const { items, ...rest } = normalized;
      Object.assign(order, rest, { updatedAt: new Date() });

      for (const item of items?.create || []) {
        this.orderItems.push({
          id: this.nextId('order_item'),
          orderId: order.id,
          ...normalizeData(item),
        });
      }

      return this.decorateOrder(order, { include });
    };

    this.order.delete = async ({ where }: AnyRecord) => {
      this.orders = this.orders.filter((order) => order.id !== where.id);
      this.orderItems = this.orderItems.filter((item) => item.orderId !== where.id);
      return { id: where.id };
    };
  }
}

export async function createInMemoryPrisma() {
  const prisma = await InMemoryPrismaService.create();
  prisma.bind();
  return prisma as unknown as InMemoryPrismaService & AnyRecord;
}
