from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse, Response
from dotenv import load_dotenv
from database import engine
import models

load_dotenv()

models.Base.metadata.create_all(bind=engine)

from routes import auth, cv, matching, chatbot

app = FastAPI(
    title="AscendIA API",
    description="Career copilot backend — CV analysis, job matching, chatbot",
    version="1.0.0",
)

_CORS = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS, PATCH, HEAD",
    "Access-Control-Allow-Headers": "Authorization, Content-Type, Accept, Origin, X-Requested-With",
}

# Handles exceptions that escape routes — adds CORS headers so the browser
# can actually read the error instead of seeing a blocked response.
@app.exception_handler(Exception)
async def _unhandled(request: Request, exc: Exception):
    return JSONResponse(status_code=500, content={"detail": str(exc)}, headers=_CORS)


@app.middleware("http")
async def cors_middleware(request: Request, call_next):
    if request.method == "OPTIONS":
        return Response(status_code=200, headers=_CORS)
    try:
        response = await call_next(request)
    except Exception as exc:
        return JSONResponse(status_code=500, content={"detail": str(exc)}, headers=_CORS)
    for k, v in _CORS.items():
        response.headers[k] = v
    return response


app.include_router(auth.router)
app.include_router(cv.router)
app.include_router(matching.router)
app.include_router(chatbot.router)


@app.get("/health")
def health():
    return {"status": "ok", "service": "AscendIA API"}
