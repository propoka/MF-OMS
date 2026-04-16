# Tong Quan Du An MF-quanlydon

## 1. Muc tieu du an

`MF-quanlydon` la mot he thong quan ly don hang + CRM noi bo cho Mountain Farmers.
Du an tap trung vao 4 nghiep vu chinh:

- Quan ly khach hang
- Quan ly nhom khach hang va chinh sach gia
- Quan ly san pham, danh muc san pham
- Tao, cap nhat, theo doi va bao cao don hang

He thong duoc to chuc theo kieu monorepo, tach rieng:

- `apps/web`: giao dien Next.js
- `apps/api`: backend NestJS
- `packages/database`: Prisma schema, migration, seed, script DB

## 2. Cau truc thu muc chinh

```text
MF-quanlydon/
|-- apps/
|   |-- api/                 # Backend NestJS
|   \-- web/                 # Frontend Next.js App Router
|-- packages/
|   \-- database/            # Prisma schema, migration, seed
|-- nginx/                   # Reverse proxy production
|-- docker-compose.yml       # Local/dev stack
|-- docker-compose.prod.yml  # Production stack
|-- .env.example             # Mau bien moi truong
|-- database_backup.sql      # Ban dump du lieu Postgres
|-- tmp_kiranism/            # Thu muc tam / tham chieu, khong phai runtime chinh
|-- tmp_kiranism_2/          # Thu muc tam / tham chieu, khong phai runtime chinh
```

## 3. Cong nghe va cach to chuc

### 3.1 Root monorepo

- Package manager: `pnpm`
- Monorepo workspace: `pnpm-workspace.yaml`
- Task runner: `turbo`
- Node yeu cau: `>= 20`

Scripts root quan trong:

- `pnpm dev`: chay dev toan workspace
- `pnpm build`: build toan bo
- `pnpm db:generate`
- `pnpm db:migrate`
- `pnpm db:seed`
- `pnpm db:studio`

### 3.2 Frontend

- Framework: `Next.js 16`
- Router: App Router
- UI: custom components + `@base-ui/react`, `Radix`, `sonner`, `recharts`
- Auth tren client qua `AuthContext`
- Bao ve route bang `middleware.ts`

### 3.3 Backend

- Framework: `NestJS 11`
- Validation: `class-validator`, `class-transformer`
- Auth: JWT + Passport
- ORM: Prisma Client
- API docs: Swagger (`/docs` trong moi truong khong production)

### 3.4 Database

- Database: PostgreSQL
- ORM/schema: Prisma

## 4. Kien truc runtime

Luong chay chinh:

1. Nguoi dung truy cap giao dien web
2. Frontend dang nhap qua backend `/api/auth/login`
3. Access token duoc luu vao localStorage + cookie `mf_access_token`
4. Middleware cua Next.js kiem tra cookie JWT de chan route private
5. Frontend goi backend qua `NEXT_PUBLIC_API_URL/api/*`
6. Backend NestJS xac thuc JWT, check role, xu ly nghiep vu
7. Backend su dung Prisma de doc/ghi PostgreSQL

Production flow:

- Nginx nhan request tai domain `oms.xuanlockontum.com`
- `/` proxy vao web container
- `/api` proxy vao api container

## 5. Frontend: route va man hinh

Frontend nam trong `apps/web/app`.

### 5.1 Auth

- `/login`
  - Form dang nhap
  - Goi `authApi.login`
  - Redirect vao dashboard sau khi thanh cong

### 5.2 Layout dashboard

- `app/(dashboard)/layout.tsx`
  - Boc toan bo khu vuc da dang nhap
  - Su dung `AppLayout`
  - Co sidebar, header, floating button tao don

- `app/(dashboard)/page.tsx`
  - Hien tai redirect sang `/customers`

### 5.3 Dashboard va bao cao

- `/dashboard`
  - KPI tong quan
  - Bieu do doanh thu
  - Top san pham
  - Top khach hang

- `/reports`
  - Bao cao theo khoang ngay
  - Loc theo trang thai don
  - Export Excel
  - In/PDF

### 5.4 CRM

- `/customers`
  - Danh sach khach hang
  - Tim kiem
  - Phan trang
  - Tao moi khach hang

