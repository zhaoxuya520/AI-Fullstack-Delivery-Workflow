---
name: forms-validation
description: 实现表单 / 校验 / 提交 / 错误处理时使用。覆盖 React Hook Form + Zod / TanStack Form / Formik / VeeValidate / Formily / Angular Forms。融合受控/非受控 + Schema 校验 + 异步校验 + 防重复提交。
---

# 表单与校验（Forms & Validation）

参考来源：React Hook Form 官方、Zod 官方、VeeValidate 官方、Form Design Patterns（Adam Silver）。

## 适用场景

- 各种表单（登录 / 注册 / 配置 / 创建 / 编辑）
- 复杂校验（依赖字段 / 异步 / 后端校验）
- 多步表单（向导）
- 动态字段（数组 / 嵌套）
- 文件上传
- 草稿保存

## 核心原则

```text
1. Schema-first
   定义 Zod / Yup schema → 自动生成类型 + 校验

2. 表单库性能优于 useState
   useState 表单 → 每字段输入全表单重渲染
   RHF / VeeValidate → 局部更新

3. 校验时机
   - onChange：实时（性能差）
   - onBlur：失焦（推荐）
   - onSubmit：提交时

4. 错误信息友好
   不写"VALIDATION_FAILED"，写"邮箱格式不正确"

5. 防重复提交
   isSubmitting 期间禁用按钮
   或：去重 / 幂等键

6. 后端校验是兜底
   前端校验只是体验，必须后端再校验

7. 字段级 vs 表单级错误
   字段级：邮箱格式
   表单级：服务器返回的"用户名已存在"
```

## React Hook Form + Zod（推荐）

### 基础表单

```typescript
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';

const formSchema = z.object({
  email: z.string().email('请输入有效邮箱'),
  password: z.string().min(8, '密码至少 8 个字符').max(64, '密码不超过 64 个字符'),
  remember: z.boolean().optional(),
});

type FormData = z.infer<typeof formSchema>;

function LoginForm() {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting, isValid },
    setError,
  } = useForm<FormData>({
    resolver: zodResolver(formSchema),
    mode: 'onBlur',  // 失焦校验
    defaultValues: { email: '', password: '', remember: false },
  });
  
  const onSubmit = async (data: FormData) => {
    try {
      await api.login(data);
      navigate('/dashboard');
    } catch (err) {
      if (err.code === 'INVALID_CREDENTIALS') {
        setError('root', { message: '邮箱或密码错误' });
      } else {
        setError('root', { message: '登录失败，请稍后重试' });
      }
    }
  };
  
  return (
    <form onSubmit={handleSubmit(onSubmit)} noValidate>
      <div>
        <label htmlFor="email">邮箱</label>
        <input id="email" type="email" {...register('email')} aria-invalid={!!errors.email} />
        {errors.email && <p role="alert">{errors.email.message}</p>}
      </div>
      
      <div>
        <label htmlFor="password">密码</label>
        <input id="password" type="password" {...register('password')} aria-invalid={!!errors.password} />
        {errors.password && <p role="alert">{errors.password.message}</p>}
      </div>
      
      <label>
        <input type="checkbox" {...register('remember')} />
        记住我
      </label>
      
      {errors.root && <p role="alert">{errors.root.message}</p>}
      
      <button type="submit" disabled={isSubmitting || !isValid}>
        {isSubmitting ? '登录中...' : '登录'}
      </button>
    </form>
  );
}
```

### 复杂校验（依赖 / 异步）

```typescript
const registerSchema = z.object({
  username: z.string().min(3).max(20),
  email: z.string().email(),
  password: z.string().min(8),
  confirmPassword: z.string(),
})
.refine((data) => data.password === data.confirmPassword, {
  message: '密码不一致',
  path: ['confirmPassword'],
})
.refine(
  async (data) => {
    const res = await api.checkUsernameAvailable(data.username);
    return res.available;
  },
  {
    message: '用户名已被占用',
    path: ['username'],
  }
);
```

### 动态字段（数组）

