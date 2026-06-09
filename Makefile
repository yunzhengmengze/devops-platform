APP_NAME := devops-platform
VERSION  ?= dev
NAMESPACE ?= devops-demo

.PHONY: help install test build run deploy clean

help: ## 显示所有命令
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

install: ## 安装依赖
	pip install -r app/requirements.txt

test: ## 运行测试
	python -m pytest tests/ -v

build: ## 构建 Docker 镜像
	docker build -t $(APP_NAME):$(VERSION) .

run: ## 本地运行 (Docker Compose)
	docker compose up -d

stop: ## 停止服务
	docker compose down

k8s-deploy: ## 直接部署到 K8s (不使用 Helm)
	kubectl apply -f k8s/namespace.yaml
	kubectl apply -f k8s/deployment.yaml
	kubectl apply -f k8s/service.yaml

helm-install: ## Helm 安装
	helm upgrade --install devops-app ./helm/devops-app \
		--namespace $(NAMESPACE) --create-namespace \
		--set image.tag=$(VERSION)

helm-uninstall: ## Helm 卸载
	helm uninstall devops-app -n $(NAMESPACE)

clean: ## 清理
	docker compose down -v
	rm -rf __pycache__ .pytest_cache
