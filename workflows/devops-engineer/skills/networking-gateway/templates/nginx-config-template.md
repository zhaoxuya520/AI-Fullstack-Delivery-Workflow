---
name: nginx-config-template
description: Nginx 反向代理 + SSL/TLS + 限流 + 安全头完整配置模板
---

# Nginx 配置模板

## 主配置（nginx.conf）

```nginx
worker_processes auto;
worker_rlimit_nofile 65535;

events {
    worker_connections 4096;
    multi_accept on;
}

http {
    # ─── 基础设置 ───
    sendfile on;
    tcp_nopush on;
    keepalive_timeout 65;
    client_max_body_size 10m;

    # ─── 日志格式（JSON） ───
    log_format json_combined escape=json '{'
        '"time":"$time_iso8601",'
        '"remote_addr":"$remote_addr",'
        '"method":"$request_method",'
        '"uri":"$request_uri",'
        '"status":$status,'
        '"body_bytes_sent":$body_bytes_sent,'
        '"request_time":$request_time,'
        '"upstream_response_time":"$upstream_response_time",'
        '"user_agent":"$http_user_agent"'
    '}';
    access_log /var/log/nginx/access.log json_combined;

    # ─── 限流区域 ───
    limit_req_zone $binary_remote_addr zone=general:10m rate=10r/s;
    limit_req_zone $binary_remote_addr zone=api:10m rate=30r/s;

    # ─── 上游服务 ───
    upstream app_backend {
        least_conn;
        server app-1:3000;
        server app-2:3000;
        keepalive 32;
    }

    # ─── HTTPS 重定向 ───
    server {
        listen 80;
        server_name _;
        return 301 https://$host$request_uri;
    }

    # ─── 主站点 ───
    server {
        listen 443 ssl http2;
        server_name api.example.com;

        ssl_certificate     /etc/ssl/certs/fullchain.pem;
        ssl_certificate_key /etc/ssl/private/privkey.pem;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_prefer_server_ciphers on;

        # ─── 安全头 ───
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
        add_header X-Content-Type-Options nosniff always;
        add_header X-Frame-Options DENY always;

        # ─── API 路由 ───
        location /api/ {
            limit_req zone=api burst=50 nodelay;
            proxy_pass http://app_backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_connect_timeout 5s;
            proxy_read_timeout 30s;
        }

        # ─── 健康检查 ───
        location /health {
            access_log off;
            proxy_pass http://app_backend/health;
        }
    }
}
```
