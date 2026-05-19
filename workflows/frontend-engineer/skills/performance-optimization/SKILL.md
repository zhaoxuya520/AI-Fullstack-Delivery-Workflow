---
name: performance-optimization
description: 优化前端性能 / 包大小 / 渲染 / 网络时使用。覆盖 Web Vitals (LCP/INP/CLS) / Bundle / Image / Code Splitting / 虚拟列表。融合性能预算 + RUM + 优化优先级。
---

# 性能优化（Performance Optimization）

参考来源：Google Web Vitals、Web.dev、Vercel Edge / Next.js 性能实践、Stripe 前端性能指南、Core Web Vitals 2024 更新（FID → INP）。

## 适用场景

- 首屏速度优化（LCP / FCP）
- 交互响应（INP / TTI）
- 视觉稳定性（CLS）
- 包大小优化
- 大列表 / 大表格性能
- 长任务拆解
- 内存泄漏排查

## 核心原则

```text
1. 测量优先，不要猜
   先 Lighthouse / DevTools / RUM
   定位瓶颈再优化

2. 性能预算
   首屏 JS < 200KB（gzip）
   首屏图片 < 200KB
   LCP < 2.5s / INP < 200ms / CLS < 0.1

3. 关注真实用户（RUM）
   实验室数据 ≠ 真实数据

4. 优先级：网络 → 渲染 → 计算
   - 减少传输
   - 减少阻塞
   - 减少重排

5. 不过早优化
   小项目过度优化 = 浪费时间

6. 持续监控
   性能退化是渐进的
```

## Core Web Vitals 2026

| 指标 | 含义 | 好 | 差 |
|---|---|---|---|
| **LCP** | Largest Contentful Paint | < 2.5s | > 4s |
| **INP** | Interaction to Next Paint（替代 FID）| < 200ms | > 500ms |
| **CLS** | Cumulative Layout Shift | < 0.1 | > 0.25 |
| **FCP** | First Contentful Paint | < 1.8s | > 3s |
| **TTFB** | Time to First Byte | < 800ms | > 1.8s |

## 性能预算（Performance Budget）

```text
首屏（Critical Path）：
  HTML：< 30 KB
  关键 CSS：< 15 KB（inline 或 critical CSS）
  JS（首屏）：< 200 KB（gzip）
  字体：< 100 KB（仅必要字重）
  首屏图片：< 200 KB（webp/avif）
  
总页面：
  JS（全部）：< 500 KB
  CSS（全部）：< 100 KB
  图片（全部）：< 1 MB

时间：
  TTFB：< 800ms
  LCP：< 2.5s
  INP：< 200ms
  CLS：< 0.1
```

## 测量工具

### 实验室

```text
Lighthouse（Chrome DevTools / CLI）：
  - Performance 评分
  - 4 个 Web Vitals
  - 问题清单

WebPageTest：
  - 多地理位置
  - 网络节流
  - 视频对比

Chrome DevTools：
  - Performance 面板（火焰图）
  - Network 面板
  - Coverage（未用代码）
  - Memory 面板（泄漏）

Bundle Analyzer：
  - webpack-bundle-analyzer
  - vite-bundle-visualizer
  - Source Map Explorer
```

### 真实用户（RUM）

```typescript
import { onLCP, onINP, onCLS, onFCP, onTTFB } from 'web-vitals';

function sendToAnalytics(metric: any) {
  // 发到 Sentry / Datadog / GA / 自建
  navigator.sendBeacon('/analytics', JSON.stringify({
    name: metric.name,
    value: metric.value,
    id: metric.id,
    rating: metric.rating,  // 'good' | 'needs-improvement' | 'poor'
    url: window.location.pathname,
  }));
}

onLCP(sendToAnalytics);
onINP(sendToAnalytics);
onCLS(sendToAnalytics);
onFCP(sendToAnalytics);
onTTFB(sendToAnalytics);
```

