#!/bin/sh
set -e

echo "[entrypoint] Running Prisma migrations..."
cd /app/packages/database
pnpm run prisma:migrate:deploy
cd /app/apps/api

echo "[entrypoint] Starting API server..."
exec node dist/main
