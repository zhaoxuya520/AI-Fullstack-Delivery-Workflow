---
name: design-tokens
description: 建立设计令牌系统时使用。适用于设计系统建立、跨平台一致性、设计代码同步。优先使用 W3C DTCG 2025.10 标准 + 三层 Token + JSON 输出。
---

# Design Tokens（设计令牌）

参考来源：[W3C DTCG 2025.10](https://tr.designtokens.org/)、[GitLab Design Tokens](https://design.gitlab.com/product-foundations/design-tokens-authoring)

## 适用场景

- 设计系统从零建立
- 多产品/多品牌的设计一致性
- 设计和代码的单一数据源
- 主题切换（暗黑模式、品牌切换）

## 核心思想

Design Tokens 是设计决策的单一数据源，用机器可读的格式存储：

```text
颜色 / 字体 / 间距 / 圆角 / 阴影 / 动效时长
→ 写成 JSON
→ 设计工具和代码都从同一份 JSON 读取
→ 改一处 = 全产品同步
```

## 三层 Token 架构

### 1. 全局 Token（Global / Primitive）

原始值，不带语义

```json
{
  "color": {
    "blue": {
      "50": { "$value": "#eff6ff", "$type": "color" },
      "500": { "$value": "#2563eb", "$type": "color" },
      "900": { "$value": "#1e3a8a", "$type": "color" }
    }
  },
  "spacing": {
    "1": { "$value": "4px", "$type": "dimension" },
    "2": { "$value": "8px", "$type": "dimension" },
    "4": { "$value": "16px", "$type": "dimension" }
  }
}
```

### 2. 语义 Token（Semantic / Alias）

按用途命名，引用全局 Token

```json
{
  "color": {
    "text": {
      "primary": { "$value": "{color.gray.900}", "$type": "color" },
      "secondary": { "$value": "{color.gray.600}", "$type": "color" },
      "danger": { "$value": "{color.red.600}", "$type": "color" }
    },
    "bg": {
      "surface": { "$value": "{color.white}", "$type": "color" },
      "muted": { "$value": "{color.gray.50}", "$type": "color" }
    }
  }
}
```

### 3. 组件 Token（Component）

组件专用，引用语义 Token

```json
{
  "button": {
    "primary": {
      "bg": { "$value": "{color.brand.500}", "$type": "color" },
      "text": { "$value": "{color.white}", "$type": "color" },
      "padding": {
        "x": { "$value": "{spacing.4}", "$type": "dimension" },
        "y": { "$value": "{spacing.2}", "$type": "dimension" }
      }
    }
  }
}
```

## 命名规范（DTCG）

```text
[类别].[属性].[变体].[状态]

color.text.primary
color.bg.surface.hover
spacing.inline.sm
font.weight.bold
button.primary.bg
border.radius.md
```

## 完整 Token 集（最小集）

```json
{
  "color": {
    "text": {
      "primary": { "$value": "#1a1a1a", "$type": "color" },
      "secondary": { "$value": "#6b7280", "$type": "color" },
      "tertiary": { "$value": "#9ca3af", "$type": "color" },
      "inverse": { "$value": "#ffffff", "$type": "color" },
      "danger": { "$value": "#dc2626", "$type": "color" },
      "success": { "$value": "#16a34a", "$type": "color" }
    },
    "bg": {
      "surface": { "$value": "#ffffff", "$type": "color" },
      "muted": { "$value": "#f9fafb", "$type": "color" },
      "subtle": { "$value": "#f3f4f6", "$type": "color" }
    },
    "border": {
      "default": { "$value": "#e5e7eb", "$type": "color" },
      "focus": { "$value": "#2563eb", "$type": "color" },
      "danger": { "$value": "#dc2626", "$type": "color" }
    }
  },
  "spacing": {
    "xs": { "$value": "4px", "$type": "dimension" },
    "sm": { "$value": "8px", "$type": "dimension" },
    "md": { "$value": "16px", "$type": "dimension" },
    "lg": { "$value": "24px", "$type": "dimension" },
    "xl": { "$value": "32px", "$type": "dimension" }
  },
  "font": {
    "size": {
      "xs": { "$value": "12px", "$type": "dimension" },
      "sm": { "$value": "13px", "$type": "dimension" },
      "base": { "$value": "14px", "$type": "dimension" },
      "lg": { "$value": "16px", "$type": "dimension" },
      "xl": { "$value": "18px", "$type": "dimension" },
      "2xl": { "$value": "24px", "$type": "dimension" }
    },
    "weight": {
      "normal": { "$value": "400", "$type": "fontWeight" },
      "medium": { "$value": "500", "$type": "fontWeight" },
      "bold": { "$value": "600", "$type": "fontWeight" }
    }
  },
  "radius": {
    "sm": { "$value": "4px", "$type": "dimension" },
    "md": { "$value": "8px", "$type": "dimension" },
    "lg": { "$value": "12px", "$type": "dimension" },
    "full": { "$value": "9999px", "$type": "dimension" }
  },
  "shadow": {
    "sm": { "$value": "0 1px 2px rgba(0,0,0,0.05)", "$type": "shadow" },
    "md": { "$value": "0 4px 6px rgba(0,0,0,0.1)", "$type": "shadow" },
    "lg": { "$value": "0 10px 15px rgba(0,0,0,0.1)", "$type": "shadow" }
  }
}
```

## 工作流程

```text
1. 收集设计需求（颜色/字体/间距）
2. 设计全局 Token（原始值）
3. 提炼语义 Token（按用途）
4. 为高频组件创建组件 Token
5. 输出 JSON 文件
6. 在设计工具同步（Figma Variables）
7. 在代码中实现（Tailwind config / CSS variables）
```

## 质量自检

```text
□ 是否分了三层（全局/语义/组件）
□ 命名是否符合 DTCG 规范
□ 语义 Token 是否引用全局 Token（不直接写值）
□ 是否覆盖了所有设计原语（颜色/间距/字体/圆角/阴影）
□ 是否考虑了主题切换（暗黑模式）
```

## 常见坑

1. **没有分层**——直接在组件用原始值
2. **命名不一致**——color.primary vs color.brand.primary
3. **语义层缺失**——直接用 color.blue.500 代替 color.text.link
4. **不可机器读取**——只在 Figma 里有，代码用不了
5. **手动维护**——设计改了忘记同步代码

## 配套模板

- `templates/tokens-base.json` — 基础 Token JSON 模板
- `templates/tokens-dark-mode.json` — 暗黑模式扩展模板

## 与其他 skill 的协作

```text
上游：
  visual-style → 提供视觉风格指引

平行：
  atomic-design → Atoms 使用 Tokens
  responsive-design → 断点 Tokens

下游：
  design-handoff → JSON 直接交给前端
```
