---
name: build-deploy
description: 配置构建工具 / 部署 / 环境管理时使用。覆盖 Vite / Turbopack / Webpack / Rspack / Vercel / Cloudflare Pages / Netlify / Docker。融合多环境配置 + CDN + Preview / Production 部署 + 回滚。
---

# 构建与部署（Build & Deploy）

参考来源：Vite / Turbopack / Webpack 官方、Vercel / Cloudflare 部署文档、Stripe / Linear 部署实践、12-Factor App。

## 适用场景

- 项目初始化（Vite / Next.js / Nuxt）
- 多环境配置（dev / staging / prod）
- 包优化（splitting / tree-shake）
- 静态资源 / CDN
- 部署平台（Vercel / Cloudflare / 自建）
- Docker 容器化
- CI/CD 流水线
- 灰度 / 回滚

## 核心原则

```text
1. 一次构建多环境
   构建产物相同
   配置通过环境变量注入

2. 环境变量分级
   - 公开（VITE_PUBLIC_*）：嵌入 bundle，不能放密钥
   - 服务端（DATABASE_URL）：仅 SSR 用，不进 bundle

3. CDN 静态资源
   缓存策略：immutable + 哈希文件名

4. CI/CD 必备
   PR 预览 + 主分支自动部署 + 回滚

5. 监控部署
   - 构建产物大小
   - 部署成功率
   - 灰度阶段指标

6. 回滚 < 5 分钟
   一键回滚或快照恢复

7. 安全 Header
   CSP / HSTS / X-Frame-Options
```

## 构建工具速查

| 工具 | 适合 | 速度 | 生态 |
|---|---|---|---|
| **Vite** | 应用主流 | 快 | 大 |
| **Turbopack** | Next.js 15+ | 极快（Rust） | 跟 Next |
| **Rspack** | Webpack 替代 | 极快（Rust） | webpack 兼容 |
| **Webpack 5** | 传统老项目 | 慢但稳 | 最大 |
| **Rollup** | 库打包 | 中 | 库专用 |
| **esbuild** | 极简 / 库 | 极快（Go）| 中 |
| **Bun** | 多用途 | 快 | 新兴 |
| **tsup** | TS 库 | 快 | 简洁 |

## Vite 配置

```typescript
// vite.config.ts
import { defineConfig, loadEnv } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';
import { visualizer } from 'rollup-plugin-visualizer';
import compression from 'vite-plugin-compression';

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '');
  
  return {
    plugins: [
      react(),
      compression({ algorithm: 'brotliCompress' }),
      mode === 'production' && visualizer({ filename: 'dist/stats.html' }),
    ].filter(Boolean),
    
    resolve: {
      alias: {
        '@': path.resolve(__dirname, './src'),
      },
    },
    
    server: {
      port: 3000,
      strictPort: true,
      proxy: {
        '/api': {
          target: env.VITE_API_URL,
          changeOrigin: true,
        },
      },
    },
    
    build: {
      target: 'es2022',
      sourcemap: mode === 'staging',           // 生产关闭
      cssCodeSplit: true,
      reportCompressedSize: false,             // 加速构建
      chunkSizeWarningLimit: 1000,
      rollupOptions: {
        output: {
          manualChunks: {
            // 拆分供应商
            'react-vendor': ['react', 'react-dom', 'react-router'],
            'ui-vendor': ['@radix-ui/react-dialog', '@radix-ui/react-tabs'],
            'data-vendor': ['@tanstack/react-query', 'axios'],
          },
          // 哈希文件名（缓存友好）
          entryFileNames: 'assets/[name]-[hash].js',
          chunkFileNames: 'assets/[name]-[hash].js',
          assetFileNames: 'assets/[name]-[hash].[ext]',
        },
      },
    },
    
    optimizeDeps: {
      include: ['react', 'react-dom'],
    },
  };
});
```

## Next.js 配置

```typescript
// next.config.ts
import type { NextConfig } from 'next';

const nextConfig: NextConfig = {
  reactStrictMode: true,
  
  // Turbopack（默认）或 Webpack
  experimental: {
    turbo: {
      rules: { '*.svg': { loaders: ['@svgr/webpack'], as: '*.js' } },
    },
  },
  
  // 图片优化
  images: {
    formats: ['image/avif', 'image/webp'],
    remotePatterns: [
      { protocol: 'https', hostname: 'cdn.example.com' },
    ],
  },
  
  // 安全 Header
  async headers() {
    return [
      {
        source: '/:path*',
        headers: [
          { key: 'Strict-Transport-Security', value: 'max-age=63072000; includeSubDomains' },
          { key: 'X-Content-Type-Options', value: 'nosniff' },
          { key: 'X-Frame-Options', value: 'DENY' },
          { key: 'Referrer-Policy', value: 'strict-origin-when-cross-origin' },
          { key: 'Content-Security-Policy', value: "default-src 'self'; ..." },
        ],
      },
    ];
  },
  
  // 重定向
  async redirects() {
    return [
      { source: '/old', destination: '/new', permanent: true },
    ];
  },
  
  // 输出（如需 Docker / 静态）
  output: 'standalone',  // 'standalone' | 'export' | undefined
};

export default nextConfig;
```

