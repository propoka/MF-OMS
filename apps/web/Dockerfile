# ---- Builder stage ----
FROM node:22-alpine AS builder
RUN apk add --no-cache openssl && npm install -g pnpm@9

WORKDIR /app

# Copy only apps/web files (standalone, no workspace)
COPY apps/web/package.json apps/web/pnpm-lock.yaml ./
COPY apps/web/next.config.ts ./
COPY apps/web/postcss.config.mjs ./
COPY apps/web/eslint.config.mjs ./
COPY apps/web/tsconfig.json ./
COPY apps/web/components.json ./
COPY apps/web/middleware.ts ./
COPY apps/web/app ./app
COPY apps/web/components ./components
COPY apps/web/hooks ./hooks
COPY apps/web/lib ./lib
COPY apps/web/public ./public

RUN pnpm install

# Build Next.js app
RUN pnpm build

# ---- Production stage ----
FROM node:22-alpine AS runner
RUN apk add --no-cache openssl && npm install -g pnpm@9

WORKDIR /app

# Copy production files
COPY apps/web/package.json apps/web/pnpm-lock.yaml ./
COPY apps/web/next.config.ts ./
COPY apps/web/postcss.config.mjs ./
COPY apps/web/eslint.config.mjs ./
COPY apps/web/tsconfig.json ./
COPY apps/web/components.json ./
COPY apps/web/middleware.ts ./
COPY apps/web/public ./public

# Copy built artifacts and node_modules from builder
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules

EXPOSE 3000

CMD ["pnpm", "start"]
