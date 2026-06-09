"""
自动化测试 — 每次 CI 构建时运行
"""
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def test_root():
    """根路径返回服务信息"""
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert data["service"] == "DevOps Platform API"
    assert data["status"] == "healthy"


def test_health():
    """健康检查端点"""
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"


def test_ready():
    """就绪探针"""
    response = client.get("/ready")
    assert response.status_code == 200
    assert response.json()["status"] == "ready"


def test_create_and_get_task():
    """创建任务 → 查询任务"""
    # 创建
    resp = client.post("/tasks", json={
        "title": "测试任务",
        "description": "这是一条自动化测试创建的任务"
    })
    assert resp.status_code == 201
    task = resp.json()
    assert task["title"] == "测试任务"
    assert "id" in task

    # 查询
    task_id = task["id"]
    resp = client.get(f"/tasks/{task_id}")
    assert resp.status_code == 200
    assert resp.json()["title"] == "测试任务"


def test_update_task():
    """更新任务"""
    resp = client.post("/tasks", json={"title": "原始标题"})
    task_id = resp.json()["id"]

    resp = client.put(f"/tasks/{task_id}", json={
        "title": "修改后的标题",
        "description": "",
        "done": True
    })
    assert resp.status_code == 200
    assert resp.json()["title"] == "修改后的标题"
    assert resp.json()["done"] is True


def test_delete_task():
    """删除任务"""
    resp = client.post("/tasks", json={"title": "待删除"})
    task_id = resp.json()["id"]

    resp = client.delete(f"/tasks/{task_id}")
    assert resp.status_code == 200

    # 确认删除
    resp = client.get(f"/tasks/{task_id}")
    assert resp.status_code == 404


def test_404():
    """不存在的任务返回 404"""
    resp = client.get("/tasks/nonexistent")
    assert resp.status_code == 404