## 环境变量管理

```text
分级：
  .env                  共享（所有环境）
  .env.development      仅 dev
  .env.staging          staging
  .env.production       生产
  .env.local            本地（gitignore）

Vite 公开变量前缀：VITE_
Next.js 公开变量前缀：NEXT_PUBLIC_

服务端变量（不进 bundle）：
  DATABASE_URL
  STRIPE_SECRET_KEY
  
公开变量（进 bundle，安全可暴露）：
  VITE_API_URL
  NEXT_PUBLIC_GA_ID
```

```bash
# .env.production
VITE_API_URL=https://api.example.com
VITE_GA_ID=G-XXXXX
VITE_SENTRY_DSN=https://...

# 严格不放
# DATABASE_URL=...   ❌ 会泄露到前端
```

## 部署平台对比

### Vercel（Next.js 首选）

```text
特点：
  - Next.js 团队
  - 边缘网络（Edge Functions）
  - 自动 PR 预览
  - 即时回滚
  - 内置 Analytics

部署：
  - GitHub 连接，push 自动部署
  - 配置：vercel.json

适合：Next.js / 一切前端
```

### Cloudflare Pages

```text
特点：
  - Cloudflare 网络（全球 PoP）
  - Workers 集成
  - 免费额度大
  - 自定义域好用

部署：
  - GitHub 连接
  - 或 wrangler CLI
  - 配置：wrangler.toml
```

### Netlify

```text
特点：
  - 老牌
  - Forms / Identity 内置
  - Edge Functions

部署：netlify.toml
```

### 自建（Docker + Nginx）

