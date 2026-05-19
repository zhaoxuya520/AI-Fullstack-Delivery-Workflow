# 认证端到端清单

## DB 层
□ users 表（email, password_hash, role, created_at）
□ refresh_tokens 表（token, user_id, expires_at）
□ email 唯一约束

## 后端层
□ POST /auth/register
□ POST /auth/login
□ POST /auth/refresh
□ POST /auth/logout
□ 密码 bcrypt(12) / argon2
□ JWT 15 min 过期
□ Refresh Token 7 天
□ 中间件校验
□ 角色检查
□ 资源归属检查

## 前端层
□ 登录表单 + 校验
□ 注册表单
□ Token 存储（Cookie）
□ 路由守卫
□ 自动刷新 Token
□ 登出清理

## 联调
□ Token 传递正确
□ 401 → 刷新 → 重试
□ 403 → 提示无权限
□ 登录失败 → 友好提示

## 测试
□ 注册成功
□ 登录成功
□ 登录失败（密码错）
□ Token 过期 → 刷新
□ 越权访问 → 403/404
□ 跨用户访问 → 拒绝