- `/customers/[id]`
  - Chi tiet khach hang
  - Lich su don hang
  - Sua/Xoa khach hang

- `/customer-groups`
  - Danh sach nhom khach hang
  - Tao/Sua/Xoa nhom

### 5.5 San pham

- `/products`
  - Danh sach san pham
  - Chinh gia le inline
  - Chinh gia theo nhom inline
  - Them/Sua/Xoa san pham

- `/products/categories`
  - Quan ly danh muc san pham
  - Moi danh muc co `name`, `code`
  - `code` dung de sinh SKU

### 5.6 Don hang

- `/orders`
  - Danh sach don hang
  - Tim kiem
  - Loc theo trang thai
  - Phan trang
  - Tao don moi
  - Xoa don

- `/orders/[id]`
  - Chi tiet don
  - Cap nhat trang thai
  - Huy don
  - In hoa don
  - Export Excel
  - Xem audit log

- `/orders/[id]/edit`
  - Sua don dang o trang thai cho phep
  - Rebuild gio hang
  - Preview pricing truoc khi luu

### 5.7 Cai dat

- `/settings`
  - Thong tin cong ty
  - Ly do huy/hoan
  - Quan ly user
  - Tab nang cao

## 6. Frontend: cac khoi code quan trong

### 6.1 Auth va route protection

- `lib/auth-context.tsx`
  - Quan ly user, access token, refresh token
  - Auto refresh access token bang refresh token
  - Dang xuat neu refresh fail hoac gap 401

- `middleware.ts`
  - Route public: `/login`
  - Route private: tat ca route con lai
  - Kiem tra JWT trong cookie `mf_access_token`

### 6.2 API client trung tam

- `lib/api.ts`
  - Chua toan bo client methods cho frontend
  - Gom nhom:
    - `authApi`
    - `usersApi`
    - `crmApi`
    - `productsApi`
    - `categoriesApi`
    - `ordersApi`
    - `dashboardApi`
    - `settingsApi`
    - `advancedApi`

### 6.3 Tao don / Sua don

- `components/orders/OrderCreateSheet.tsx`
  - Chon khach hang
  - Tim san pham
  - Them vao gio
  - Preview pricing
  - Tao don

- `app/(dashboard)/orders/[id]/edit/OrderEditClient.tsx`
  - Tai lai don can sua
  - Chinh sua item, so luong, discount, shipping
  - Preview pricing
  - Luu lai don

### 6.4 Import/export

- `reports/page.tsx`
  - Export Excel/PDF report

- `orders/[id]/page.tsx`
  - Export Excel tung don
  - In hoa don

- `settings/AdvancedTab.tsx`
  - Import Excel customers/products/orders
  - Download template import

## 7. Backend: modules va vai tro

Backend nam trong `apps/api/src`.

### 7.1 Entry point

- `main.ts`
  - Global prefix: `/api`
  - Enable CORS
  - Global validation pipe
  - Swagger `/docs`

- `app.module.ts`
  - Nap toan bo module
  - Dang ky global guard va interceptor

### 7.2 Auth

- `auth/`
  - `auth.controller.ts`
  - `auth.service.ts`
  - `jwt.strategy.ts`

Nghiep vu:

- Login
- Refresh token
- Logout
- `me`

JWT:

- Access token dung de goi API
- Refresh token luu hash trong DB (`User.refreshTokenHash`)

### 7.3 Users

- `users/`
  - Danh sach user
  - Tao user
  - Sua role
  - Xoa user

Role hien co:

- `ADMIN`
- `STAFF`

### 7.4 Customer groups

- `customer-groups/`
  - CRUD nhom khach hang
  - Ho tro nhom mac dinh
  - Co `priceType`, `discountPercent`, `isDefault`

### 7.5 Customers

- `customers/`
  - CRUD khach hang
  - Import customer
  - Tinh tong doanh so tu orders
  - Lich su don cua tung khach

- `customers/special-prices.controller.ts`
  - Gia dac biet theo tung khach + tung san pham

### 7.6 Products

- `products/`
  - CRUD san pham
  - Import product
  - Lay next SKU
  - Quan ly gia theo nhom

- `products/categories.*`
  - CRUD danh muc san pham
  - `migrateOldSkus()`

### 7.7 Orders

