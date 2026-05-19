---
name: miniprogram-development
description: 小程序开发时使用。覆盖微信/支付宝/抖音小程序 + Taro/uni-app 多端统一开发。
---

# 小程序开发（Miniprogram Development）

## 适用场景

- 微信小程序开发（原生 / Taro / uni-app）
- 支付宝小程序 / 抖音小程序 / 百度小程序
- 多端统一开发（一套代码多端发布）
- 小程序性能优化
- 小程序与 H5 互通

### 与其他 skill 的分工

| 场景 | 用什么 |
|------|--------|
| 小程序页面/组件/多端 | **本 skill** |
| Web 页面（纯浏览器） | `component-architecture/` |
| APP 原生（React Native/Flutter） | `mobile-hybrid/` |
| 状态管理通用方法 | `state-management/` |
| API 调用/缓存 | `data-fetching/` |

---

## 技术栈选型

```text
┌─ 小程序框架决策树 ─────────────────────────────────────────┐
│                                                             │
│  Q1: 只做微信小程序？                                       │
│    是 → 微信原生（最佳性能 + 最新 API）                      │
│    否 → Q2                                                  │
│                                                             │
│  Q2: 团队技术栈？                                           │
│    React → Taro 3（京东出品，React/Vue 均支持）             │
│    Vue → uni-app（DCloud，Vue 生态 + 最多端）              │
│    都行 → Taro（社区更活跃） 或 uni-app（端更多）          │
│                                                             │
│  Q3: 需要同时出 APP？                                       │
│    是 → uni-app（支持编译到 APP）                           │
│    否 → Taro（小程序 + H5 足够）                           │
└─────────────────────────────────────────────────────────────┘
```

### 框架对比

| 框架 | 语法 | 多端覆盖 | 性能 | 生态 | 适合 |
|------|------|---------|------|------|------|
| **微信原生** | WXML+WXSS+JS | 仅微信 | 最佳 | 微信组件 | 只做微信且性能敏感 |
| **Taro 3** | React/Vue | 微信/支付宝/抖音/H5/RN | 良好 | 京东+社区 | React 团队多端 |
| **uni-app** | Vue 2/3 | 微信/支付宝/抖音/百度/H5/APP | 良好 | DCloud | Vue 团队 + 需要 APP |
| **Remax** | React | 多端 | 良好 | 蚂蚁 | React 纯粹 |

---

## 项目结构（Taro）

```text
src/
├── app.config.ts          # 全局配置（pages/tabBar/window）
├── app.ts                 # 入口
├── pages/
│   ├── index/
│   │   ├── index.tsx      # 页面组件
│   │   ├── index.config.ts # 页面配置
│   │   └── index.module.scss
│   └── user/
│       └── ...
├── components/            # 通用组件
├── services/              # API 调用
├── stores/                # 状态管理
├── utils/                 # 工具函数
└── assets/                # 静态资源
```

## 核心开发模式

### 页面生命周期

```typescript
// Taro React 页面
import { useDidShow, useDidHide, useShareAppMessage } from '@tarojs/taro';

function IndexPage() {
  // 页面显示（每次切回来都触发）
  useDidShow(() => { console.log('页面显示'); });
  
  // 页面隐藏
  useDidHide(() => { console.log('页面隐藏'); });
  
  // 分享
  useShareAppMessage(() => ({
    title: '分享标题',
    path: '/pages/index/index',
    imageUrl: 'share.png',
  }));
  
  return <View>...</View>;
}
```

### 网络请求封装

```typescript
// services/request.ts
import Taro from '@tarojs/taro';

const BASE_URL = process.env.TARO_APP_API_URL;

export async function request<T>(options: {
  url: string;
  method?: 'GET' | 'POST' | 'PUT' | 'DELETE';
  data?: any;
  needAuth?: boolean;
}): Promise<T> {
  const { url, method = 'GET', data, needAuth = true } = options;
  
  const header: Record<string, string> = {
    'Content-Type': 'application/json',
  };
  
  if (needAuth) {
    const token = Taro.getStorageSync('token');
    if (token) header['Authorization'] = `Bearer ${token}`;
  }
  
  const res = await Taro.request({
    url: `${BASE_URL}${url}`,
    method,
    data,
    header,
    timeout: 10000,
  });
  
  if (res.statusCode === 401) {
    // Token 过期 → 跳登录
    Taro.navigateTo({ url: '/pages/login/index' });
    throw new Error('未授权');
  }
  
  if (res.statusCode >= 400) {
    throw new Error(res.data?.message || '请求失败');
  }
  
  return res.data as T;
}
```

### 登录流程（微信）

```typescript
// 微信小程序登录标准流程
import Taro from '@tarojs/taro';

export async function wxLogin(): Promise<string> {
  // 1. 获取临时 code
  const { code } = await Taro.login();
  
  // 2. 发送 code 到后端换 token
  const { token } = await request<{ token: string }>({
    url: '/auth/wx-login',
    method: 'POST',
    data: { code },
    needAuth: false,
  });
  
  // 3. 存储 token
  Taro.setStorageSync('token', token);
  return token;
}

// 获取用户信息（需要用户授权按钮触发）
export async function getUserProfile() {
  const { userInfo } = await Taro.getUserProfile({
    desc: '用于完善个人资料',
  });
  return userInfo;
}
```

---

## 性能优化

```text
首屏优化：
  □ 分包加载（subPackages，主包 < 2MB）
  □ 预加载分包（preloadRule）
  □ 骨架屏（首屏数据未到时展示）
  □ 数据预拉取（prefetchData）
  □ 图片懒加载（lazy-load）

渲染优化：
  □ 长列表虚拟化（RecycleView / VirtualList）
  □ setData 数据量最小化（diff 更新）
  □ 避免频繁 setData（合并更新）
  □ WXS / wxs 处理响应式交互（不过桥）

包大小优化：
  □ 主包 ≤ 2MB（超了必须分包）
  □ 总包 ≤ 20MB
  □ 图片用 CDN（不放本地）
  □ 按需引入组件库
  □ Tree-shaking 无用代码
```

---

## 组件库选型

| 组件库 | 适配框架 | Stars | 适合 |
|--------|---------|-------|------|
| **Vant Weapp** | 原生/uni-app | 18K+ | 移动端风格（有赞） |
| **NutUI** | Taro | 6K+ | 京东风格 |
| **TDesign 小程序** | 原生 | 4K+ | 腾讯风格 |
| **Arco Design Mobile** | Taro | - | 字节风格 |
| **uni-ui** | uni-app | - | DCloud 官方 |
| **WeUI** | 原生 | 27K+ | 微信官方基础 |

---

## 常见坑

```text
1. 主包超 2MB → 必须分包，图片上 CDN
2. setData 数据太大 → 页面卡顿（单次 < 256KB）
3. 不处理授权拒绝 → 用户拒绝后功能卡死
4. wx.navigateTo 层级超 10 → 用 redirectTo 或 reLaunch
5. 不做登录态检查 → Token 过期后白屏
6. 不适配 iOS 安全区 → 底部被遮挡
7. 不测试真机 → 模拟器正常真机崩溃
8. 不处理网络异常 → 断网无提示
9. 小程序审核被拒 → 提前看审核规范
10. 不做版本兼容 → 低版本基础库报错
```

---

## 配套模板

- `templates/miniprogram-template.md`

## 与其他 skill 的协作

```text
上游：
  ui-ux-designer → 小程序设计稿（注意平台规范差异）
  api-designer → API 契约

下游：
  testing-frontend → 小程序自动化测试（Miniprogram Automator）
  build-deploy → 小程序 CI（miniprogram-ci）
```
