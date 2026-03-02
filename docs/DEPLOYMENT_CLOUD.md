# situation-monitor 云端部署方案

**版本**: v1.1
**更新日期**: 2026-03-02

---

## 1. 项目概述

- **项目名称**: situation-monitor
- **项目描述**: 实时监控大屏 - 全球新闻、市场、地缘政治事件
- **技术栈**: SvelteKit + Vite + TailwindCSS + D3.js
- **GitHub**: https://github.com/hipcityreg/situation-monitor

---

## 2. 云端架构

```
┌─────────────────────────────────────────────────────────────┐
│                      云服务器                               │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────┐  │
│  │              OpenClaw Gateway (Agent)                 │  │
│  │              agent-situation                         │  │
│  └─────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌────────────┐  ┌────────────┐                          │
│  │  Frontend  │  │   Proxy    │                          │
│  │  (SvelteKit)│  │  (Nginx)   │                          │
│  │  :5174     │  │  :80       │                          │
│  └────────────┘  └────────────┘                          │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 3. 部署步骤

### 3.1 环境准备

```bash
# 1. 安装Node.js 22
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt-get install -y nodejs

# 2. 安装pnpm
npm install -g pnpm

# 3. 创建工作目录
mkdir -p ~/situation-monitor
```

### 3.2 项目部署

```bash
# 克隆项目
cd ~/situation-monitor
git clone https://github.com/hipcityreg/situation-monitor.git

# 安装依赖
cd situation-monitor
pnpm install

# 构建项目
pnpm build

# 启动生产服务
pnpm preview --host 0.0.0.0 --port 5174
```

### 3.3 使用Docker部署

```bash
# 创建Dockerfile
cat > Dockerfile << 'EOF'
FROM node:22-slim
WORKDIR /app
RUN corepack enable && corepack prepare pnpm@latest --activate
COPY . .
RUN pnpm install && pnpm build
EXPOSE 5174
CMD ["pnpm", "preview", "--host", "0.0.0.0", "--port", "5174"]
EOF

# 构建镜像
docker build -t situation-monitor:latest .

# 运行容器
docker run -d -p 5174:5174 --name situation-monitor situation-monitor:latest
```

---

## 4. 端口配置

| 服务 | 端口 | 说明 |
|------|------|------|
| Frontend | 5174 | SvelteKit生产预览 |
| Nginx | 80 | 反向代理(可选) |

---

## 5. Agent集成

### 5.1 agent-situation 配置

```yaml
# 云端 openclaw.json
{
  "agents": {
    "situation": {
      "model": "minimax-portal/MiniMax-M2.5",
      "workspace": "~/situation-monitor/situation-monitor",
      "skills": ["github", "weather"]
    }
  }
}
```

### 5.2 启动Agent

```bash
# 在云端启动Agent
openclaw agent --agent situation --mode session
```

---

## 6. 运维

### 6.1 日志

```bash
# Docker方式
docker logs -f situation-monitor

# PM2方式 (如使用)
pm2 logs situation-monitor
```

### 6.2 更新

```bash
# 更新项目
cd ~/situation-monitor/situation-monitor
git pull
pnpm install
pnpm build

# 重启服务
docker restart situation-monitor
```

---

## 7. 监控数据源

| 数据源 | 用途 | 状态 |
|--------|------|------|
| NewsAPI | 全球新闻 | 待配置 |
| Alpha Vantage | 股票数据 | 待配置 |
| OpenWeatherMap | 天气数据 | 待配置 |

---

*更新: 曹佬 | 2026-03-02*
