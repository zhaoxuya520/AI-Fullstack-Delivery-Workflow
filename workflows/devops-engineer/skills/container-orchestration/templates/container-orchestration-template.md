# 容器编排方案模板

## 基本信息

- 服务名：
- 语言/框架：
- 端口：
- 依赖服务：DB / Redis / MQ

## Dockerfile 要求

- [ ] 多阶段构建
- [ ] Alpine/Slim 基础镜像
- [ ] 非 root 用户
- [ ] HEALTHCHECK
- [ ] .dockerignore 完善

## 部署方式

- [ ] Docker Compose（开发/小项目）
- [ ] Kubernetes（生产）
- [ ] Serverless 容器（Cloud Run / Fargate）

## 资源需求

| 环境 | CPU Request | CPU Limit | Memory Request | Memory Limit | Replicas |
|------|-------------|-----------|----------------|--------------|----------|
| dev | 100m | 500m | 128Mi | 256Mi | 1 |
| prod | 200m | 1000m | 256Mi | 512Mi | 2~5 |
