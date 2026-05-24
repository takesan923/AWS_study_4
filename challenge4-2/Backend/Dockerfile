FROM python:3.12-slim

COPY requirements.txt /tmp/
RUN pip install --no-cache-dir -r /tmp/requirements.txt

WORKDIR /app
COPY app/ .

COPY alembic/ /alembic/
COPY alembic.ini /alembic.ini

EXPOSE 8080

CMD ["sh", "-c", "cd / && alembic upgrade head && uvicorn main:app --app-dir /app --host 0.0.0.0 --port 8080"]