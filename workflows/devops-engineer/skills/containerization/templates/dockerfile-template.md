---
name: dockerfile-template
description: 多阶段 Dockerfile + .dockerignore + Docker Compose 模板
---

# Dockerfile 模板

## 多阶段构建（Node.js 示例）

```dockerfile
# syntax=docker/dockerfile:1

# ─── Stage 1: Dependencies ───
FROM node:20-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN --mount=type=cache,target=/root/.npm \
    npm ci --only=production

# ─── Stage 2: Build ───
FROM node:20-alpine AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN --mount=type=cache,target=/root/.npm npm ci
COPY src/ src/
COPY tsconfig.json ./
RUN npm run build

# ─── Stage 3: Production ───
FROM gcr.io/distroless/nodejs20-debian12:nonroot
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
EXPOSE 3000
HEALTHCHECK --interval=10s --timeout=5s --retries=3 \
  CMD ["node", "-e", "fetch('http://localhost:3000/health')"]
USER nonroot
CMD ["dist/main.js"]
```

## .dockerignore

```text
.git
.github
node_modules
dist
*.md
.env*
.vscode
coverage
tests
docker-compose*.yml
```

## Docker Compose（本地开发）

```yaml
version: "3.9"
services:
  app:
    build:
      context: .
      target: production
    ports:
      - "${APP_PORT:-3000}:3000"
    env_file: .env
    depends_on:
      db:
        condition: service_healthy

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: ${DB_NAME:-app}
      POSTGRES_PASSWORD: ${DB_PASSWORD:-localdev}
    ports:
      - "${DB_PORT:-5432}:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready"]
      interval: 5s

volumes:
  pgdata:
```
