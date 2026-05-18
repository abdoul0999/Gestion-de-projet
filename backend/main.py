from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
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

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


app.include_router(auth.router)
app.include_router(cv.router)
app.include_router(matching.router)
app.include_router(chatbot.router)


@app.get("/health")
def health():
    return {"status": "ok", "service": "AscendIA API"}
