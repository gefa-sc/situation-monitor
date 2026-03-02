# Situation Monitor 部署文档

## 项目概述

- **项目地址**: https://github.com/hipcityreg/situation-monitor
- **项目描述**: Real-time dashboard for monitoring global news, markets, and geopolitical events
- **技术栈**: SvelteKit + Vite + TailwindCSS + D3.js
- **部署日期**: 2026-02-20

## 端口配置

| 服务 | 端口 | 说明 |
|------|------|------|
| situation-monitor | 5174 | Web UI (避免与SocialAI-Manager冲突) |
| socialai-api | 8000 | SocialAI Manager API |
| socialai-postgres | 5432 | PostgreSQL 数据库 |
| socialai-redis | 6379 | Redis 缓存 |

## 部署步骤

### 1. 克隆项目

```bash
cd /home/gefa/.openclaw/workspace
git clone https://github.com/hipcityreg/situation-monitor.git
```

### 2. 安装依赖

```bash
cd situation-monitor
npm install
```

### 3. 构建项目

```bash
npm run build
```

构建产物生成在 `build` 目录。

### 4. 创建 Docker 网络（避免端口冲突）

```bash
docker network create socialai-network
```

### 5. 构建 Docker 镜像

创建 `Dockerfile`:

```dockerfile
FROM nginx:alpine
COPY build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 5174
CMD ["nginx", "-g", "daemon off;"]
```

创建 `nginx.conf`:

```nginx
server {
    listen 5174;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;
    
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

构建镜像:

```bash
docker build -t situation-monitor .
```

### 6. 运行容器

```bash
docker run -d --name situation-monitor -p 5174:5174 --network socialai-network situation-monitor
```

### 7. 验证部署

```bash
# 检查容器状态
docker ps

# 测试访问
curl -I http://localhost:5174
```

## Docker Compose 配置（可选）

```yaml
version: '3.8'

services:
  situation-monitor:
    build: .
    container_name: situation-monitor
    ports:
      - "5174:5174"
    restart: unless-stopped
    networks:
      - socialai-network

networks:
  socialai-network:
    external: true
```

## 常用命令

```bash
# 启动
docker start situation-monitor

# 停止
docker stop situation-monitor

# 重启
docker restart situation-monitor

# 查看日志
docker logs -f situation-monitor

# 删除容器
docker rm -f situation-monitor
```

## 当前运行状态

| 容器名 | 镜像 | 状态 | 端口 |
|--------|------|------|------|
| situation-monitor | situation-monitor | 运行中 | 5174 |
| socialai-api-dev | socialai-manager_api | 运行中 | 8000 |
| socialai-postgres-dev | postgres:15-alpine | 运行中 | 5432 |
| socialai-redis-dev | redis:7-alpine | 运行中 | 6379 |

## 访问地址

- **Situation Monitor**: http://localhost:5174
- **SocialAI API**: http://localhost:8000

## 文件结构

```
situation-monitor/
├── build/                  # 构建产物
├── src/                   # 源代码
├── static/                # 静态资源
├── docs/                  # 本文档
├── Dockerfile             # Docker 镜像配置
├── nginx.conf             # Nginx 配置
├── docker-compose.yml     # Docker Compose 配置
└── package.json           # 项目依赖
```
