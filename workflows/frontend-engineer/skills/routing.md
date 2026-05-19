# 前端 Skills 路由矩阵

## 按用户意图

| 用户说 | 加载 skill |
|--------|-----------|
| "组件怎么拆" / "复用" / "Atomic Design" | [component-architecture](component-architecture/SKILL.md) |
| "状态管理" / "Redux" / "Zustand" / "Pinia" | [state-management](state-management/SKILL.md) |
| "样式" / "CSS" / "Tailwind" / "主题" | [styling-system](styling-system/SKILL.md) |
| "路由" / "权限" / "导航" / "守卫" | [routing-navigation](routing-navigation/SKILL.md) |
| "表单" / "校验" / "提交" | [forms-validation](forms-validation/SKILL.md) |
| "API 调用" / "loading" / "缓存" / "TanStack Query" | [data-fetching](data-fetching/SKILL.md) |
| "卡顿" / "首屏慢" / "包大小" / "Web Vitals" | [performance-optimization](performance-optimization/SKILL.md) |
| "无障碍" / "屏幕阅读器" / "ARIA" / "键盘" | [accessibility-implementation](accessibility-implementation/SKILL.md) |
| "单元测试" / "E2E" / "Storybook" / "MSW" | [testing-frontend](testing-frontend/SKILL.md) |
| "小程序" / "微信" / "Taro" / "uni-app" | [miniprogram-development](miniprogram-development/SKILL.md) |
| "APP" / "React Native" / "Flutter" / "Expo" / "Tauri" | [mobile-hybrid](mobile-hybrid/SKILL.md) |
| "构建" / "部署" / "CI" / "Vite 配置" | [build-deploy](build-deploy/SKILL.md) |

## 按任务场景

| 场景 | 推荐 skill 组合 |
|------|----------------|
| 单组件实现（S 级） | component-architecture + styling-system + testing-frontend |
| 单页面（M 级） | + state-management + data-fetching + forms-validation + routing-navigation |
| 复杂业务（L 级） | + performance-optimization + accessibility-implementation |
| 核心产品（XL 级） | 全部 + build-deploy 重点 |
| 性能优化专项 | performance-optimization + data-fetching + build-deploy |
| 无障碍专项 | accessibility-implementation + testing-frontend |
| 设计系统建设 | component-architecture + styling-system + testing-frontend |

## 按复杂度

| 复杂度 | 时长 | 典型组合 |
|--------|------|---------|
| S | 10~30min | component-architecture + testing-frontend |
| M | 30~120min | + state + data + forms + styling |
| L | 2~6h | + routing + performance + a11y |
| XL | 6h+ | 全部 + build-deploy |

## 路径交叉

```text
新页面实现：
  component-architecture（设计组件树）
  → styling-system（样式实现）
  → state-management（局部状态）
  → data-fetching（API 集成）
  → forms-validation（表单）
  → routing-navigation（接入路由）
  → testing-frontend（测试）
  → accessibility-implementation（a11y 检查）
  → performance-optimization（性能）

性能优化：
  performance-optimization（定位）
  → data-fetching（缓存策略）
  → component-architecture（虚拟化 / memo）
  → build-deploy（包优化）

设计系统建设：
  component-architecture（组件库结构）
  → styling-system（token + 主题）
  → accessibility-implementation（每个组件 a11y）
  → testing-frontend（Storybook + 视觉回归）
  → build-deploy（库打包发布）
```

## 路由未命中处理

按 `CONTRIBUTING.md` 流程新增。
