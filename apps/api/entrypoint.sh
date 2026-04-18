#!/bin/sh
set -e

echo "[entrypoint] Running Prisma migrations..."
cd /app/packages/database

# Cực kỳ quan trọng: Luồng cấp cứu Database Restore.
# Khi Khôi phục SQL, bảng _prisma_migrations bị xoá. Prisma sẽ cố tạo lại toàn bộ bảng và bị sập.
# Lệnh dưới đây chặn đứng điều đó bằng cách báo cho Prisma biết "Schema gốc đã tồn tại".
pnpm exec prisma migrate resolve --applied 20260416185109_init_schema_sync || true

pnpm run prisma:migrate:deploy
cd /app/apps/api

echo "[entrypoint] Starting API server..."
exec node dist/main
