FROM python:3.12-slim

WORKDIR /app

# 安装依赖
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 复制代码
COPY app/main.py .

# 非 root 运行
RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 8000

# 健康检查
HEALTHCHECK --interval=15s --timeout=3s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')" || exit 1

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
