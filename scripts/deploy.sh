#!/bin/bash
# ============================================
# DevOps Platform — 一键部署脚本
# ============================================
set -e

NAMESPACE=${NAMESPACE:-devops-demo}
VERSION=${VERSION:-latest}

echo "====== DevOps Platform 部署 ======"
echo "Namespace : $NAMESPACE"
echo "Version   : $VERSION"
echo ""

# 1. 检查 kubectl
if ! command -v kubectl &>/dev/null; then
    echo "[错误] kubectl 未安装，请先安装"
    exit 1
fi

# 2. 检查集群连接
if ! kubectl cluster-info &>/dev/null; then
    echo "[错误] 无法连接 Kubernetes 集群"
    exit 1
fi

echo "[1/3] 创建命名空间..."
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

echo "[2/3] 构建 Docker 镜像..."
docker build -t devops-platform:"$VERSION" .

# 如果是 k3s，导入镜像到 containerd
if command -v k3s &>/dev/null; then
    echo "  检测到 k3s，导入镜像到 containerd..."
    docker save devops-platform:"$VERSION" | sudo k3s ctr images import -
fi

echo "[3/3] 部署到 Kubernetes..."
# 更新 deployment 中的镜像 tag
sed -i "s|image: devops-platform:.*|image: devops-platform:$VERSION|g" k8s/deployment.yaml
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

echo ""
echo "====== 部署完成 ======"
echo "查看 Pod 状态:  kubectl get pods -n $NAMESPACE -w"
echo "端口转发:       kubectl port-forward -n $NAMESPACE svc/devops-api 8000:80"
echo "测试 API:       curl http://localhost:8000/health"
