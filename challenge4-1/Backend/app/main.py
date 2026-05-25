import logging
import time

from fastapi import FastAPI, Request
from fastapi.exceptions import HTTPException
from fastapi.responses import JSONResponse

from database import engine
import models
from logger import logger, setup_logging
from router import tasks

setup_logging()

app = FastAPI(title="タスク管理 API")


@app.middleware("http")
async def _log_requests(request: Request, call_next):
    start = time.time()
    response = await call_next(request)
    duration_ms = round((time.time() - start) * 1000)
    level = logging.ERROR if response.status_code >= 500 else logging.INFO
    logger.log(
        level,
        "request",
        extra={
            "method": request.method,
            "path": request.url.path,
            "status_code": response.status_code,
            "duration_ms": duration_ms,
        },
    )
    return response


@app.exception_handler(HTTPException)
async def http_exception_handler(request: Request, exc: HTTPException):
    if isinstance(exc.detail, dict):
        return JSONResponse(status_code=exc.status_code, content=exc.detail)
    return JSONResponse(status_code=exc.status_code, content={"message": str(exc.detail)})


app.include_router(tasks.router, prefix="/api/tasks", tags=["Tasks"])


@app.get("/health")
def health_check():
    return {"status": "ok"}

@app.get("/api/error-test")
def error_test():
    raise HTTPException(status_code=500, detail={"message":"テスト用エラー"})