```typescript
import { useFieldArray } from 'react-hook-form';

const orderSchema = z.object({
  customer: z.string().min(1),
  items: z.array(
    z.object({
      productId: z.number().int().positive(),
      quantity: z.number().int().positive().max(100),
    })
  ).min(1, '至少 1 个商品'),
});

function OrderForm() {
  const { control, register, handleSubmit, formState: { errors } } = useForm({
    resolver: zodResolver(orderSchema),
    defaultValues: { customer: '', items: [{ productId: 0, quantity: 1 }] },
  });
  
  const { fields, append, remove } = useFieldArray({ control, name: 'items' });
  
  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('customer')} />
      
      {fields.map((field, index) => (
        <div key={field.id}>
          <input type="number" {...register(`items.${index}.productId`)} />
          <input type="number" {...register(`items.${index}.quantity`)} />
          <button type="button" onClick={() => remove(index)}>删除</button>
        </div>
      ))}
      
      <button type="button" onClick={() => append({ productId: 0, quantity: 1 })}>
        添加商品
      </button>
      
      <button type="submit">提交</button>
    </form>
  );
}
```

### 多步表单

```typescript
function MultiStepForm() {
  const [step, setStep] = useState(0);
  const methods = useForm<FullFormData>({ resolver: zodResolver(fullSchema) });
  
  const stepSchemas = [stepOneSchema, stepTwoSchema, stepThreeSchema];
  
  const next = async () => {
    const valid = await methods.trigger(stepFields[step]);  // 仅校验当前步
    if (valid) setStep(s => s + 1);
  };
  
  return (
    <FormProvider {...methods}>
      <form onSubmit={methods.handleSubmit(onSubmit)}>
        {step === 0 && <StepOne />}
        {step === 1 && <StepTwo />}
        {step === 2 && <StepThree />}
        
        <div>
          {step > 0 && <button onClick={() => setStep(s => s - 1)}>上一步</button>}
          {step < 2 && <button type="button" onClick={next}>下一步</button>}
          {step === 2 && <button type="submit">提交</button>}
        </div>
      </form>
    </FormProvider>
  );
}
```

### 文件上传

```typescript
const fileSchema = z.object({
  avatar: z.instanceof(FileList)
    .refine(files => files.length > 0, '请选择文件')
    .refine(files => files[0]?.size <= 5 * 1024 * 1024, '文件不超过 5MB')
    .refine(files => ['image/jpeg', 'image/png'].includes(files[0]?.type), '仅支持 JPG/PNG'),
});

function UploadForm() {
  const { register, handleSubmit, watch } = useForm({ resolver: zodResolver(fileSchema) });
  const file = watch('avatar')?.[0];
  
  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input type="file" accept="image/*" {...register('avatar')} />
      {file && <img src={URL.createObjectURL(file)} alt="预览" />}
      <button type="submit">上传</button>
    </form>
  );
}
```

## TanStack Form（新一代，类型极致）

```typescript
import { useForm } from '@tanstack/react-form';

function MyForm() {
  const form = useForm({
    defaultValues: { email: '', password: '' },
    onSubmit: async ({ value }) => {
      await api.login(value);
    },
    validators: {
      onChange: ({ value }) => formSchema.safeParse(value).error,
    },
  });
  
  return (
    <form onSubmit={(e) => { e.preventDefault(); form.handleSubmit(); }}>
      <form.Field
        name="email"
        validators={{
          onBlur: z.string().email('请输入邮箱'),
        }}
        children={(field) => (
          <>
            <input
              value={field.state.value}
              onChange={(e) => field.handleChange(e.target.value)}
              onBlur={field.handleBlur}
            />
            {field.state.meta.errors.length > 0 && <span>{field.state.meta.errors[0]}</span>}
          </>
        )}
      />
    </form>
  );
}
```

## Vue 3 + VeeValidate

