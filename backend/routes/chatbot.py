from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from database import get_db
import models
import schemas
from utils.auth import get_current_user
from utils.openai_client import get_client

router = APIRouter(prefix="/chatbot", tags=["chatbot"])

SYSTEM_PROMPT = """You are AscendIA, an expert AI career coach specializing in helping young French graduates (18-30 years old) navigate their professional career.

You provide personalized advice on:
- CV optimization and best practices for the French job market
- Career transitions and skill development
- Interview preparation (technical and behavioral)
- Job market trends in France
- Certification and training recommendations
- Work contract types (CDI, CDD, Stage, Alternance, Freelance)

Your tone is:
- Friendly and encouraging, like a mentor
- Professional but approachable
- Specific and actionable (not generic advice)
- Always cite concrete examples

You answer in the same language as the user (French or English).
Keep responses concise but complete (max 250 words).
"""


@router.post("/message", response_model=schemas.ChatResponse)
async def send_message(
    payload: schemas.ChatRequest,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    history = (
        db.query(models.ChatMessage)
        .filter(models.ChatMessage.user_id == current_user.id)
        .order_by(models.ChatMessage.created_at.desc())
        .limit(10)
        .all()
    )
    history.reverse()

    messages = [{"role": "system", "content": SYSTEM_PROMPT}]
    for msg in history:
        messages.append({"role": msg.role, "content": msg.content})
    messages.append({"role": "user", "content": payload.message})

    client = get_client()
    response = await client.chat.completions.create(
        model="gpt-4o-mini",
        messages=messages,
        temperature=0.7,
        max_tokens=400,
    )

    reply = response.choices[0].message.content

    user_msg = models.ChatMessage(user_id=current_user.id, role="user", content=payload.message)
    assistant_msg = models.ChatMessage(user_id=current_user.id, role="assistant", content=reply)
    db.add(user_msg)
    db.add(assistant_msg)
    db.commit()
    db.refresh(assistant_msg)

    return {"reply": reply, "message_id": assistant_msg.id}


@router.get("/history", response_model=list[schemas.ChatMessageOut])
def chat_history(
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    return (
        db.query(models.ChatMessage)
        .filter(models.ChatMessage.user_id == current_user.id)
        .order_by(models.ChatMessage.created_at.asc())
        .all()
    )


@router.delete("/history")
def clear_history(
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    db.query(models.ChatMessage).filter(models.ChatMessage.user_id == current_user.id).delete()
    db.commit()
    return {"message": "Chat history cleared"}
