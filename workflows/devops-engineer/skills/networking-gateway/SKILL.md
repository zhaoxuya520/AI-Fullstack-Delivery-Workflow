---
name: networking-gateway
description: 网络网关与流量管理，覆盖 Nginx / Traefik / API Gateway。DNS 管理、SSL/TLS 证书、CDN 配置、负载均衡策略、流量路由。
---

# 网络与网关（Networking & Gateway）

参考来源：Nginx 官方文档、Traefik 文档、AWS ALB/NLB 文档、Cloudflare 文档、Let's Encrypt / cert-manager 文档。

## 适用场景

- 反向代理与负载均衡配置
- API Gateway 设计（路由 / 限流 / 认证）
- SSL/TLS 证书管理（自动续期）
- DNS 记录管理与切换
- CDN 配置与缓存策略
- 多服务流量路由（路径 / 域名）
- WebSocket / gRPC 代理
- DDoS 防护与 WAF

## 核心原则

```text
1. TLS Everywhere
   所有外部流量 HTTPS
   内部服务间 mTLS（Service Mesh）
   HSTS 强制

2. 最小暴露
   只暴露必要端口
   内部服务不直接对外
   安全组 / NetworkPolicy 限制

3. 高可用
   负载均衡多实例
   健康检查剔除故障节点
   DNS 多记录 / Failover

4. 缓存分层
   CDN → 反向代理 → 应用
   静态资源长缓存 + 版本化
   API 按需缓存

5. 限流保护
   全局限流 + 按 IP / 用户
   突发容忍 + 平滑限流
   429 返回 Retry-After

6. 可观测
   访问日志结构化
   延迟 / 错误率 / 流量指标
   实时流量可视化

7. 零停机变更
   配置热加载
   DNS 切换 TTL 提前降低
   蓝绿 / 金丝雀流量切分
```

## 工作流程

```text
1. 网络架构设计
   - 外部流量入口（CDN → LB → Gateway）
   - 内部服务通信（Service Mesh / 直连）
   - 网络分段（公有 / 私有子网）

2. DNS 配置
   - 域名注册与托管
   - A / CNAME / ALIAS 记录
   - TTL 策略（正常 300s，切换前降至 60s）

3. SSL/TLS 证书
   - cert-manager 自动签发（Let's Encrypt）
   - 通配符证书（*.example.com）
   - 证书到期监控

4. 反向代理 / 网关
   - 路由规则（路径 / 域名 / Header）
   - 上游健康检查
   - 超时与重试配置
   - WebSocket / gRPC 支持

5. 负载均衡
   - 算法选择（Round Robin / Least Conn / IP Hash）
   - 会话保持（如需）
   - 跨 AZ 分布

6. 安全加固
   - WAF 规则（OWASP Top 10）
   - Rate Limiting
   - IP 白名单 / 黑名单
   - Bot 检测

7. CDN 配置
   - 静态资源缓存规则
   - 动态内容 bypass
   - 缓存失效策略（purge）

8. 监控与告警
   - 4xx / 5xx 错误率
   - P50 / P95 / P99 延迟
   - 带宽与连接数
```

## 技术选型

| 方案 | 适用场景 | 优势 | 劣势 |
|---|---|---|---|
| Nginx | 通用反向代理 | 性能高、生态成熟 | 配置复杂 |
| Traefik | K8s / Docker 原生 | 自动发现、热加载 | 高并发略逊 |
| AWS ALB | AWS 云原生 | 托管免运维 | 锁定云厂商 |
| Cloudflare | CDN + WAF + DNS | 全球节点、DDoS 防护 | 依赖第三方 |
| Kong | API Gateway | 插件丰富 | 运维复杂 |
| Envoy | Service Mesh | L7 能力强 | 学习曲线高 |

## Nginx 核心配置模式

```nginx
# 反向代理 + 负载均衡
upstream backend {
    least_conn;
    server app1:3000 weight=3;
    server app2:3000 weight=1;
    keepalive 32;
}

server {
    listen 443 ssl http2;
    server_name api.example.com;

    ssl_certificate     /etc/ssl/cert.pem;
    ssl_certificate_key /etc/ssl/key.pem;

    # 安全头
    add_header Strict-Transport-Security "max-age=31536000" always;
    add_header X-Content-Type-Options nosniff;

    # 限流
    limit_req zone=api burst=20 nodelay;

    location / {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_connect_timeout 5s;
        proxy_read_timeout 30s;
    }
}
```

## 质量自检

```text
□ 所有外部流量走 HTTPS
□ HSTS 已启用
□ SSL 证书自动续期
□ 健康检查已配置（剔除故障节点）
□ Rate Limiting 已配置
□ 安全头已添加（HSTS / X-Content-Type / X-Frame）
□ 访问日志结构化输出
□ 超时合理设置（connect / read / write）
□ CDN 缓存规则正确（静态长缓存、API 不缓存）
□ DNS TTL 合理
□ WebSocket / gRPC 代理正确（如需）
□ 负载均衡算法合适
□ 跨 AZ / 多节点部署
□ WAF 规则已启用
```

## 常见坑

1. **不配 HSTS**——中间人降级攻击
2. **证书过期**——全站不可用
3. **超时太长**——慢请求拖垮连接池
4. **不限流**——单用户打爆服务
5. **CDN 缓存 API 响应**——数据不一致
6. **DNS TTL 太长**——切换生效慢
7. **不转发真实 IP**——日志全是 LB 地址
8. **WebSocket 无 upgrade**——连接失败
9. **HTTP → HTTPS 不重定向**——混合内容
10. **负载均衡无健康检查**——流量打到故障节点
11. **通配符证书不续期**——子域名全挂
12. **Nginx reload 不测试**——配置错误导致宕机

## 配套模板

- `templates/nginx-config-template.md` — Nginx 反向代理 + SSL + 限流完整配置模板

## 与其他 skill 的协作

```text
上游：
  infrastructure-as-code → VPC / 子网 / LB 基础设施
  kubernetes-orchestration → Ingress Controller

下游：
  release-strategy → 流量切分（金丝雀 / 蓝绿）
  monitoring-alerting → 网关指标采集
  secrets-config → SSL 证书 / API Key 管理
  ci-cd-pipeline → DNS 切换自动化
```