- `orders/`
  - Tao don
  - Sua don
  - Xoa don
  - Doi trang thai
  - Import don
  - Preview pricing

- `pricing.service.ts`
  - Pricing engine trung tam
  - Thu tu ap gia:
    1. `CustomerSpecialPrice`
    2. `ProductGroupPrice` hoac `discountPercent` cua group
    3. `retailPrice`

### 7.8 Dashboard

- `dashboard/`
  - KPI tong quan
  - Report theo khoang ngay
  - Top products / top customers

### 7.9 Settings

- `settings/`
  - Company settings
  - Cancel reasons
  - Advanced destructive actions

### 7.10 Address

- `common/address/`
  - Backend van co address module local
  - Co `provinces.json`
  - Co endpoint `/api/address/*`

Luu y:

- Hien tai frontend dang dung API dia chi ngoai, khong dung endpoint address backend.

## 8. Backend: toan bo endpoint API

Tat ca endpoint deu co prefix `/api`.

### 8.1 Auth

- `POST /auth/login`
- `POST /auth/refresh`
- `GET /auth/me`
- `POST /auth/logout`

### 8.2 Users

- `GET /users`
- `POST /users`
- `PATCH /users/:id/role`
- `DELETE /users/:id`

### 8.3 Customer groups

- `GET /customer-groups`
- `GET /customer-groups/:id`
- `POST /customer-groups`
- `PATCH /customer-groups/:id`
- `DELETE /customer-groups/:id`

### 8.4 Customers

- `GET /customers`
- `GET /customers/:id`
- `POST /customers`
- `POST /customers/import`
- `PATCH /customers/:id`
- `DELETE /customers/:id`

### 8.5 Customer special prices

- `GET /customers/:customerId/special-prices`
- `POST /customers/:customerId/special-prices`
- `DELETE /customers/:customerId/special-prices/:productId`

### 8.6 Products

- `GET /products`
- `GET /products/:id`
- `GET /products/next-sku/:categoryId`
- `POST /products`
- `POST /products/import`
- `PATCH /products/:id`
- `DELETE /products/:id`

### 8.7 Product categories

- `GET /product-categories`
- `GET /product-categories/:id`
- `POST /product-categories`
- `PATCH /product-categories/:id`
- `POST /product-categories/migrate-skus`
- `DELETE /product-categories/:id`

### 8.8 Orders

- `GET /orders`
- `GET /orders/:id`
- `POST /orders/preview-pricing`
- `POST /orders`
- `POST /orders/import`
- `PATCH /orders/:id`
- `PATCH /orders/:id/status`
- `DELETE /orders/:id`

### 8.9 Dashboard

- `GET /dashboard/kpis`
- `GET /dashboard/report`

### 8.10 Settings

- `GET /settings/company`
- `PATCH /settings/company`
- `GET /settings/cancel-reasons`
- `POST /settings/cancel-reasons`
- `PATCH /settings/cancel-reasons/:id`
- `DELETE /settings/cancel-reasons/:id`

### 8.11 Advanced

- `DELETE /settings/advanced/delete-all/products`
- `DELETE /settings/advanced/delete-all/customers`
- `DELETE /settings/advanced/delete-all/orders`
- `DELETE /settings/advanced/delete-all/customer-groups`
- `DELETE /settings/advanced/delete-all/product-categories`

### 8.12 Address

- `GET /address/provinces`
- `GET /address/provinces/:code/districts`

## 9. Bao mat, role, audit

### 9.1 Guard

- `JwtAuthGuard`
  - Tat ca route mac dinh deu can auth
  - Dung `@Public()` de bypass

- `RolesGuard`
  - Check `@Roles(...)`

### 9.2 Roles

Hanh dong thuong bi gioi han cho `ADMIN`:

- Tao/xoa user
- Import mot so du lieu
- Xoa don/san pham/nhom
- Advanced actions

### 9.3 Audit log

- `AuditInterceptor`
  - Tu dong ghi log cho `POST`, `PUT`, `PATCH`, `DELETE`
  - Ghi `oldData`, `newData`, user, entity, action, IP

Audit duoc dung ro nhat trong:

- Don hang
- Khach hang
- San pham
- User
- Settings

## 10. Database: mo hinh du lieu hien tai

