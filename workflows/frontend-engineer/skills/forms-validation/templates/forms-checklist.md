# 表单实现检查清单

## 1. 表单信息

```text
表单名：
路径：
表单库：React Hook Form / TanStack Form / VeeValidate / Formily / Angular
Schema 库：Zod / Valibot / Yup
负责人：
```

---

## 2. 字段清单

| 字段 | 类型 | 必填 | 校验 | 错误信息 | 默认值 |
|---|---|---|---|---|---|
| email | string | ✅ | email format | 请输入有效邮箱 | '' |
| password | string | ✅ | min 8 chars | 密码至少 8 个字符 | '' |
| age | number | ❌ | min 18, max 120 | 年龄 18~120 | - |

---

## 3. 校验时机

```text
□ onChange：[字段]
□ onBlur：默认（推荐）
□ onSubmit：[字段]
□ 异步校验：[字段] - 防抖 500ms
```

---

## 4. 提交策略

```text
□ isSubmitting 期间禁用按钮
□ 幂等键（关键操作）
□ 节流 / 防抖（如必要）
□ 提交后清除草稿
```

---

## 5. 错误处理

```text
字段级错误：
  □ aria-invalid 属性
  □ 错误消息 role="alert"
  □ 错误消息友好（不技术化）
  □ 焦点跳到首个错误

表单级错误（服务端）：
  □ 显示在表单顶部 / 按钮附近
  □ 业务错误友好（密码错误 vs INVALID_CREDENTIALS）
  □ 系统错误兜底（请稍后重试）

错误恢复：
  □ 用户修改后清除该字段错误
```

---

## 6. 用户体验

```text
□ Loading 状态（按钮文案变化）
□ 必填用 *（红色）
□ 默认值合理
□ 自动聚焦首个字段
□ Tab 顺序合理
□ Enter 提交
□ Esc 取消（弹窗内）
□ 移动端 input type / inputmode 正确
  - type="email" / inputmode="email"
  - type="tel"
  - type="number" / inputmode="numeric"
□ 字体 ≥ 16px（防 iOS 缩放）
□ 错误下方提示，不用 alert
□ 长表单分步
□ 草稿自动保存
□ 已填字段成功反馈（绿色 ✓）
```

---

## 7. 可访问性

```text
□ 每个 input 有 label
□ label htmlFor 关联 input id
□ aria-required（必填）
□ aria-invalid（无效）
□ aria-describedby（提示 / 错误关联）
□ 错误用 role="alert"
□ 焦点环可见
□ 屏幕阅读器测试
```

---

## 8. 安全

```text
□ 后端校验（前端只是体验）
□ XSS 防护（不直接 innerHTML）
□ 密码字段 type="password"
□ autocomplete 属性
  - email: email
  - password: current-password / new-password
  - 信用卡: cc-number / cc-exp / cc-csc
□ HTTPS 提交
□ CSRF Token（如用 Cookie）
□ 不在 URL 提交敏感信息
```

---

## 9. 测试

```text
□ 必填字段空值
□ 字段格式错误
□ 字段长度边界
□ 跨字段校验
□ 异步校验
□ 提交成功
□ 提交失败（业务错误）
□ 提交失败（系统错误）
□ 防重复提交
□ 键盘提交（Enter）
□ 焦点管理
□ 屏幕阅读器
```

---

## 10. 自检

```text
□ Schema-first
□ 类型派生
□ 校验时机合理
□ 错误信息友好
□ 防重复提交
□ 后端校验兜底
□ a11y 完整
□ 移动端优化
□ 草稿保存（长表单）
□ 测试覆盖
□ 安全合规
```