## 1. 网络优化（最大杠杆）

### 减少 / 推迟资源

```text
策略：
  □ 移除未用代码（Tree-shake）
  □ 第三方脚本 lazy load（async / defer）
  □ 字体子集 + font-display: swap
  □ 图片 webp / avif + responsive
  □ HTTP/2 / HTTP/3
  □ Brotli 压缩
  □ CDN 边缘
```

### 图片优化（最大坑）

```typescript
// Next.js Image
<Image
  src="/hero.jpg"
  alt="Hero"
  width={1200}
  height={600}
  priority                    // 首屏加 priority
  placeholder="blur"
  blurDataURL="..."
/>

// 原生 picture
<picture>
  <source type="image/avif" srcset="hero.avif" />
  <source type="image/webp" srcset="hero.webp" />
  <img
    src="hero.jpg"
    alt="Hero"
    loading="lazy"            // 非首屏 lazy
    decoding="async"
    width="1200"
    height="600"              // 必填（防 CLS）
  />
</picture>

// Responsive srcset
<img
  src="hero-small.jpg"
  srcset="hero-small.jpg 400w, hero-medium.jpg 800w, hero-large.jpg 1200w"
  sizes="(max-width: 600px) 400px, (max-width: 1200px) 800px, 1200px"
  alt="Hero"
/>
```

### 字体优化

```css
@font-face {
  font-family: 'Inter';
  src: url('/fonts/Inter-var.woff2') format('woff2-variations');
  font-display: swap;          /* 不阻塞渲染 */
  font-weight: 100 900;
}

/* 子集 - 只用拉丁 */
@font-face {
  font-family: 'Inter';
  src: url('/fonts/Inter-latin.woff2') format('woff2');
  unicode-range: U+0000-007F;
}
```

```html
<!-- 关键字体预加载 -->
<link rel="preload" href="/fonts/Inter-var.woff2" as="font" type="font/woff2" crossorigin>
```

### 关键资源 preload / prefetch

```html
<!-- 当前页关键 -->
<link rel="preload" href="/api/critical-data" as="fetch" crossorigin>

<!-- 下一页可能用 -->
<link rel="prefetch" href="/dashboard">

<!-- DNS 预解析 -->
<link rel="dns-prefetch" href="https://api.example.com">
<link rel="preconnect" href="https://api.example.com">
```

## 2. 包大小优化

### Bundle 分析

```bash
# Vite
npm i -D rollup-plugin-visualizer
# vite.config.ts
import { visualizer } from 'rollup-plugin-visualizer';
plugins: [visualizer({ open: true, gzipSize: true })]

# Webpack
npm i -D webpack-bundle-analyzer
```

### Tree Shaking

```typescript
// ✅ 命名导入（tree-shake 友好）
import { debounce } from 'lodash-es';

// ❌ 整库引入
import _ from 'lodash';

// ❌ CommonJS 难 tree-shake
import { debounce } from 'lodash';
```

### Code Splitting

```typescript
// 路由级（最重要）
const Dashboard = lazy(() => import('./pages/Dashboard'));
const Settings = lazy(() => import('./pages/Settings'));

// 组件级（重组件 / 模态）
const HeavyChart = lazy(() => import('./HeavyChart'));

function App() {
  return (
    <Suspense fallback={<Skeleton />}>
      <HeavyChart />
    </Suspense>
  );
}

// 命名 chunk
const HeavyChart = lazy(() => 
  import(/* webpackChunkName: "heavy-chart" */ './HeavyChart')
);
```

### 替换大库

```text
moment.js (66KB) → date-fns (modular) / dayjs (2KB)
lodash → lodash-es (tree-shake) / 单独函数
axios → fetch / ky
全 ECharts → echarts/core + 按需导入模块
全 lucide-react → lucide-react/icons/Specific
```

### 动态导入

