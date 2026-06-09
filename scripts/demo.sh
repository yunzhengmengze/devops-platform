#!/bin/bash
# ============================================
# 项目演示脚本 — 展示 CI/CD 流水线完整流程
# 运行: bash scripts/demo.sh
# ============================================
set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     DevOps Platform — 项目演示               ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════╝${NC}"
echo ""

# 1. 架构
echo -e "${GREEN}[1/5] 架构概览${NC}"
echo "  请求 → Nginx(:8000) → 负载均衡 → App1 + App2"
echo "  ┌─────────┐      ┌───────────┐"
echo "  │  Nginx  │─────▶│  App 1    │"
echo "  │  :8000  │      └───────────┘"
echo "  │         │      ┌───────────┐"
echo "  │         │─────▶│  App 2    │"
echo "  └─────────┘      └───────────┘"
echo ""

# 2. Docker
echo -e "${GREEN}[2/5] Docker 容器状态${NC}"
docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "请先运行: docker compose up -d"
echo ""

# 3. 健康检查
echo -e "${GREEN}[3/5] 健康检查${NC}"
curl -s http://localhost:8000/health 2>/dev/null || echo "API 未就绪"
echo ""
echo ""

# 4. API 测试
echo -e "${GREEN}[4/5] API 功能测试${NC}"
echo -n "  GET  /health → "
curl -s http://localhost:8000/health
echo ""

echo -n "  POST /tasks  → "
curl -s -X POST http://localhost:8000/tasks \
  -H "Content-Type: application/json" \
  -d '{"title":"Demo 测试任务"}'
echo ""

echo -n "  GET  /tasks  → "
curl -s http://localhost:8000/tasks
echo ""
echo ""

# 5. 测试
echo -e "${GREEN}[5/5] 自动化测试${NC}"
python3 -m pytest tests/ -v --tb=short 2>/dev/null || echo "请先安装依赖: pip install -r app/requirements.txt"

echo ""
echo -e "${BLUE}══════════════════════════════════════════════${NC}"
echo -e "${BLUE}  演示完成!  GitHub: github.com/yunzhengmengze/devops-platform${NC}"
echo -e "${BLUE}══════════════════════════════════════════════${NC}"