```vue
<script setup lang="ts">
import { useForm } from 'vee-validate';
import { toTypedSchema } from '@vee-validate/zod';
import { z } from 'zod';

const schema = toTypedSchema(z.object({
  email: z.string().email('请输入邮箱'),
  password: z.string().min(8, '密码至少 8 个字符'),
}));

const { defineField, handleSubmit, errors, isSubmitting } = useForm({
  validationSchema: schema,
});

const [email, emailAttrs] = defineField('email');
const [password, passwordAttrs] = defineField('password');

const onSubmit = handleSubmit(async (values) => {
  await api.login(values);
});
</script>

<template>
  <form @submit="onSubmit" novalidate>
    <input v-model="email" v-bind="emailAttrs" type="email" />
    <p v-if="errors.email">{{ errors.email }}</p>
    
    <input v-model="password" v-bind="passwordAttrs" type="password" />
    <p v-if="errors.password">{{ errors.password }}</p>
    
    <button :disabled="isSubmitting">登录</button>
  </form>
</template>
```

## Vue 3 + Formily（企业级，复杂表单）

```typescript
// 适合：动态表单、JSON Schema 驱动、可视化表单设计器
import { createForm } from '@formily/core';
import { FormProvider, FormItem, Input, Submit } from '@formily/antdv';

const form = createForm();

const schema = {
  type: 'object',
  properties: {
    email: {
      type: 'string',
      title: '邮箱',
      required: true,
      'x-validator': [{ format: 'email' }],
      'x-component': 'Input',
    },
  },
};
```

## Angular Reactive Forms

```typescript
@Component({
  selector: 'app-login',
  imports: [ReactiveFormsModule],
  template: `
    <form [formGroup]="form" (ngSubmit)="onSubmit()">
      <input formControlName="email" type="email" />
      @if (form.get('email')?.errors?.['email']) {
        <p>请输入邮箱</p>
      }
      
      <input formControlName="password" type="password" />
      <button [disabled]="form.invalid || submitting()">登录</button>
    </form>
  `,
})
export class LoginComponent {
  fb = inject(FormBuilder);
  submitting = signal(false);
  
  form = this.fb.group({
    email: ['', [Validators.required, Validators.email]],
    password: ['', [Validators.required, Validators.minLength(8)]],
  });
  
  async onSubmit() {
    if (this.form.invalid) return;
    this.submitting.set(true);
    try {
      await this.authService.login(this.form.value);
    } finally {
      this.submitting.set(false);
    }
  }
}
```

## SvelteKit Form Actions

```svelte
<!-- routes/login/+page.svelte -->
<script lang="ts">
  import { enhance } from '$app/forms';
  
  let { form } = $props();
</script>

<form method="POST" use:enhance>
  <input name="email" type="email" required />
  {#if form?.errors?.email}<p>{form.errors.email}</p>{/if}
  
  <input name="password" type="password" required />
  
  <button>登录</button>
</form>

<!-- routes/login/+page.server.ts -->
<script lang="ts">
  import { fail, redirect } from '@sveltejs/kit';
  import { z } from 'zod';
  
  const schema = z.object({
    email: z.string().email(),
    password: z.string().min(8),
  });
  
  export const actions = {
    default: async ({ request }) => {
      const formData = Object.fromEntries(await request.formData());
      const result = schema.safeParse(formData);
      
      if (!result.success) {
        return fail(400, { errors: result.error.flatten().fieldErrors });
      }
      
      try {
        await login(result.data);
      } catch {
        return fail(401, { message: '邮箱或密码错误' });
      }
      
      throw redirect(303, '/dashboard');
    },
  };
</script>
```

## Schema 库对比

| 库 | 大小 | TS | 性能 | 推荐 |
|---|---|---|---|---|
| **Zod** | 11KB | 强 | 中 | ⭐⭐⭐⭐⭐ |
| **Yup** | 28KB | 中 | 中 | ⭐⭐⭐ |
| **Valibot** | 1KB | 强 | 高 | ⭐⭐⭐⭐⭐ |
| **Joi** | 145KB | 弱 | 中 | ⭐⭐ |
| **ArkType** | - | 极强 | 高 | ⭐⭐⭐⭐ |

## 校验时机选择