```dockerfile
# Dockerfile
FROM node:20-alpine AS deps
WORKDIR /app
COPY package*.json pnpm-lock.yaml ./
RUN corepack enable && pnpm install --frozen-lockfile

FROM node:20-alpine AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
ARG VITE_API_URL
ENV VITE_API_URL=${VITE_API_URL}
RUN corepack enable && pnpm run build

FROM nginx:alpine AS runner
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

```nginx
# nginx.conf
server {
  listen 80;
  root /usr/share/nginx/html;
  index index.html;
  
  # 静态资源永久缓存（哈希文件名）
  location /assets/ {
    expires 1y;
    add_header Cache-Control "public, immutable";
    add_header Vary Accept-Encoding;
    
    # Brotli / Gzip
    gzip on;
    gzip_types text/css application/javascript application/json image/svg+xml;
  }
  
  # HTML 短缓存
  location / {
    try_files $uri $uri/ /index.html;
    expires 1h;
    add_header Cache-Control "public, must-revalidate";
  }
  
  # 安全 Header
  add_header Strict-Transport-Security "max-age=63072000; includeSubDomains" always;
  add_header X-Content-Type-Options "nosniff" always;
  add_header X-Frame-Options "DENY" always;
  add_header Referrer-Policy "strict-origin-when-cross-origin" always;
  add_header Content-Security-Policy "default-src 'self'; ..." always;
}
```

## CI/CD 流水线

```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    branches: [main, develop]
  pull_request:

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 20, cache: 'pnpm' }
      - uses: pnpm/action-setup@v3
      - run: pnpm install --frozen-lockfile
      - run: pnpm run lint
      - run: pnpm run typecheck
      - run: pnpm run test
      - run: pnpm run build
      - name: Bundle Size Check
        run: |
          MAX_SIZE=200000
          SIZE=$(stat -c%s dist/assets/*.js | sort -n | tail -1)
          if [ $SIZE -gt $MAX_SIZE ]; then
            echo "Bundle too large: $SIZE > $MAX_SIZE"
            exit 1
          fi
      - uses: actions/upload-artifact@v4
        with:
          name: dist
          path: dist/
  
  e2e:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
      - run: pnpm install
      - run: npx playwright install --with-deps
      - run: pnpm run build
      - run: pnpm run test:e2e
  
  lighthouse:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: treosh/lighthouse-ci-action@v11
        with:
          urls: |
            https://preview-${{ github.event.number }}.example.com
          uploadArtifacts: true
          temporaryPublicStorage: true
  
  deploy-preview:
    if: github.event_name == 'pull_request'
    needs: [test, e2e]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/download-artifact@v4
        with: { name: dist }
      - name: Deploy to Vercel Preview
        run: vercel --token=${{ secrets.VERCEL_TOKEN }}
  
  deploy-production:
    if: github.ref == 'refs/heads/main'
    needs: [test, e2e, lighthouse]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Deploy to Vercel Production
        run: vercel --prod --token=${{ secrets.VERCEL_TOKEN }}
      - name: Notify Slack
        run: curl -X POST ${{ secrets.SLACK_WEBHOOK }} ...
```

## Bundle 优化

```text
检查：
  □ Bundle Analyzer 看分布
  □ 单文件 < 200 KB（gzip）
  □ 总大小预算

优化：
  □ Code splitting（路由 / 组件）
  □ Tree shaking（命名导入）
  □ 动态导入（用时加载）
  □ 替换大库（moment → dayjs）
  □ 压缩（Terser / SWC）
  □ Brotli 压缩
  □ Polyfill 按需（targets）
```

```javascript
// browserslist
"browserslist": {
  "production": [
    "> 0.5%",
    "not dead",
    "not op_mini all"
  ],
  "development": [
    "last 1 chrome version",
    "last 1 firefox version"
  ]
}
```

## 灰度发布

```text
方案 A：Vercel/Cloudflare 流量分配
  - 主域：50% old + 50% new
  - 监控错误率 / Web Vitals
  - OK → 100%

方案 B：Feature Flag
  - LaunchDarkly / Unleash / Flagsmith
  - 按用户 / 租户开关
  - 灰度 5% → 50% → 100%

方案 C：A/B 测试
  - Optimizely / GrowthBook
  - 长期对比
```

## 回滚策略

```text
平台快照（推荐）：
  Vercel：一键回滚到任意 deployment
  Cloudflare：回滚 production 别名
  Netlify：deploy rollback

Git 回滚：
  revert commit + push → 触发部署

CDN 缓存：
  强制清缓存（特殊情况）

数据库：不回滚（前端不影响 DB）

回滚时间：< 5 min
```

## 监控

```text
□ 部署成功率
□ 部署时长
□ Bundle 大小趋势
□ 真实用户性能（RUM）
□ 错误率（Sentry）
□ Lighthouse 分数变化
□ 灰度阶段指标
```

## 安全

```text
□ Source Map 生产关闭或 hidden
□ 不暴露 .env / .git
□ CSP 配置
□ HSTS 强制 HTTPS
□ 依赖扫描（Snyk / Dependabot）
□ Subresource Integrity（CDN 资源）
□ 不在 bundle 放敏感
```

## 工作流程

```text
1. 选构建工具
   - 应用 → Vite / Next.js
   - 库 → Rollup / tsup

2. 配置环境变量
   - 分级
   - 注意公开 vs 私密

3. 优化构建
   - Code splitting
   - Tree shaking
   - 压缩

4. 选部署平台
   - 框架推荐
   - 团队需求

5. CI/CD 流水线
   - Test → Build → E2E → Lighthouse → Deploy
   - PR 预览 + 主分支生产

6. 监控
   - 部署 / 性能 / 错误

7. 灰度 / 回滚机制
```

## 配套模板

- `templates/build-deploy-checklist.md` — 构建配置 + CI/CD + 灰度 + 回滚 + 监控

## 质量自检

```text
□ 一次构建多环境
□ 环境变量分级（公开 vs 私密）
□ Bundle 分析 + 预算
□ Code splitting
□ Tree shaking
□ 压缩 + Brotli
□ Source Map 生产隐藏
□ CDN 静态资源
□ 安全 Header（CSP / HSTS）
□ CI/CD 必跑 lint/test/build
□ PR 预览
□ Lighthouse CI
□ Bundle 大小 CI 阻塞
□ 一键回滚 < 5min
□ 监控接入
```

## 常见坑

1. **环境变量泄露密钥**——前缀放错
2. **Source Map 生产暴露源码**——必须 hidden
3. **不分 chunk**——首屏 1MB
4. **不哈希文件名**——CDN 缓存清不掉
5. **CSP 配置错误**——线上挂
6. **CORS 配置错**——API 调不通
7. **代理不配置**——dev 环境不通
8. **构建产物 > 预算**——CI 不阻塞
9. **Lighthouse 退化无感**——CI 不集成
10. **回滚流程不清楚**——故障时慌
11. **没监控部署**——失败不知
12. **Docker 镜像太大**——> 1GB
13. **依赖未锁版本**——构建不可复现
14. **不用 lockfile**——团队各自构建
15. **生产暴露 dev 工具**——React DevTools / Vue DevTools

## 与其他 skill 的协作

```text
上游：
  performance-optimization → 构建优化策略

下游：
  devops-engineer 工作流 → CI/CD 流水线深入
  sre-ops 工作流 → 监控告警
  security-engineer → 安全 Header / CSP
```

## 相关参考

- 项目根 `references/frontend-tech-stack-guide.md` — 构建工具
