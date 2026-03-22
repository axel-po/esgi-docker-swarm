ARG SERVICE=api

# --- Build ---
FROM node:20-alpine AS builder
RUN corepack enable && corepack prepare pnpm@9.11.0 --activate
RUN npm install -g turbo
WORKDIR /app
COPY . .
RUN pnpm install --frozen-lockfile
ARG SERVICE
RUN pnpm run build --filter=@nebula/${SERVICE}

# --- Production ---
FROM node:20-alpine
WORKDIR /app
ARG SERVICE
ENV SERVICE=${SERVICE}
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/packages ./packages
COPY --from=builder /app/apps/${SERVICE} ./apps/${SERVICE}
COPY --from=builder /app/package.json ./
USER node
CMD ["sh", "-c", "if [ \"$SERVICE\" = \"web\" ]; then node apps/web/.next/standalone/apps/web/server.js; else node apps/$SERVICE/dist/main; fi"]
