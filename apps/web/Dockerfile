# ---- Builder stage ----
FROM node:22-alpine AS builder
RUN apk add --no-cache openssl && npm install -g pnpm@9

ARG NEXT_PUBLIC_API_URL
ENV NEXT_PUBLIC_API_URL=${NEXT_PUBLIC_API_URL}

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

# ---- Production stage (standalone) ----
FROM node:22-alpine AS runner
RUN apk add --no-cache openssl

WORKDIR /app

# Thiết lập môi trường production
ENV NODE_ENV=production
ENV HOSTNAME="0.0.0.0"
ENV PORT=3000

# Copy standalone output (nhỏ hơn ~10 lần so với full node_modules)
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static

EXPOSE 3000

CMD ["node", "server.js"]
