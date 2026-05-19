# DevOps 工程师工作流常见坑

## 1. 密钥进代码 / 日志

- 表现：.env 提交到 Git，CI 日志输出 Token。
- 风险：密钥泄露 = 安全事故。
- 避免：用 Vault / Secrets Manager，CI 用 masked variables。

## 2. 没有健康检查

- 表现：K8s 不知道 Pod 是否正常。
- 风险：流量打到挂掉的 Pod。
- 避免：配置 liveness + readiness probe。

## 3. latest 标签部署生产

- 表现：`image: my-app:latest`。
- 风险：不知道当前跑的是哪个版本，无法回滚。
- 避免：用 git sha / semver 标签。

## 4. root 运行容器

- 表现：Dockerfile 没有 USER 指令。
- 风险：容器逃逸时获得宿主机 root。
- 避免：`USER nonroot` + 最小权限。

## 5. 没有资源限制

- 表现：K8s Pod 没有 requests / limits。
- 风险：一个 Pod OOM 杀死邻居。
- 避免：必须设置 CPU / Memory limits。

## 6. 手动部署

- 表现：SSH 到服务器手动 pull + restart。
- 风险：不可重复、不可追溯、容易出错。
- 避免：CI/CD 自动化，所有部署通过流水线。

## 7. 没有回滚方案

- 表现：部署出问题不知道怎么回退。
- 风险：故障持续时间长。
- 避免：每次部署前确认回滚方式（< 5 min）。

## 8. 跳过 staging

- 表现：代码直接部署到生产。
- 风险：生产才发现问题。
- 避免：dev → staging → prod 三环境。

## 9. CI 太慢

- 表现：CI 跑 30 分钟+。
- 风险：开发不愿跑 CI，跳过检查。
- 避免：并行化 + 缓存 + 分层测试。

## 10. 告警太多（Alert Fatigue）

- 表现：每天 100+ 告警，大部分无意义。
- 风险：真正重要的告警被忽略。
- 避免：告警基于 SLO，不基于阈值；分级处理。

## 11. 不监控就上线

- 表现：服务上线没有 Prometheus / Grafana。
- 风险：出问题才知道。
- 避免：监控是上线前置条件。

## 12. DNS TTL 太长

- 表现：DNS 缓存 24 小时。
- 风险：切换 / 灾备时等待时间长。
- 避免：生产 DNS TTL 设 60~300 秒。

## 13. SSL 证书过期

- 表现：没有自动续期。
- 风险：服务不可用。
- 避免：Let's Encrypt + 自动续期 + 过期告警。

## 14. 镜像太大

- 表现：镜像 > 1GB。
- 风险：部署慢、拉取慢、存储贵。
- 避免：多阶段构建 + Alpine / Distroless。

## 15. 不扫描镜像

- 表现：镜像含已知漏洞。
- 风险：漏洞进生产。
- 避免：CI 集成 Trivy / Snyk 扫描。