```typescript
// 按需加载重计算
async function exportToExcel(data) {
  const { utils, writeFile } = await import('xlsx');
  const ws = utils.json_to_sheet(data);
  // ...
}
```

## 3. 渲染优化

### React 优化

```typescript
// 1. memo（仅当父组件频繁渲染但 props 不变）
const ExpensiveItem = memo(function ExpensiveItem({ item }) {
  return <div>...</div>;
});

// 2. useMemo（重计算）
const filteredList = useMemo(
  () => list.filter(complexFilter),
  [list]
);

// 3. useCallback（传给 memo 子组件）
const handleClick = useCallback((id: number) => {
  setSelectedId(id);
}, []);

// 4. 状态拆分（减少重渲染范围）
// ❌ 大对象
const [state, setState] = useState({ ... 10 个字段 ... });

// ✅ 拆细
const [name, setName] = useState('');
const [age, setAge] = useState(0);
// ...

// 5. 用 Zustand selector 避免重渲染
const userName = useStore((s) => s.user.name);  // 仅 name 变才重渲

// 6. React Compiler（实验，自动优化）
```

### Vue 3 优化

```vue
<!-- 1. v-once 静态内容 -->
<header v-once>
  <h1>{{ title }}</h1>
</header>

<!-- 2. v-memo 跳过重渲染 -->
<div v-for="item in list" v-memo="[item.id, item.selected]">
  ...
</div>

<!-- 3. 大列表 shallowRef -->
<script setup>
import { shallowRef } from 'vue';
const heavyData = shallowRef(largeArray);
</script>

<!-- 4. 异步组件 -->
<script setup>
import { defineAsyncComponent } from 'vue';
const HeavyChart = defineAsyncComponent(() => import('./HeavyChart.vue'));
</script>
```

### 虚拟列表（大数据必备）

```typescript
// TanStack Virtual
import { useVirtualizer } from '@tanstack/react-virtual';

function VirtualList({ items }: { items: Item[] }) {
  const parentRef = useRef<HTMLDivElement>(null);
  
  const virtualizer = useVirtualizer({
    count: items.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 50,
    overscan: 5,
  });
  
  return (
    <div ref={parentRef} style={{ height: 600, overflow: 'auto' }}>
      <div style={{ height: virtualizer.getTotalSize(), position: 'relative' }}>
        {virtualizer.getVirtualItems().map((virtualRow) => (
          <div
            key={virtualRow.key}
            style={{
              position: 'absolute',
              top: 0,
              left: 0,
              width: '100%',
              height: virtualRow.size,
              transform: `translateY(${virtualRow.start}px)`,
            }}
          >
            {items[virtualRow.index].name}
          </div>
        ))}
      </div>
    </div>
  );
}
```

### CLS 优化

```text
原因：图片 / 广告 / 字体 / 异步内容插入

解决：
  □ 图片必须有 width/height（保留位置）
  □ 字体 size-adjust 适配
  □ 骨架屏占位
  □ 广告 / 嵌入式预留容器（min-height）
  □ Skeleton 与最终尺寸一致
```

```html
<!-- 必须 width / height -->
<img src="hero.jpg" alt="" width="1200" height="600" />

<!-- 或 aspect-ratio -->
<div style="aspect-ratio: 16/9; background: #eee;">
  <img src="hero.jpg" alt="" />
</div>
```

### INP 优化

```text
INP = 用户交互 → 下次绘制的时间

优化：
  □ 长任务拆分（< 50ms）
  □ 防抖输入
  □ 节流滚动
  □ Web Worker 计算
  □ requestIdleCallback / scheduler.yield()
  □ 避免 forced reflow
```

