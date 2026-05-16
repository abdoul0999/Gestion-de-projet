import json
from fastapi import APIRouter, Depends, UploadFile, File, HTTPException
from sqlalchemy.orm import Session
from database import get_db
import models
import schemas
from utils.auth import get_current_user
from utils.pdf_extractor import extract_text_from_pdf
from utils.openai_client import get_client

router = APIRouter(prefix="/cv", tags=["cv"])

ANALYZE_PROMPT = """
You are an expert career coach and CV analyst. Analyze the following CV text and return a JSON object with this exact structure:

{
  "score": <integer 0-100>,
  "skills": [
    {"name": "<skill name>", "level": <integer 0-100>},
    ...
  ],
  "corrections": [
    {"rule": "<rule description>", "status": "<ok|error|warning>", "suggestion": "<improvement text or null>"},
    ...
  ],
  "soft_skills": ["<soft skill>", ...],
  "languages": ["<language and level>", ...]
}

Rules to check in corrections:
- First name in lowercase
- Last name in UPPERCASE
- Consistent date format (MM/YYYY)
- Action verbs at start of bullet points
- Professional summary present
- Contact information complete
- No photo (not recommended for France)
- Clear section structure

Extract all technical skills with estimated proficiency levels.
Return ONLY valid JSON, no markdown, no explanation.

CV TEXT:
"""


@router.post("/analyze", response_model=schemas.CVAnalysisOut)
async def analyze_cv(
    file: UploadFile = File(...),
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if not file.filename.lower().endswith((".pdf", ".doc", ".docx")):
        raise HTTPException(status_code=400, detail="Only PDF, DOC, DOCX files are accepted")

    file_bytes = await file.read()

    if file.filename.lower().endswith(".pdf"):
        raw_text = extract_text_from_pdf(file_bytes)
    else:
        raw_text = file_bytes.decode("utf-8", errors="ignore")

    if not raw_text.strip():
        raise HTTPException(status_code=422, detail="Could not extract text from the file")

    client = get_client()
    response = await client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[{"role": "user", "content": ANALYZE_PROMPT + raw_text[:8000]}],
        response_format={"type": "json_object"},
        temperature=0.3,
    )

    data = json.loads(response.choices[0].message.content)

    analysis = models.CVAnalysis(
        user_id=current_user.id,
        filename=file.filename,
        raw_text=raw_text[:10000],
        skills=json.dumps(data.get("skills", [])),
        corrections=json.dumps(data.get("corrections", [])),
        score=float(data.get("score", 0)),
        soft_skills=json.dumps(data.get("soft_skills", [])),
        languages=json.dumps(data.get("languages", [])),
    )
    db.add(analysis)
    db.commit()
    db.refresh(analysis)

    return _serialize(analysis)


@router.get("/analyses", response_model=list[schemas.CVAnalysisOut])
def list_analyses(
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    analyses = (
        db.query(models.CVAnalysis)
        .filter(models.CVAnalysis.user_id == current_user.id)
        .order_by(models.CVAnalysis.created_at.desc())
        .all()
    )
    return [_serialize(a) for a in analyses]


@router.get("/analyses/{analysis_id}", response_model=schemas.CVAnalysisOut)
def get_analysis(
    analysis_id: int,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    analysis = (
        db.query(models.CVAnalysis)
        .filter(models.CVAnalysis.id == analysis_id, models.CVAnalysis.user_id == current_user.id)
        .first()
    )
    if not analysis:
        raise HTTPException(status_code=404, detail="Analysis not found")
    return _serialize(analysis)


def _serialize(a: models.CVAnalysis) -> dict:
    return {
        "id": a.id,
        "filename": a.filename,
        "score": a.score,
        "skills": json.loads(a.skills or "[]"),
        "corrections": json.loads(a.corrections or "[]"),
        "soft_skills": json.loads(a.soft_skills or "[]"),
        "languages": json.loads(a.languages or "[]"),
        "created_at": a.created_at,
    }
