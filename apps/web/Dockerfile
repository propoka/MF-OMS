# ---- Builder stage ----
FROM node:22-alpine AS builder
RUN apk add --no-cache openssl && npm install -g pnpm@9

WORKDIR /app

# Copy root workspace files
COPY package.json pnpm-workspace.yaml pnpm-lock.yaml ./
COPY turbo.json ./

# Copy packages/database
COPY packages/database/package.json packages/database/
COPY packages/database/prisma packages/database/prisma/
COPY packages/database/tsconfig.json packages/database/
COPY packages/database/index.ts packages/database/

# Copy apps/web
COPY apps/web/package.json apps/web/
COPY apps/web/tsconfig.json apps/web/
COPY apps/web/next.config.ts apps/web/
COPY apps/web/postcss.config.mjs apps/web/
COPY apps/web/eslint.config.mjs apps/web/
COPY apps/web/pnpm-workspace.yaml apps/web/
COPY apps/web/app apps/web/app
COPY apps/web/components apps/web/components
COPY apps/web/hooks apps/web/hooks
COPY apps/web/lib apps/web/lib
COPY apps/web/public apps/web/public
COPY apps/web/middleware.ts apps/web/
COPY apps/web/components.json apps/web/

RUN pnpm install --frozen-lockfile

# Build Next.js app
RUN pnpm --filter @mf/web build

# ---- Production stage ----
FROM node:22-alpine AS runner
RUN apk add --no-cache openssl && npm install -g pnpm@9

WORKDIR /app

# Copy root workspace files
COPY package.json pnpm-workspace.yaml pnpm-lock.yaml ./
COPY turbo.json ./

# Copy packages/database (needed for workspace resolution)
COPY packages/database/package.json packages/database/
COPY packages/database/index.ts packages/database/

# Copy apps/web production files
COPY apps/web/package.json apps/web/
COPY apps/web/next.config.ts apps/web/
COPY apps/web/postcss.config.mjs apps/web/
COPY apps/web/eslint.config.mjs apps/web/
COPY apps/web/pnpm-workspace.yaml apps/web/
COPY apps/web/public apps/web/public
COPY apps/web/.next apps/web/.next
COPY apps/web/node_modules apps/web/node_modules
COPY --from=builder /app/node_modules node_modules
COPY --from=builder /app/packages/database/node_modules packages/database/node_modules

WORKDIR /app/apps/web

EXPOSE 3000

CMD ["pnpm", "start"]
