---
name: containerization
description: Docker 多阶段构建、镜像优化、Distroless 基础镜像、安全扫描（Trivy）、Docker Compose 编排。适用于应用容器化、镜像瘦身、供应链安全加固场景。
---

# 容器化（Containerization）

参考来源：Docker 官方文档、Google Distroless 项目、Trivy 文档、CNCF 容器安全白皮书、Chainguard Images。

## 适用场景

- 应用首次容器化（从裸机 / VM 迁移）
- 镜像体积优化（>500MB 需瘦身）
- 多阶段构建设计
- 安全基线加固（CVE 扫描、非 root 运行）
- 本地开发环境编排（Docker Compose）
- CI 中的镜像构建与推送
- 多架构镜像（linux/amd64 + linux/arm64）

## 核心原则

```text
1. 最小化攻击面
   使用 Distroless / Alpine / scratch
   不安装调试工具到生产镜像

2. 多阶段构建
   编译阶段 → 运行阶段
   只复制产物，不复制源码

3. 层缓存优先
   依赖安装在前，源码复制在后
   利用 BuildKit 缓存挂载

4. 非 root 运行
   USER 指令指定非特权用户
   文件权限最小化

5. 可复现构建
   锁定基础镜像 digest
   锁定依赖版本

6. 扫描前置
   CI 中构建后立即扫描
   阻断 HIGH/CRITICAL 漏洞

7. 标签规范
   语义化版本 + git SHA
   不依赖 :latest
```

## 工作流程

```text
1. 分析应用依赖
   - 运行时需要哪些系统库
   - 编译时需要哪些工具链
   - 区分 devDependencies vs dependencies

2. 选择基础镜像
   - 编译阶段：官方 SDK 镜像（node:20, golang:1.22, python:3.12）
   - 运行阶段：distroless / alpine / scratch
   - 锁定 digest（sha256:xxx）

3. 编写多阶段 Dockerfile
   - Stage 1: 安装依赖
   - Stage 2: 编译 / 构建
   - Stage 3: 仅复制产物到最小运行时

4. 优化层缓存
   - COPY package.json → RUN npm ci → COPY src/
   - 使用 --mount=type=cache 加速

5. 安全加固
   - 添加 .dockerignore
   - USER nonroot
   - HEALTHCHECK 指令
   - 不暴露不必要端口

6. 本地验证
   - docker build --target=production
   - docker compose up（集成测试）
   - dive 分析层

7. 安全扫描
   - trivy image <image>:<tag>
   - 阻断 HIGH/CRITICAL
   - 生成 SBOM

8. 推送与签名
   - docker push → registry
   - cosign sign（可选）
   - 记录 digest
```

## 镜像优化策略

| 策略 | 效果 | 适用场景 |
|---|---|---|
| 多阶段构建 | 减少 50-90% | 所有项目 |
| Distroless | 减少 70%+ | Go / Java / Node |
| Alpine 基础 | 减少 60% | 需要 shell 调试 |
| .dockerignore | 减少构建上下文 | 所有项目 |
| --mount=type=cache | 加速构建 | 依赖多的项目 |
| 合并 RUN 指令 | 减少层数 | 多 apt-get 场景 |
| scratch | 最小（<10MB） | 静态编译 Go |

## Docker Compose 编排

```yaml
# docker-compose.yml 结构
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
      target: production
    ports:
      - "3000:3000"
    environment:
      - DATABASE_URL=postgres://db:5432/app
    depends_on:
      db:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 10s
      timeout: 5s
      retries: 3

  db:
    image: postgres:16-alpine
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]

volumes:
  pgdata:
```

## 质量自检

```text
□ 使用多阶段构建
□ 运行阶段基于 Distroless / Alpine / scratch
□ 基础镜像锁定 digest 或具体版本
□ 非 root 用户运行
□ .dockerignore 排除无关文件
□ 依赖安装层在源码复制层之前（缓存友好）
□ 无 secrets 硬编码在镜像中
□ HEALTHCHECK 已配置
□ Trivy 扫描无 HIGH/CRITICAL
□ 镜像大小合理（<200MB 应用层）
□ 多架构构建（如需）
□ docker compose 可一键启动本地环境
□ 标签使用语义化版本 + SHA
```

## 常见坑

1. **:latest 标签**——不可复现，生产回滚困难
2. **单阶段构建**——镜像含编译工具链，体积 1GB+
3. **root 运行**——容器逃逸后直接 root 权限
4. **COPY . .**——把 .git / node_modules / .env 打入镜像
5. **不锁定基础镜像**——上游更新导致构建失败
6. **RUN apt-get 不清理**——每层残留缓存
7. **secrets 写入 ENV**——docker inspect 可见
8. **不用 .dockerignore**——构建上下文 GB 级
9. **HEALTHCHECK 缺失**——编排器无法判断就绪
10. **层顺序错误**——改一行代码重装所有依赖
11. **不扫描就推送**——带 CVE 上生产
12. **compose 硬编码端口**——团队冲突

## 配套模板

- `templates/dockerfile-template.md` — 多阶段 Dockerfile + .dockerignore + Compose 模板

## 与其他 skill 的协作

```text
上游：
  backend-engineer → 应用代码 + 依赖清单
  frontend-engineer → 静态产物构建

下游：
  ci-cd-pipeline → 镜像构建阶段
  kubernetes-orchestration → 镜像部署
  secrets-config → 运行时 secrets 注入
  monitoring-alerting → 健康检查端点
```
