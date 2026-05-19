---
name: accessibility
description: 设计无障碍可访问的界面时使用。适用于满足 WCAG 标准、键盘导航、屏幕阅读器支持。优先使用 WCAG 2.2 AA 级标准 + 键盘 + 焦点 + 对比度 + ARIA。
---

# 可访问性（Accessibility / A11y）

参考来源：[WCAG 2.2](https://www.w3.org/TR/WCAG22/)、[The Accessible UI/UX Design Playbook 2026](https://www.forasoft.com/blog/article/ai-accessibility-ui-ux-design)

## 适用场景

- 政府 / 教育 / 公共服务产品（合规要求）
- 国际化产品（欧美市场）
- 用户群体多样（老人 / 视障 / 听障）
- 提升整体产品质量

## 核心原则（WCAG POUR）

```text
Perceivable（可感知）
  内容必须能被所有用户感知
  - 文本替代（图标 alt）
  - 字幕（视频）
  - 颜色不是唯一信息载体

Operable（可操作）
  界面必须能被所有用户操作
  - 键盘可用
  - 足够时间
  - 不引发癫痫（避免快速闪烁）
  - 易于导航

Understandable（可理解）
  内容和操作必须能被理解
  - 语言标识
  - 可预测的行为
  - 输入帮助

Robust（健壮）
  必须兼容辅助技术
  - 语义 HTML
  - ARIA 属性
  - 屏幕阅读器友好
```

## WCAG 等级

```text
A  （最低）：基本可访问性
AA （推荐）：行业标准 ← 大部分产品的目标
AAA（最高）：高级别要求

本 skill 默认 AA 级。
```

## 核心检查清单

### 视觉

```text
□ 文字对比度 ≥ 4.5:1（正文，AA 级）
□ 文字对比度 ≥ 3:1（大文字 18px+ 或 14px+ bold）
□ 非文字元素对比度 ≥ 3:1（图标、边框、按钮边）
□ 颜色不是唯一信息载体（错误状态除红色外加 ✗ 图标）
□ 文字可缩放至 200% 不破坏布局
□ 不依赖颜色区分链接（加下划线）
```

### 键盘

```text
□ 所有可交互元素键盘可达（Tab 键）
□ Tab 顺序符合视觉顺序
□ 焦点状态明显（不是浏览器默认的 outline:none）
□ 没有键盘陷阱（能进去能出来）
□ 键盘快捷键可关闭/重映射
□ Skip Link（跳过导航直达内容）
```

### 触控

```text
□ 触控目标最小 44×44px
□ 相邻可点击元素间距 ≥ 8px
□ 不依赖手势（提供按钮替代）
```

### 语义和结构

```text
□ 用语义 HTML（h1-h6/nav/main/article 而非 div）
□ 标题层级正确（不跳级）
□ 表单字段有 label
□ 图片有 alt（装饰图 alt=""）
□ 图标有 aria-label 或文字
□ 动态内容用 aria-live 通知
```

### 动效

```text
□ 支持 prefers-reduced-motion 媒体查询
□ 没有快速闪烁（< 3 次/秒）
□ 自动播放可暂停
□ 视差滚动可关闭
```

### 表单

```text
□ 错误信息不只用颜色（加图标 + 文字）
□ 错误信息有 aria-describedby 关联
□ 必填字段明确标识
□ 提示文字（placeholder）不替代 label
□ 表单可被键盘完全填写和提交
```

### 媒体

```text
□ 视频有字幕
□ 音频有文字版本
□ 图表有数据替代（表格）
```

## 焦点环（Focus Ring）设计

```text
不要做：
  - 移除 outline（outline: none）
  - 用极淡的颜色

要做：
  - 焦点可见（蓝色 outline / 阴影）
  - 焦点宽度 ≥ 2px
  - 焦点对比度 ≥ 3:1
  - 提供 :focus-visible 区分键盘和鼠标

示例 CSS：
.button:focus-visible {
  outline: 2px solid var(--color-focus);
  outline-offset: 2px;
}
```

## ARIA 常见用法

```text
aria-label="关闭"            # 图标按钮
aria-labelledby="title-id"   # 引用标题
aria-describedby="desc-id"   # 引用描述
aria-hidden="true"           # 装饰元素，屏幕阅读器跳过
aria-live="polite"           # 动态通知（不打断）
aria-live="assertive"        # 紧急通知（打断）
aria-expanded="true|false"   # 折叠状态
aria-controls="panel-id"     # 控制的元素
role="alert"                 # 警告
role="dialog"                # 对话框
```

## 输出格式

```markdown
## 可访问性检查：[页面/组件]

### WCAG 等级目标：AA

### 视觉
✅ 主文本对比度：6.2:1（黑#1a1a1a on 白）
✅ 副文本对比度：4.6:1
⚠️ 灰色 placeholder：3.2:1（达到 AA 大文字标准）

### 键盘
✅ 所有交互元素 Tab 可达
✅ 焦点环：2px 蓝色 outline
✅ 无键盘陷阱
✅ Skip Link 已设置

### 触控
✅ 按钮：48px × 48px
✅ 列表项：56px 高
✅ 间距：12px

### 语义
✅ 使用 nav/main/article
✅ 标题层级：h1 → h2 → h3
✅ 所有图标有 aria-label

### 动效
✅ 支持 prefers-reduced-motion
✅ 无快速闪烁

### 待修复
- ⚠️ 灰色 placeholder 对比度偏低，建议加深到 4.5:1
- ⚠️ 头像图片缺少 alt 属性
```

## 工作流程

```text
1. 设计完成后做可访问性检查
2. 用核心检查清单逐项检查
3. 用工具验证（axe DevTools / WAVE）
4. 修复问题（按严重程度）
5. 输出可访问性报告
6. 转交前端实现
```

## 工具推荐

```text
设计阶段：
  - Stark（Figma 插件）：对比度检查
  - Contrast Ratio Calculator

代码阶段：
  - axe DevTools（浏览器扩展）
  - WAVE（浏览器扩展）
  - Lighthouse（Chrome DevTools）
  - NVDA / VoiceOver（屏幕阅读器实测）
```

## 质量自检

```text
□ 是否符合 WCAG 2.2 AA 级
□ 所有交互元素键盘可达
□ 焦点状态明显
□ 对比度满足要求
□ 颜色不是唯一信息
□ 表单有 label 和错误提示
□ 图标有文字替代
□ 支持 reduced-motion
□ 用工具实测过（不是只看清单）
```

## 常见坑

1. **outline: none 没有替代**——键盘用户失去焦点反馈
2. **只用颜色表达状态**——色盲用户看不出错误
3. **对比度刚好达标**——4.5:1 在某些屏幕上还是难读
4. **placeholder 当 label 用**——视障用户找不到字段名
5. **aria-label 翻译错误**——中文产品用了英文 label
6. **图标按钮没有 label**——纯图标按钮屏幕阅读器读不出
7. **触控目标太小**——移动端 24px 按钮老人点不准
8. **不实测**——只看清单不用屏幕阅读器测

## 配套模板

- `templates/a11y-checklist-template.md` — 完整检查清单模板
- `templates/contrast-table-template.md` — 对比度记录表模板
- `templates/aria-cheatsheet.md` — ARIA 速查表

## 与其他 skill 的协作

```text
上游：
  page-structure → 列出所有需要检查的元素

平行：
  component-states → Focus 状态
  design-tokens → 对比度 tokens
  visual-style → 视觉风格不能违反对比度

下游：
  design-handoff → 可访问性要求交接给前端
  usability-evaluation → 可访问性是评审重点之一
```
