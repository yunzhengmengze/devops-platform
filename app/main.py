from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from datetime import datetime
import uuid
import os

app = FastAPI(
    title="DevOps Platform Demo",
    description="一个云原生微服务示例 — 演示 CI/CD、容器化、Kubernetes 部署",
    version="1.0.0"
)

# 用内存字典模拟数据库
tasks = {}
VERSION = os.getenv("APP_VERSION", "dev")


class Task(BaseModel):
    title: str
    description: str = ""
    done: bool = False


class TaskResponse(Task):
    id: str
    created_at: str


@app.get("/")
def root():
    return {
        "service": "DevOps Platform API",
        "version": VERSION,
        "status": "healthy",
        "uptime": str(datetime.now())
    }


@app.get("/health")
def health():
    return {"status": "ok", "version": VERSION}


@app.get("/ready")
def ready():
    """Kubernetes readiness probe — 检查依赖是否就绪"""
    return {"status": "ready"}


@app.get("/tasks")
def list_tasks():
    return list(tasks.values())


@app.post("/tasks", status_code=201)
def create_task(task: Task):
    task_id = str(uuid.uuid4())[:8]
    tasks[task_id] = {
        "id": task_id,
        "title": task.title,
        "description": task.description,
        "done": task.done,
        "created_at": datetime.now().isoformat()
    }
    return tasks[task_id]


@app.get("/tasks/{task_id}")
def get_task(task_id: str):
    if task_id not in tasks:
        raise HTTPException(status_code=404, detail="Task not found")
    return tasks[task_id]


@app.put("/tasks/{task_id}")
def update_task(task_id: str, task: Task):
    if task_id not in tasks:
        raise HTTPException(status_code=404, detail="Task not found")
    tasks[task_id].update({
        "title": task.title,
        "description": task.description,
        "done": task.done
    })
    return tasks[task_id]


@app.delete("/tasks/{task_id}")
def delete_task(task_id: str):
    if task_id not in tasks:
        raise HTTPException(status_code=404, detail="Task not found")
    del tasks[task_id]
    return {"message": "deleted"}


# ========== 启动方式 ==========
# python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