```typescript
// 长任务拆分
async function processLargeData(data: Data[]) {
  const chunks = chunk(data, 100);
  for (const c of chunks) {
    processChunk(c);
    await new Promise(resolve => setTimeout(resolve, 0));  // yield
  }
}

// scheduler.yield()（新 API，更精确）
async function processLargeData(data: Data[]) {
  for (const item of data) {
    processItem(item);
    if ('scheduler' in window && 'yield' in scheduler) {
      await scheduler.yield();
    }
  }
}

// Web Worker
const worker = new Worker(new URL('./worker.ts', import.meta.url));
worker.postMessage(data);
worker.onmessage = (e) => setResult(e.data);
```

## 4. 缓存与离线

```text
HTTP 缓存：
  - Cache-Control: public, max-age=31536000, immutable（哈希文件名）
  - ETag / Last-Modified（HTML）

Service Worker：
  - 预缓存关键资源
  - Stale-While-Revalidate
  - 离线兜底页

应用层：
  - TanStack Query 内存缓存
  - localStorage 用户偏好
  - IndexedDB 大量数据
```

## 5. SSR / 流式渲染

```text
SSR 优势：
  - 首屏快（HTML 直出）
  - SEO 好
  
潜在问题：
  - TTFB 慢（服务端渲染要时间）
  - hydration 慢

优化：
  - Streaming SSR（HTML 流式返回）
  - Server Components（React 19）
  - Selective Hydration（部分 hydrate）
  - Islands（Astro / Qwik）
  - Resumability（Qwik）
```

## 性能优化优先级（ROI）

```text
1. 图片优化（40% 收益）
2. 包大小（20%）
3. Code splitting（15%）
4. 虚拟列表（10%）
5. memo / useMemo（5%）
6. 微优化（5%）

不要：
  - 还没测就 memo 全部
  - useMemo 所有计算
  - useCallback 所有函数
```

## 工作流程

```text
1. 测量基线
   - Lighthouse / RUM
   - 记录 Web Vitals

2. 找瓶颈
   - 网络（最常见）
   - 渲染（中等）
   - 计算（少）

3. 性能预算
   - 首屏 JS / CSS / 图片预算
   - LCP / INP / CLS 目标

4. 实施优化（按优先级）

5. 重新测量

6. 持续监控（RUM）

7. 性能退化告警
   - LCP P75 > 2.5s 持续 → 告警
```

## 配套模板

- `templates/performance-checklist.md` — Web Vitals + 包大小 + 图片 + 字体 + 渲染 + 监控

## 质量自检

```text
□ Lighthouse Performance ≥ 90
□ LCP < 2.5s（P75）
□ INP < 200ms（P75）
□ CLS < 0.1
□ 首屏 JS < 200KB（gzip）
□ 总 CSS < 100KB
□ 图片 webp/avif + 懒加载
□ 字体 woff2 + font-display: swap
□ 路由级 code splitting
□ 大列表虚拟化
□ Tree-shake 友好导入
□ 包分析检查
□ RUM 监控接入
□ 性能预算文档化
```

## 常见坑

1. **图片不优化**——LCP 直接挂
2. **图片不限尺寸**——CLS 爆炸
3. **字体阻塞渲染**——FOIT
4. **整库引入**——包翻倍
5. **不 code splitting**——首屏 1MB
6. **memo 全部**——过度优化反而慢
7. **useEffect 滥用**——无限重渲染
8. **大列表不虚拟化**——卡死
9. **同步阻塞操作**——长任务
10. **不监控 RUM**——线上才知道
11. **第三方脚本同步加载**——阻塞首屏
12. **CSS 大量 @import**——串行加载
13. **图片用 background-image**——不能 lazy
14. **scroll handler 不节流**——卡顿
15. **不预加载关键字体**——FOUT

## 与其他 skill 的协作

```text
上游：
  ui-ux-designer 工作流 → 设计 / 图片资源
  api-designer → 接口性能 / 缓存策略

下游：
  build-deploy → 打包优化
  observability（前端）→ RUM 接入
  testing-frontend → 性能测试
```

## 相关参考

- 项目根 `references/frontend-tech-stack-guide.md` — 性能工具
