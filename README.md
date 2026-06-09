# DevOps Platform

> **一个完整的云原生 CI/CD 演示项目** — 从代码提交到 Kubernetes 部署，全链路自动化。

[![CI/CD Pipeline](https://github.com/yunzhengmengze/devops-platform/actions/workflows/ci.yml/badge.svg)](https://github.com/yunzhengmengze/devops-platform/actions/workflows/ci.yml)

---

## 架构概览

```
┌─────────────┐     ┌──────────────┐     ┌───────────────────┐
│  Developer  │────▶│  GitHub Repo │────▶│  GitHub Actions   │
│   git push  │     │              │     │  CI/CD Pipeline   │
└─────────────┘     └──────────────┘     └────────┬──────────┘
                                                   │
                          ┌────────────────────────┼────────────────────────┐
                          │                        ▼                        │
                          │  ┌──────────┐  ┌───────────┐  ┌────────────┐  │
                          │  │  Build   │  │   Test    │  │   Deploy   │  │
                          │  │  Docker  │──│  pytest   │──│  Helm → K8s│  │
                          │  └──────────┘  └───────────┘  └────────────┘  │
                          │                                                │
                          │              Kubernetes Cluster                │
                          │  ┌──────────────────────────────────────────┐ │
                          │  │          Namespace: devops-demo          │ │
                          │  │  ┌─────────────┐  ┌─────────────────┐   │ │
                          │  │  │ Deployment  │  │    Service      │   │ │
                          │  │  │ 2 replicas  │──│   ClusterIP:80  │   │ │
                          │  │  │ RollingUpd  │  └─────────────────┘   │ │
                          │  │  └─────────────┘                        │ │
                          │  │  ┌──────────┐  ┌──────────┐            │ │
                          │  │  │Liveness  │  │Readiness │            │ │
                          │  │  │  Probe   │  │  Probe   │            │ │
                          │  │  └──────────┘  └──────────┘            │ │
                          │  └──────────────────────────────────────────┘ │
                          └────────────────────────────────────────────────┘
```

## 技术栈

| 分类 | 技术 |
|------|------|
| 应用 | Python 3.12, FastAPI |
| 测试 | pytest |
| 容器化 | Docker, Docker Compose |
| 编排 | Kubernetes, k3s |
| 包管理 | Helm |
| CI/CD | GitHub Actions |
| 监控 | liveness/readiness probes |
| 部署策略 | RollingUpdate (零停机) |

## 快速开始

### 本地开发

```bash
# 1. 安装依赖
pip install -r app/requirements.txt

# 2. 启动服务
cd app && uvicorn main:app --host 0.0.0.0 --port 8000 --reload

# 3. 测试
curl http://localhost:8000/health
```

### Docker 运行

```bash
make build VERSION=1.0.0   # 构建镜像
make run                   # docker compose 启动
curl http://localhost:8000/
```

### Kubernetes 部署

```bash
# 使用 Helm (推荐)
make helm-install VERSION=1.0.0

# 或使用 kubectl 直接部署
make k8s-deploy

# 端口转发
kubectl port-forward -n devops-demo svc/devops-api 8000:80

# 测试
curl http://localhost:8000/health
```

## API

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/` | 服务信息 |
| GET | `/health` | 健康检查 (liveness) |
| GET | `/ready` | 就绪检查 (readiness) |
| GET | `/tasks` | 获取所有任务 |
| POST | `/tasks` | 创建任务 |
| GET | `/tasks/{id}` | 获取单个任务 |
| PUT | `/tasks/{id}` | 更新任务 |
| DELETE | `/tasks/{id}` | 删除任务 |

## 运行演示

```bash
bash scripts/demo.sh
```

输出效果：

```
╔══════════════════════════════════════════════╗
║     DevOps Platform — 项目演示               ║
╚══════════════════════════════════════════════╝

[1/5] 架构概览
  请求 → Nginx(:8000) → 负载均衡 → App1 + App2
  ┌─────────┐      ┌───────────┐
  │  Nginx  │─────▶│  App 1    │
  │  :8000  │      └───────────┘
  │         │      ┌───────────┐
  │         │─────▶│  App 2    │
  └─────────┘      └───────────┘

[2/5] Docker 容器状态
NAME                      STATUS             PORTS
devops-platform-app1-1    Up (healthy)       8000/tcp
devops-platform-app2-1    Up (healthy)       8000/tcp
devops-platform-nginx-1   Up                 0.0.0.0:8000->80/tcp

[3/5] 健康检查
{"status":"ok","version":"1.0.0"}

[4/5] API 功能测试
  GET  /health → {"status":"ok","version":"1.0.0"}
  POST /tasks  → {"id":"47b4cc9f","title":"Demo 测试任务",...}
  GET  /tasks  → [{"id":"344d3001","title":"学习Kubernetes",...}]

[5/5] 自动化测试
tests/test_main.py::test_root PASSED
tests/test_main.py::test_health PASSED
tests/test_main.py::test_ready PASSED
tests/test_main.py::test_create_and_get_task PASSED
tests/test_main.py::test_update_task PASSED
tests/test_main.py::test_delete_task PASSED
tests/test_main.py::test_404 PASSED
============================== 7 passed ==============================
```

## 项目结构

```
devops-platform/
├── app/
│   ├── main.py              # FastAPI 应用
│   └── requirements.txt     # Python 依赖
├── tests/
│   └── test_main.py         # 自动化测试 (7 个用例)
├── k8s/
│   ├── namespace.yaml       # 命名空间
│   ├── deployment.yaml      # 部署配置 (2 副本, 滚动更新)
│   ├── service.yaml         # Service
│   └── ingress.yaml         # Ingress
├── helm/
│   └── devops-app/
│       ├── Chart.yaml       # Chart 信息
│       ├── values.yaml      # 默认配置
│       └── templates/       # 模板文件
├── scripts/
│   └── deploy.sh            # 一键部署脚本
├── .github/
│   └── workflows/
│       └── ci.yml           # CI/CD 流水线
├── Dockerfile               # 多阶段构建
├── docker-compose.yml       # 本地开发
├── Makefile                 # 常用命令
└── README.md
```

## CI/CD 流水线

每次 `git push` 到 main 分支自动执行：

```
代码检出 → 安装依赖 → 运行测试 → 构建镜像 → 推送到 Docker Hub → Helm 部署到 K8s
```

**需要的 GitHub Secrets：**
- `DOCKERHUB_USERNAME` — Docker Hub 用户名
- `DOCKERHUB_TOKEN` — Docker Hub Access Token
- `KUBECONFIG` — K8s 集群配置 (base64)

## 演示亮点

面试时可以聊的技术点：

1. **容器化** — Dockerfile 最佳实践: 非 root 用户、健康检查、分层构建
2. **Kubernetes** — Deployment、Service、Ingress、滚动更新策略
3. **Helm** — 模板化部署，环境差异化配置
4. **CI/CD** — GitHub Actions 自动化，测试→构建→部署一气呵成
5. **可靠性** — liveness/readiness probes，零停机滚动更新
6. **可观测性** — 健康检查端点，结构化日志

---

**作者**: 邓乐乐 | [GitHub](https://github.com/yunzhengmengze)
