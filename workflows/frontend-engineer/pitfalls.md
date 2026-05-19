# 前端工程师工作流常见坑

跨 skill 通用的高频坑，具体 skill 内的坑见各 SKILL.md。

## 1. 状态管理过度

- 表现：所有数据放 Redux / Context，组件间传递全靠全局。
- 风险：任意状态变化 → 全部重渲染，性能差。
- 避免：服务端数据用 TanStack Query，局部状态用 useState，全局仅必要。

## 2. 缺 loading / error / empty 状态

- 表现：只写成功路径，加载时白屏，错误时崩溃。
- 风险：用户体验差，QA 报大量 Bug。
- 避免：每个数据组件必须处理 4 种状态。

## 3. 表单不防重复提交

- 表现：用户连续点击"提交"，发出多次请求。
- 风险：重复创建订单 / 重复扣款。
- 避免：isSubmitting 禁用按钮 + 后端幂等。

## 4. useEffect 滥用

- 表现：useEffect 依赖数组错误 → 死循环 / 不触发。
- 风险：性能问题 / 数据不一致。
- 避免：用 TanStack Query 管理数据获取，减少手写 effect。

## 5. 大列表不虚拟化

- 表现：渲染 10000 个 DOM 节点。
- 风险：页面卡顿 / 内存爆。
- 避免：> 100 项用 TanStack Virtual / react-window。

## 6. 图片不优化

- 表现：原图 5MB 直接 `<img src>`，不压缩不懒加载。
- 风险：LCP 10 秒+，流量浪费。
- 避免：webp/avif + responsive srcset + lazy loading + CDN。

## 7. CSS 全局污染

- 表现：全局 CSS 类名冲突，改一处影响全站。
- 风险：样式不可预测。
- 避免：CSS Modules / Tailwind / scoped styles。

## 8. 写死颜色不用 Token

- 表现：`color: #4287f5` 散落各处。
- 风险：主题切换 / 暗黑模式无法实现。
- 避免：用 CSS 变量 / Tailwind 主题 / Token。

## 9. TypeScript any 滥用

- 表现：到处 `as any`，类型形同虚设。
- 风险：重构时无类型保护，Bug 难发现。
- 避免：strict 模式 + 禁止 any（ESLint 规则）。

## 10. 不测可访问性

- 表现：没有 ARIA / 键盘导航 / 屏幕阅读器测试。
- 风险：15% 用户被排除，法律风险。
- 避免：用 Headless 库 + axe-core 自动化 + 手动键盘测试。

## 11. 包过大不分割

- 表现：首屏 JS 1MB+，所有页面打一个 bundle。
- 风险：首屏加载 5 秒+。
- 避免：路由级 code splitting + 动态导入重组件。

## 12. 不缓存 API 响应

- 表现：每次进页面都重新请求，不用 stale-while-revalidate。
- 风险：重复请求 / 闪烁 / 慢。
- 避免：TanStack Query / SWR 自动缓存。

## 13. 直接改第三方组件源码

- 表现：fork 组件库改源码。
- 风险：升级地狱，安全补丁无法跟进。
- 避免：封装一层 wrapper，用 props / slot 覆盖。

## 14. SSR hydration 错误

- 表现：服务端渲染 HTML 与客户端不一致。
- 风险：闪烁 / 报错 / SEO 失效。
- 避免：不在 SSR 中用 window / localStorage / Date.now()。

## 15. 跳过 i18n 准备

- 表现：字符串硬编码在组件里。
- 风险：国际化时大改所有文件。
- 避免：从一开始用 i18n 库，字符串外置。

## 16. 不监控真实用户性能

- 表现：只看 Lighthouse 实验室数据。
- 风险：真实用户（慢网络 / 低端设备）体验差不知道。
- 避免：接入 web-vitals RUM + Sentry Performance。