Schema nam trong `packages/database/prisma/schema.prisma`.

### 10.1 Enums

- `Role`
- `OrderDeliveryStatus`
- `PriceSource`
- `GroupPriceType`
- `AuditAction`

### 10.2 Models chinh

#### User

- Tai khoan he thong
- Co `refreshTokenHash`
- Quan he voi `Order`, `AuditLog`

#### CustomerGroup

- Nhom khach hang
- Co `priceType`
- Co `discountPercent`
- Co `isDefault`

#### Customer

- Ho so khach hang
- Da co `code` de lam ma khach hang
- Co dia chi cap `province` va `ward`
- Thuoc `CustomerGroup`

#### CustomerSpecialPrice

- Gia dac biet theo cap:
  - 1 customer
  - 1 product

#### ProductCategory

- Danh muc san pham moi
- Co `name`, `code`, `description`

#### Product

- San pham master data
- Thuoc `ProductCategory`
- Co `retailPrice`, `costPrice`, `unit`

#### ProductGroupPrice

- Gia theo nhom cho tung san pham
- Dung khi group co `priceType = FIXED`

#### Order

- Don hang tong
- Snapshot ten/sdt khach tai thoi diem tao don
- Chua:
  - `subtotal`
  - `discountAmount`
  - `shippingFee`
  - `totalAmount`
  - `deliveryStatus`
  - `cancelReasonId`

#### OrderItem

- Snapshot tung dong san pham
- Luu:
  - ten SP
  - SKU
  - don vi
  - unit price
  - nguon gia
  - pricing note
  - quantity
  - line discount
  - line total

#### CancelReason

- Danh muc ly do huy/hoan

#### AuditLog

- Nhat ky thao tac

#### CompanySettings

- Thong tin cong ty dung cho in an va report

## 11. Vong doi nghiep vu don hang

Trang thai hien tai trong backend:

- `PENDING`
- `PROCESSING`
- `SHIPPING`
- `COMPLETED`
- `RETURNED`
- `CANCELLED`

Luong chuyen trang thai duoc backend validate trong `OrdersService`.

Rule hien tai:

- `PENDING -> PROCESSING | CANCELLED`
- `PROCESSING -> SHIPPING | CANCELLED`
- `SHIPPING -> COMPLETED | RETURNED`
- `COMPLETED -> RETURNED`

Khi tao don:

1. Frontend gui `customerId`, `items`, `shippingFee`, `discount`
2. Backend goi pricing engine
3. Pricing engine tinh gia theo uu tien
4. Backend snapshot du lieu khach + san pham
5. Backend tao `Order` va `OrderItem`
6. Audit log ghi lai thao tac

## 12. Chinh sach gia

Pricing engine la mot diem trung tam cua du an.

Thu tu uu tien:

1. Gia dac biet cua khach (`CustomerSpecialPrice`)
2. Gia theo nhom:
   - `FIXED` qua `ProductGroupPrice`
   - `PERCENTAGE` qua `CustomerGroup.discountPercent`
3. Gia le mac dinh (`Product.retailPrice`)

Ngoai ra tung item con co:

- `manualDiscount`

Moi dong don sau khi tinh gia se luu snapshot hoan chinh de bao toan lich su.

## 13. Import/export va thao tac hang loat

### 13.1 Import

He thong co import Excel cho:

- Customers
- Products
- Orders

Vi tri:

- Frontend: `settings/AdvancedTab.tsx`
- Backend:
  - `POST /customers/import`
  - `POST /products/import`
  - `POST /orders/import`

### 13.2 Export

- Bao cao tong hop: Excel + Print/PDF
- Chi tiet don hang: Excel + Print

## 14. Cau hinh, moi truong, deploy

### 14.1 Bien moi truong

Mau trong `.env.example`:

- `DATABASE_URL`
- `JWT_ACCESS_SECRET`
- `JWT_REFRESH_SECRET`
- `JWT_ACCESS_EXPIRES_IN`
- `JWT_REFRESH_EXPIRES_IN`
- `API_PORT`
- `API_URL`
- `NEXT_PUBLIC_API_URL`

### 14.2 Docker local

`docker-compose.yml` chay:

- `postgres`
- `api`

### 14.3 Docker production

`docker-compose.prod.yml` chay:

