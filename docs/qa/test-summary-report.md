# Test Summary Report

## Thong Tin Chung
- Du an: `MF-quanlydon`
- Ngay bao cao: `2026-04-19`
- Pham vi: QA baseline, smoke, integration, regression, E2E toi thieu, quality gates, release/data checklist
- Nguon bao cao: ket qua chay truc tiep tren workspace hien tai

## Tong Quan Ket Qua
- Backend QA suite: `13/14` test pass, `1` test fail
- Backend unit test cu: `PASS`
- API lint: `FAIL`
- API build: `FAIL`
- Web lint: `FAIL`
- Web build: `FAIL`
- QA docs/checklists: `PASS`
- Backup SQL file: `PASS`

## Cac Lenh Da Chay
```bash
pnpm --filter @mf/api test:qa
pnpm --filter @mf/api exec jest --runInBand
pnpm --filter @mf/api exec eslint src --ext .ts
pnpm --filter @mf/api build
pnpm --filter @mf/web lint
pnpm --filter @mf/web build
```

## Ket Qua Theo Checklist

### 1. Smoke Suite
Trang thai: `PASS`

Da chay thanh cong:
- `auth`
- `customers`
- `products`
- `orders`
- `settings`

Tai san:
- [qa-smoke.e2e-spec.ts](/E:/Project/MF-quanlydon/apps/api/test/qa-smoke.e2e-spec.ts)

### 2. API Integration Test
Trang thai: `FAIL mot phan`

Ket qua:
- `pricing preview`: `PASS`
- `create order`: `PASS`
- `update status`: `PASS`
- `import customers/products/orders`: `PASS`
- `login/refresh rotation`: `FAIL`

Tai san:
- [qa-integration.e2e-spec.ts](/E:/Project/MF-quanlydon/apps/api/test/qa-integration.e2e-spec.ts)

### 3. Regression Test
Trang thai: `PASS`

Da chay va pass:
- `pricing priority`
- `order status transition`
- `permission ADMIN/STAFF`

Tai san:
- [qa-regression.e2e-spec.ts](/E:/Project/MF-quanlydon/apps/api/test/qa-regression.e2e-spec.ts)

### 4. E2E Toi Thieu
Trang thai: `PASS` o muc API flow

Da chay va pass:
- login -> tao khach -> tao don -> doi trang thai -> xem chi tiet
- admin import customer/product/order end-to-end

Tai san:
- [qa-flows.e2e-spec.ts](/E:/Project/MF-quanlydon/apps/api/test/qa-flows.e2e-spec.ts)

Ghi chu:
- Day la E2E o muc API/app flow, chua phai browser E2E cho Next.js UI

### 5. Data Verification Checklist
Trang thai: `PARTIAL`

Da co file checklist:
- [data-verification-checklist.md](/E:/Project/MF-quanlydon/docs/qa/data-verification-checklist.md)

Chua xac minh duoc toan bo bang DB live trong phien nay.

### 6. Release Checklist
Trang thai: `PARTIAL`

Da co file checklist:
- [release-checklist.md](/E:/Project/MF-quanlydon/docs/qa/release-checklist.md)

Da xac minh bang file/config:
- Nginx `/` proxy ve `web:3000`: `PASS`
- Nginx `/api` proxy ve `api:3001`: `PASS`
- Co Docker compose local/prod: `PASS`
- Co template import file: `PASS`
- Co backup SQL file: `PASS`

Ref:
- [oms.xuanlockontum.com.conf](/E:/Project/MF-quanlydon/nginx/oms.xuanlockontum.com.conf)
- [docker-compose.yml](/E:/Project/MF-quanlydon/docker-compose.yml)
- [docker-compose.prod.yml](/E:/Project/MF-quanlydon/docker-compose.prod.yml)

## Ket Qua Thuc Te Chi Tiet

### Backend QA Suite
Lenh:
```bash
pnpm --filter @mf/api test:qa
```

Ket qua:
- `4 suites`
- `13 passed`
- `1 failed`

Suite fail:
- `QA API Integration Suite`
- test fail: `integrates login and refresh token rotation`

### Backend Unit Test Cu
Lenh:
```bash
pnpm --filter @mf/api exec jest --runInBand
```

Ket qua:
- `1 suite passed`
- `1 test passed`

### API Lint
Lenh:
```bash
pnpm --filter @mf/api exec eslint src --ext .ts
```

Ket qua:
- `FAIL`
- `4 errors`
- `38 warnings`

Error chinh nam o:
- [advanced.service.ts](/E:/Project/MF-quanlydon/apps/api/src/settings/advanced.service.ts:72)