```text
onChange（每字符）：
  ✅ 适合：密码强度提示、计数
  ❌ 不适合：异步校验（频繁请求）、长表单

onBlur（失焦）：
  ✅ 适合：通用校验、邮箱格式
  ❌ 不适合：实时反馈

onSubmit（提交时）：
  ✅ 适合：简单表单、确认操作
  ❌ 不适合：需要立即反馈

混合（推荐）：
  - 第一次提交后切到 onChange
  - 默认 onBlur
```

## 防重复提交

```typescript
// React Hook Form
const { handleSubmit, formState: { isSubmitting } } = useForm();

// 自动 isSubmitting，按钮 disabled
<button disabled={isSubmitting}>提交</button>

// 自定义 + 节流
const onSubmit = useCallback(
  throttle(async (data) => {
    await api.submit(data);
  }, 1000),
  []
);

// 幂等键（重要操作）
const idempotencyKey = useMemo(() => crypto.randomUUID(), []);
const onSubmit = async (data) => {
  await api.createOrder(data, { headers: { 'Idempotency-Key': idempotencyKey } });
};
```

## 草稿保存

```typescript
// LocalStorage 自动保存
function useDraft<T>(formId: string, watch: () => T) {
  const [restored, setRestored] = useState(false);
  const data = watch();
  
  useEffect(() => {
    const saved = localStorage.getItem(`draft:${formId}`);
    if (saved && !restored) {
      // 用 form.reset(JSON.parse(saved)) 恢复
      setRestored(true);
    }
  }, [formId]);
  
  useEffect(() => {
    if (restored) {
      localStorage.setItem(`draft:${formId}`, JSON.stringify(data));
    }
  }, [data, restored, formId]);
  
  const clearDraft = () => localStorage.removeItem(`draft:${formId}`);
  return { clearDraft };
}
```

## 工作流程

```text
1. 设计表单 schema（Zod）
   - 字段 + 校验规则

2. 选择表单库（RHF / TanStack Form / VeeValidate）

3. 实现表单
   - 受控 vs 非受控
   - 校验时机
   - 错误展示

4. 防重复提交（isSubmitting / 幂等键）

5. 处理提交错误
   - 字段级 vs 表单级
   - 业务错误友好提示

6. 草稿保存（如长表单）

7. 测试
   - 校验规则
   - 提交成功 / 失败
   - 防重复
```

## 配套模板

- `templates/forms-checklist.md` — 表单清单 + 校验规则 + 错误处理 + 测试

## 质量自检

```text
□ Schema-first（Zod / Valibot）
□ 类型自动派生
□ 受控 / 非受控明确
□ 校验时机合理
□ 错误信息友好（用户语言）
□ 防重复提交
□ 异步校验防抖
□ Loading / Error 状态
□ 必填用 *
□ 错误用 aria-invalid
□ 标签关联（label htmlFor）
□ 焦点管理（首个错误聚焦）
□ 键盘可操作
□ 移动端友好（type / inputmode）
□ 草稿保存（如长表单）
□ 后端校验兜底
```

## 常见坑

1. **不防重复提交**——重复创建
2. **错误信息技术化**——"VALIDATION_FAILED" 而非"邮箱格式不正确"
3. **校验只在前端**——直接调 API 仍可绕过
4. **onChange 校验性能差**——大表单卡顿
5. **不用表单库**——useState 表单全表单重渲染
6. **focus 不到首个错误**——长表单用户找不到
7. **type=email 不验证**——浏览器原生不严格
8. **没 noValidate**——浏览器默认 UI 干扰
9. **复选框 / 单选错处理**——RHF 用法不对
10. **文件上传不限制类型 / 大小**——后端被攻击
11. **无草稿保存**——长表单刷新就丢
12. **disabled 按钮无说明**——用户不知道为啥
13. **多步表单不能后退**——体验差
14. **iOS 缩放问题**——input 字体 < 16px

## 与其他 skill 的协作

```text
上游：
  ui-ux-designer 工作流 → 表单设计 / 状态
  api-designer → 字段约束 / 错误码

下游：
  data-fetching → 提交 mutation
  state-management → 表单状态
  accessibility-implementation → ARIA / 焦点
  testing-frontend → 表单测试
```

## 相关参考

- 项目根 `references/frontend-tech-stack-guide.md` — 表单库
