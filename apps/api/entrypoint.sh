#!/bin/sh
set -e

echo "[entrypoint] Running Prisma migrations..."
cd /app/packages/database

# Thử chạy migrate bình thường trước (dành cho database trắng mới tinh)
if ! pnpm run prisma:migrate:deploy; then
    echo "[entrypoint] Phát hiện lỗi P3009 (Bảng đã tồn tại do Restore Data hoặc Database cũ). Tiến hành baseline schema cũ..."
    pnpm exec prisma migrate resolve --applied 20260416185109_init_schema_sync || true
    
    # Chạy lại migrate để cập nhật tiếp các bản vá nối tiếp (như indexes)
    pnpm run prisma:migrate:deploy
fi

echo "[entrypoint] Đồng bộ Schema cưỡng bức (để phòng ngừa trường hợp thiếu cột db do file SQL hoặc migrations thiếu bản cập nhật mới)"
pnpm exec prisma db push --accept-data-loss
cd /app/apps/api

echo "[entrypoint] Starting API server..."
exec node dist/main