Noi dung loi:
- dung `require()` bi rule `@typescript-eslint/no-require-imports` chan
- nhieu warning format `prettier`

### API Build
Lenh:
```bash
pnpm --filter @mf/api build
```

Ket qua:
- `FAIL`
- loi `EPERM unlink` trong `apps/api/dist`

Ghi chu:
- co dau hieu la loi moi truong/file lock tren Windows
- chua du du kien de ket luan la loi source code

### Web Lint
Lenh:
```bash
pnpm --filter @mf/web lint
```

Ket qua:
- `FAIL`
- `1 error`
- `69 warnings`

Error chan chinh:
- [GreetingWidget.tsx](/E:/Project/MF-quanlydon/apps/web/components/layout/GreetingWidget.tsx:39)

Noi dung loi:
- `react-hooks/set-state-in-effect`
- goi `setGreeting()` dong bo trong `useEffect`

Ngoai ra con nhieu warning:
- unused imports/vars
- missing hook deps
- `<img>` thay vi `<Image />`

### Web Build
Lenh:
```bash
pnpm --filter @mf/web build
```

Ket qua:
- `FAIL`
- loi `EPERM unlink` trong `.next`

Ghi chu:
- hien tai nghi nghieng ve loi moi truong/file locking
- nhung gate build van dang khong pass

## Loi Hien Dang Co

### 1. Refresh Token Rotation Khong Rotate That
Muc do: `High`

Bieu hien:
- sau `login` roi `refresh` ngay, token moi co the giong token cu

Evidence:
- [qa-integration.e2e-spec.ts](/E:/Project/MF-quanlydon/apps/api/test/qa-integration.e2e-spec.ts:19)
- [auth.service.ts](/E:/Project/MF-quanlydon/apps/api/src/auth/auth.service.ts:105)

Nguyen nhan kha di:
- JWT duoc ky tu cung payload, cung secret, cung expiry, cung timestamp giay
- khong co `jti` hoac entropy rieng cho moi lan issue

Rui ro:
- rotation khong dat muc tieu bao mat nhu ky vong
- session refresh kho phan biet token cu/moi

### 2. API Lint Fail Do `require()` Trong Advanced Restore Service
Muc do: `Medium`

Evidence:
- [advanced.service.ts](/E:/Project/MF-quanlydon/apps/api/src/settings/advanced.service.ts:72)

Rui ro:
- khong qua quality gate
- CI de fail neu lint la bat buoc

### 3. Web Lint Fail O GreetingWidget
Muc do: `Medium`

Evidence:
- [GreetingWidget.tsx](/E:/Project/MF-quanlydon/apps/web/components/layout/GreetingWidget.tsx:39)

Rui ro:
- quality gate fail
- pattern khong dung chuan React lint hien tai

### 4. Web Codebase Co Nhieu Warning Chat Luong
Muc do: `Low/Medium`

Nhom loi:
- unused imports/vars
- missing deps trong hooks
- `<img>` thay vi `<Image />`

Rui ro:
- giam maintainability
- co the che lap warning quan trong hon

### 5. Build Backend/Frontend Chua Pass Trong Moi Truong Hien Tai
Muc do: `Blocked`

Evidence:
- `@mf/api build` fail voi `EPERM unlink dist`
- `@mf/web build` fail voi `EPERM unlink .next`

Danh gia:
- hien la blocker release gate
- nhieu kha nang la loi moi truong local/file locking, chua ket luan la bug source code

## Hien Trang Release
Neu danh gia nhu mot release candidate:
- `Khong nen sign-off release ngay`

Ly do:
- con 1 loi nghiep vu that o auth token rotation
- `web lint` fail
- `api lint` fail
- `web build` va `api build` chua pass trong moi truong chay hien tai

## File/Artifact Xac Minh Them
- [apps/web/public/oms_db_backup.sql](/E:/Project/MF-quanlydon/apps/web/public/oms_db_backup.sql)
- [apps/web/public/templates](/E:/Project/MF-quanlydon/apps/web/public/templates)

## Kien Nghi Buoc Tiep Theo
1. Sua loi refresh-token rotation bang cach them `jti` hoac nonce khi issue token.
2. Sua `advanced.service.ts` de bo `require()` va pass lint.
3. Sua `GreetingWidget.tsx` de bo `setState` dong bo trong `useEffect`.
4. Don dep warning lon o `web` de quality gate ro rang hon.
5. Dieu tra va xu ly file locking/permission cho `dist` va `.next`, sau do chay lai build.
6. Neu can QA day du hon, scaffold browser E2E cho `apps/web` bang Playwright.
