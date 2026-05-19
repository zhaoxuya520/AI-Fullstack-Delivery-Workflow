# 构建部署检查清单

## 1. 项目信息

```text
项目：
框架：React / Vue / Angular / Svelte / Next.js / Nuxt / SvelteKit
构建工具：Vite / Turbopack / Webpack / Rspack
部署平台：Vercel / Cloudflare / Netlify / 自建
负责人：
```

---

## 2. 环境配置

| 环境 | URL | 用途 | 配置 |
|---|---|---|---|
| dev | localhost:3000 | 本地开发 | .env.development |
| preview | preview-{pr}.example.com | PR 预览 | .env.staging |
| staging | staging.example.com | 联调测试 | .env.staging |
| prod | example.com | 生产 | .env.production |

---

## 3. 环境变量清单

### 公开（进 bundle）

```text
VITE_API_URL=
VITE_GA_ID=
VITE_SENTRY_DSN=
VITE_FEATURE_FLAGS=
```

### 私密（不进 bundle / 服务端用）

```text
DATABASE_URL
STRIPE_SECRET_KEY
SESSION_SECRET
SMTP_PASSWORD
```

---

## 4. 构建配置

```text
□ TypeScript 严格模式
□ Code splitting（路由级）
□ Tree shaking
□ Source Map 生产关闭或 hidden
□ Manual chunks（vendor 拆分）
□ 哈希文件名
□ 资源压缩（Terser / SWC）
□ Brotli 压缩
□ 图片优化插件
□ Bundle 分析工具
```

---

## 5. Bundle 预算

```text
单 chunk 上限：200 KB（gzip）
总 JS：500 KB
总 CSS：100 KB
首屏图片：200 KB

CI 阻塞：超出预算合并失败
```

---

## 6. 静态资源 / CDN

```text
□ 静态资源分发到 CDN
□ Cache-Control: public, max-age=31536000, immutable（哈希文件名）
□ HTML 短缓存（max-age=3600）
□ Brotli + Gzip
□ HTTP/2 / HTTP/3
□ DNS prefetch / preconnect
```

---

## 7. 安全 Header

```text
□ Strict-Transport-Security: max-age=63072000; includeSubDomains
□ X-Content-Type-Options: nosniff
□ X-Frame-Options: DENY
□ Referrer-Policy: strict-origin-when-cross-origin
□ Permissions-Policy
□ Content-Security-Policy
□ X-XSS-Protection（旧浏览器兼容）
```

---

## 8. CSP 模板

```text
Content-Security-Policy:
  default-src 'self';
  script-src 'self' 'unsafe-inline' 'unsafe-eval' https://www.googletagmanager.com;
  style-src 'self' 'unsafe-inline' https://fonts.googleapis.com;
  font-src 'self' https://fonts.gstatic.com;
  img-src 'self' data: https://*.cloudinary.com;
  connect-src 'self' https://api.example.com https://*.sentry.io;
  frame-ancestors 'none';
  base-uri 'self';
  form-action 'self';
```

---

## 9. CI/CD 流水线

| 步骤 | 工具 | 阻塞 |
|---|---|---|
| Lint | ESLint / Biome | ✅ |
| TypeCheck | tsc | ✅ |
| Unit Test | Vitest / Jest | ✅ |
| Coverage | v8 / istanbul | ✅（< 80%）|
| Build | Vite / Next | ✅ |
| Bundle Size | bundlesize | ✅（> budget）|
| E2E | Playwright | ✅ |
| Lighthouse | LHCI | ✅（< 90）|
| Visual Regression | Chromatic | 警告 |
| a11y | axe-core | ✅ |
| Deploy | Vercel / CF | - |

---

## 10. 部署阶段

```text
PR 创建：
  □ 自动跑 CI
  □ 部署 Preview 环境
  □ 评论 Preview URL
  □ Lighthouse 评分

主分支合并：
  □ 跑全部测试
  □ 部署 Production
  □ 监控 5 分钟
  □ 错误率 / 性能告警

灰度（如启用）：
  □ Phase 1: 5% 流量
  □ Phase 2: 50%（监控通过）
  □ Phase 3: 100%
  □ 失败自动回滚
```

---

## 11. 回滚

```text
□ Vercel / Cloudflare 一键回滚
□ Git revert + push
□ 回滚时长目标：< 5 min
□ 回滚验证清单
□ 通知机制
```

---

## 12. 监控

```text
□ 部署成功率
□ 构建时长
□ Bundle 大小趋势
□ Sentry 错误
□ Web Vitals（RUM）
□ Uptime 监控（UptimeRobot / Pingdom）
□ Slack / 邮件告警
```

---

## 13. Docker（如自建）

```text
□ 多阶段构建（节省镜像大小）
□ Alpine 基础镜像
□ 用户切换（非 root）
□ HEALTHCHECK
□ 镜像 < 200 MB
□ 标签策略（git sha + tag）
□ 镜像扫描（Trivy）
```

---

## 14. 依赖安全

```text
□ Snyk / Dependabot 自动 PR
□ npm audit / pnpm audit
□ 锁定版本（lockfile）
□ 依赖最少化
□ 更新策略（每月）
```

---

## 15. 自检

```text
□ 环境变量分级
□ 公开 / 私密区分
□ Bundle 预算
□ 静态资源 CDN
□ 安全 Header
□ CSP 配置
□ CI/CD 完整
□ PR 预览
□ Lighthouse CI
□ E2E 集成
□ 一键回滚
□ 监控接入
□ 文档化（部署手册）
```
