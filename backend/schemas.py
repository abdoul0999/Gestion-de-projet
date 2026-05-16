from pydantic import BaseModel, EmailStr
from typing import Optional, List
from datetime import datetime


# ── Auth ──────────────────────────────────────────────────────────────────────

class UserRegister(BaseModel):
    first_name: str
    last_name: str
    email: EmailStr
    password: str
    education_level: Optional[str] = None


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class ProfileSetup(BaseModel):
    target_job: str
    contract_type: str
    region: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: "UserOut"


class UserOut(BaseModel):
    id: int
    first_name: str
    last_name: str
    email: str
    target_job: Optional[str] = None
    contract_type: Optional[str] = None
    region: Optional[str] = None
    education_level: Optional[str] = None

    class Config:
        from_attributes = True


TokenResponse.model_rebuild()


# ── CV Analysis ───────────────────────────────────────────────────────────────

class SkillItem(BaseModel):
    name: str
    level: int   # 0–100


class CorrectionItem(BaseModel):
    rule: str
    status: str  # "ok" | "error" | "warning"
    suggestion: Optional[str] = None


class CVAnalysisOut(BaseModel):
    id: int
    filename: Optional[str]
    score: Optional[float]
    skills: List[SkillItem]
    corrections: List[CorrectionItem]
    soft_skills: List[str]
    languages: List[str]
    created_at: datetime

    class Config:
        from_attributes = True


# ── Job Matching ──────────────────────────────────────────────────────────────

class JobMatchRequest(BaseModel):
    job_title: str
    company: Optional[str] = ""
    job_description: str
    cv_analysis_id: Optional[int] = None


class CertificationItem(BaseModel):
    title: str
    platform: str
    duration: str
    price: str
    priority: str   # "high" | "medium" | "low"
    reason: str


class JobMatchOut(BaseModel):
    id: int
    job_title: str
    company: Optional[str]
    match_score: float
    strong_skills: List[str]
    missing_skills: List[str]
    certifications: List[CertificationItem]
    created_at: datetime

    class Config:
        from_attributes = True


# ── Chatbot ───────────────────────────────────────────────────────────────────

class ChatRequest(BaseModel):
    message: str


class ChatMessageOut(BaseModel):
    id: int
    role: str
    content: str
    created_at: datetime

    class Config:
        from_attributes = True


class ChatResponse(BaseModel):
    reply: str
    message_id: int
