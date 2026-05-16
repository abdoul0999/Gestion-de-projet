from sqlalchemy import Column, Integer, String, Text, Float, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    first_name = Column(String(100), nullable=False)
    last_name = Column(String(100), nullable=False)
    email = Column(String(255), unique=True, index=True, nullable=False)
    hashed_password = Column(String(255), nullable=False)
    target_job = Column(String(200))
    contract_type = Column(String(50))
    region = Column(String(100))
    education_level = Column(String(50))
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    cv_analyses = relationship("CVAnalysis", back_populates="user")
    job_matches = relationship("JobMatch", back_populates="user")
    chat_messages = relationship("ChatMessage", back_populates="user")


class CVAnalysis(Base):
    __tablename__ = "cv_analyses"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    filename = Column(String(255))
    raw_text = Column(Text)
    skills = Column(Text)           # JSON string: ["Python", "SQL", ...]
    corrections = Column(Text)      # JSON string: [{rule, status, suggestion}, ...]
    score = Column(Float)
    soft_skills = Column(Text)      # JSON string
    languages = Column(Text)        # JSON string
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    user = relationship("User", back_populates="cv_analyses")


class JobMatch(Base):
    __tablename__ = "job_matches"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    cv_analysis_id = Column(Integer, ForeignKey("cv_analyses.id"))
    job_title = Column(String(200))
    company = Column(String(200))
    job_description = Column(Text)
    match_score = Column(Float)
    strong_skills = Column(Text)    # JSON string
    missing_skills = Column(Text)   # JSON string
    certifications = Column(Text)   # JSON string
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    user = relationship("User", back_populates="job_matches")


class ChatMessage(Base):
    __tablename__ = "chat_messages"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    role = Column(String(20), nullable=False)   # "user" or "assistant"
    content = Column(Text, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    user = relationship("User", back_populates="chat_messages")