- `web`
- `api`
- `postgres`

Nginx:

- SSL termination
- Proxy `/` -> web
- Proxy `/api` -> api

## 15. Script database

Nam trong `packages/database/`.

- `prisma/seed.ts`
- `clearDb.ts`
- `migrate_missing_prices.ts`

Luu y:

- `seed.ts` hien co dau hieu cu hon schema hien tai
- Script nay can duoc doi chieu lai truoc khi dung de seed moi truong moi

## 16. Hien trang va ghi chu ky thuat quan trong

### 16.1 Nang cap moi da co trong schema hien tai

Du an hien tai da co:

- `ProductCategory`
- `Product.categoryId`
- `Customer.code`

Day la phan nang cap moi ma da duoc dua vao schema va giao dien nghiep vu.

### 16.2 Address API

Frontend hien dang dung API ngoai:

- `https://provinces.open-api.vn`

Backend van con module dia chi local:

- `apps/api/src/common/address`

Dieu nay co nghia la hien tai he thong dang ton tai 2 huong xu ly dia chi:

- 1 huong local tren backend
- 1 huong external tren frontend

### 16.3 Lech giua schema va migration/backup

Can luu y manh:

- `schema.prisma` hien tai moi hon bo migration dang co
- `database_backup.sql` cung chua phan anh day du cac nang cap moi

Vi du:

- Migration cu van co `paymentStatus`, `paidAmount`, `payments`
- Schema hien tai da bo payment model
- Schema hien tai co `ProductCategory`, `Customer.code`
- Migration/back-up doc duoc hien khong the hien day du phan nay

Dieu nay cho thay:

- Hoac da co thay doi schema nhung chua tao migration moi
- Hoac DB that dang chay da duoc cap nhat bang cach khac ngoai bo migration hien tai

### 16.4 Thu muc tam

Thu muc:

- `tmp_kiranism`
- `tmp_kiranism_2`

co ve la workspace tam/tham chieu/thiet ke, khong phai phan runtime chinh cua he thong OMS/CRM.

Khi tiep tuc "buoc 2", nen uu tien:

- `apps/api`
- `apps/web`
- `packages/database`
- `docker-compose*`
- `nginx`

## 17. Tep va module nen uu tien khi vao buoc 2

Neu buoc 2 la tiep tuc nang cap/chuan hoa he thong, nen doc va thao tac tren cac diem sau truoc:

### 17.1 Frontend

- `apps/web/lib/api.ts`
- `apps/web/lib/auth-context.tsx`
- `apps/web/app/(dashboard)/orders/*`
- `apps/web/app/(dashboard)/products/*`
- `apps/web/app/(dashboard)/customers/*`
- `apps/web/app/(dashboard)/settings/*`

### 17.2 Backend

- `apps/api/src/app.module.ts`
- `apps/api/src/auth/*`
- `apps/api/src/orders/*`
- `apps/api/src/products/*`
- `apps/api/src/customers/*`
- `apps/api/src/settings/*`
- `apps/api/src/common/*`

### 17.3 Database

- `packages/database/prisma/schema.prisma`
- `packages/database/prisma/migrations/*`
- `packages/database/prisma/seed.ts`

## 18. De xuat pham vi cho "Buoc 2"

Sau khi co tai lieu tong quan nay, buoc 2 hop ly nhat thuong se la mot trong cac huong sau:

1. Chuan hoa schema, migration va seed cho dong bo
2. Gom nhat luong dia chi ve 1 huong duy nhat
3. Chuan hoa API contract frontend/backend
4. Tach business rules pricing, status, import thanh cac khoi ro rang hon
5. Viet tai lieu API/spec nghiep vu chinh thuc
6. Ra soat UI/UX va luong nghiep vu tren orders/customers/products

## 19. Ket luan ngan

Day la mot he thong OMS/CRM full-stack theo monorepo, trong do:

- Frontend Next.js quan ly toan bo giao dien nghiep vu
- Backend NestJS cung cap API, auth, pricing, audit
- PostgreSQL + Prisma la lop du lieu trung tam
- San pham, khach hang, nhom gia, don hang va bao cao la 5 truc nghiep vu cot loi

Tai lieu nay duoc tao de lam moc chuyen sang buoc 2.
