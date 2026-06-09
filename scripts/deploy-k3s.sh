#!/bin/bash
# ============================================
# k3s 部署脚本 — 将项目部署到本地 k3s 集群
# ============================================
set -e

NAMESPACE=${NAMESPACE:-devops-demo}
echo "====== DevOps Platform → k3s 部署 ======"

# 1. 检查 k3s
if ! sudo kubectl cluster-info &>/dev/null 2>&1; then
    echo "[错误] k3s 未运行，请先执行: sudo sh /tmp/k3s-install.sh"
    exit 1
fi

# 2. 导入 Docker 镜像到 containerd
echo "[1/4] 导出 Docker 镜像..."
docker save devops-platform:latest -o /tmp/devops-platform.tar

echo "[2/4] 导入镜像到 k3s containerd..."
sudo k3s ctr images import /tmp/devops-platform.tar 2>&1
rm -f /tmp/devops-platform.tar

# 3. 部署
echo "[3/4] 部署到 Kubernetes..."
sudo kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | sudo kubectl apply -f -
sudo kubectl apply -f k8s/deployment.yaml
sudo kubectl apply -f k8s/service.yaml

# 4. 等待就绪
echo "[4/4] 等待 Pod 就绪..."
sudo kubectl wait --for=condition=ready pod -l app=devops-api -n "$NAMESPACE" --timeout=60s

echo ""
echo "====== 部署成功 ======"
echo ""
echo "查看状态:  sudo kubectl get all -n $NAMESPACE"
echo "端口转发:  sudo kubectl port-forward -n $NAMESPACE svc/devops-api 8000:80"
echo "测试 API:  curl http://localhost:8000/health"
