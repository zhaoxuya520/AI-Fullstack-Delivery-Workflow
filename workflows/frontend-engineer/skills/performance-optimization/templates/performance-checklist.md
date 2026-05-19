# 前端性能检查清单

## 1. 项目信息

```text
项目：
框架：
当前 Lighthouse 分：
目标 Lighthouse 分：≥ 90
负责人：
```

---

## 2. 性能预算

| 指标 | 预算 | 实测 |
|---|---|---|
| LCP（P75） | < 2.5s |  |
| INP（P75） | < 200ms |  |
| CLS（P75） | < 0.1 |  |
| FCP | < 1.8s |  |
| TTFB | < 800ms |  |
| TBT | < 200ms |  |
| 首屏 JS（gzip） | < 200 KB |  |
| 首屏 CSS（gzip） | < 30 KB |  |
| 总 JS | < 500 KB |  |
| 总图片 | < 1 MB |  |
| 字体 | < 100 KB |  |

---

## 3. 测量工具

```text
□ Lighthouse（CI 集成）
□ WebPageTest（真实地理位置）
□ Chrome DevTools Performance
□ Bundle Analyzer
□ Web Vitals lib（RUM）
□ Sentry / Datadog Performance
```

---

## 4. 网络优化

```text
□ HTTP/2 或 HTTP/3
□ Brotli 压缩
□ CDN 接入
□ 静态资源 immutable cache
□ HTML 短缓存（ETag / 1 hour）
□ DNS prefetch / preconnect 关键域
□ preload 关键资源
□ prefetch 下一页
```

---

## 5. 图片优化

```text
□ 格式：avif > webp > jpg
□ Responsive srcset / sizes
□ 首屏 priority / fetchpriority="high"
□ 非首屏 loading="lazy"
□ width / height 必填（防 CLS）
□ aspect-ratio 容器
□ 占位（blur / skeleton）
□ <picture> + 多格式 fallback
□ SVG 用于 icon / 简单图形
□ 图片 CDN（Cloudflare Images / imgix / 阿里云 OSS 处理）
```

---

## 6. 字体优化

```text
□ woff2 格式
□ font-display: swap
□ 字体子集（unicode-range）
□ 关键字体 preload
□ 限制字重（仅必要）
□ Variable Font（多字重合一）
□ 系统字体兜底（system-ui）
```

---

## 7. JS 优化

```text
□ Tree-shake 友好导入
□ Code splitting（路由级 + 组件级）
□ 第三方脚本 async / defer
□ 大库替换（moment → dayjs / lodash → 单函数）
□ Bundle 分析（< 阈值）
□ 移除 dev-only 代码（process.env.NODE_ENV）
□ 压缩（Terser / SWC）
□ Source Map 生产关闭或 hidden
□ Polyfill 按需（targets browserlist）
```

---

## 8. CSS 优化

```text
□ Critical CSS inline（首屏）
□ 非关键 CSS 异步
□ PurgeCSS / Tailwind tree-shake
□ 不用 @import（串行）
□ CSS-in-JS 评估开销
□ minify（cssnano）
□ 减少 selectors 复杂度
```

---

## 9. 渲染优化

```text
□ React.memo 必要时（不滥用）
□ useMemo / useCallback 必要时
□ 状态拆细（减少重渲染）
□ 虚拟列表（> 100 项）
□ Code splitting 重组件
□ Suspense + lazy
□ Server Components（如适用）
□ requestIdleCallback / scheduler.yield 长任务
□ Web Worker 计算密集
```

---

## 10. CLS 优化

```text
□ 图片 width / height
□ 字体 size-adjust
□ 骨架屏占位
□ 广告容器预留
□ 异步内容容器预留
□ transform 替代 top / left（动画）
```

---

## 11. INP 优化

```text
□ 长任务拆解（< 50ms）
□ scroll / input 节流
□ 输入防抖（搜索 300ms）
□ Web Worker 计算
□ 减少 forced reflow
□ 避免大 list 一次渲染
```

---

## 12. 缓存

```text
□ HTTP Cache-Control 配置
□ ETag / Last-Modified
□ Service Worker（PWA）
□ 应用层缓存（TanStack Query）
□ IndexedDB（大数据）
```

---

## 13. SSR / SSG（如适用）

```text
□ Streaming SSR
□ Selective Hydration
□ ISR（Next.js）
□ Server Components（React 19）
□ Edge runtime（Vercel / Cloudflare）
```

---

## 14. RUM 监控

```text
□ web-vitals lib 接入
□ 数据上报（Sentry / Datadog / 自建）
□ 按页面 / 按设备分组
□ P75 / P95 阈值告警
□ 退化检测（vs 上版本）
```

---

## 15. CI 集成

```text
□ Lighthouse CI（PR 阻塞）
□ Bundle Size 检查（大于阈值阻塞）
□ 性能预算 budget.json
□ 自动 PR 评论
```

---

## 16. 自检

```text
□ 测量基线
□ 性能预算
□ 图片 / 字体 / JS / CSS 优化
□ Code splitting
□ 虚拟列表（如需）
□ RUM 接入
□ Lighthouse ≥ 90
□ 持续监控
□ 退化告警
```
