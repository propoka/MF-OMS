# Release Checklist

## 1. Build Gate
- [ ] `pnpm --filter @mf/api build` pass.
- [ ] `pnpm --filter @mf/web build` pass.
- [ ] `pnpm --filter @mf/web lint` pass hoac warnings da duoc chap nhan ro rang.
- [ ] QA suites pass: smoke, integration, regression, e2e flows.
- [ ] Migration va Prisma client da duoc generate tu schema moi nhat.

## 2. Docker Gate
- [ ] `docker-compose.yml` dung de local smoke voi `postgres` + `api`.
- [ ] `docker-compose.prod.yml` build duoc `web`, `api`, `postgres`.
- [ ] Image `api` khoi dong duoc va expose `3001`.
- [ ] Image `web` khoi dong duoc va expose `3000`.
- [ ] Bien moi truong bat buoc (`DATABASE_URL`, `JWT_*`, `NEXT_PUBLIC_API_URL`) da du.
- [ ] Xac minh `next build` khong phu thuoc network ben ngoai hoac da co cach fallback cho fonts.

## 3. Nginx Routing Gate
- [ ] `location /` proxy den `web:3000`.
- [ ] `location /api` proxy den `api:3001`.
- [ ] Header `Host`, `X-Forwarded-For`, `X-Forwarded-Proto` duoc pass qua.
- [ ] Redirect HTTP -> HTTPS hoat dong dung.
- [ ] SSL certificate va key ton tai dung path.

## 4. Auth / Security Gate
- [ ] JWT secrets khong dung gia tri mac dinh.
- [ ] Access token, refresh token, logout, token rotation da smoke test.
- [ ] Route private khong truy cap duoc khi khong co token.
- [ ] Role `ADMIN` / `STAFF` da duoc verify lai o release candidate.
- [ ] Khong mo route `advanced` cho `STAFF`.

## 5. Database / Migration Gate
- [ ] Backup database duoc tao truoc khi deploy.
- [ ] Da test `prisma migrate deploy` tren moi truong gan production.
- [ ] Da verify migration rollback plan hoac restore plan.
- [ ] Du lieu quan trong duoc doi chieu theo `docs/qa/data-verification-checklist.md`.

## 6. Seed / Backup Tools Gate
- [ ] `seed.ts` co the chay tren moi truong test/staging.
- [ ] Tinh nang restore SQL chi duoc bat cho dung moi truong admin/noi bo.
- [ ] File backup SQL can thiet ton tai dung vi tri neu UI expose nut restore.
- [ ] Neu restore tool can `docker exec` / `docker cp`, image runtime phai co Docker CLI hoac cong cu thay the.
- [ ] Neu khong dap ung dieu kien tren, phai an/disable tinh nang restore truoc release.

## 7. Rollback Plan
- [ ] Co ban backup DB truoc release.
- [ ] Co image/tag cu de rollback nhanh cho `web` va `api`.
- [ ] Co quy trinh rollback migration/data ro rang.
- [ ] Co checklist smoke sau rollback: login, customers, products, orders, settings.
- [ ] Co nguoi phu trach va kenh lien lac khi rollback.

## 8. Final Sign-off
- [ ] Khong con bug `Critical` / `High`.
- [ ] Bug `Medium` con lai da duoc triage va chap nhan.
- [ ] QA sign-off.
- [ ] Tech lead/owner sign-off.
- [ ] Co release note ngan gon cho thay doi chinh va rui ro con ton tai.
