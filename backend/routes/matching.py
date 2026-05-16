import json
import traceback
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
import models
import schemas
from utils.auth import get_current_user
from utils.openai_client import get_client

router = APIRouter(prefix="/matching", tags=["matching"])

MATCH_PROMPT = """
You are an expert recruiter and career advisor. Compare the candidate's CV skills with the job description and return a JSON object with this exact structure:

{{
  "match_score": <integer 0-100>,
  "strong_skills": ["<skill already mastered>", ...],
  "missing_skills": ["<skill missing or to improve>", ...],
  "certifications": [
    {{
      "title": "<certification title>",
      "platform": "<Coursera|Udemy|LinkedIn Learning|etc>",
      "duration": "<e.g. 8h or 4 weeks>",
      "price": "<e.g. Free|~25€|~40€>",
      "priority": "<high|medium|low>",
      "reason": "<why this certification helps>"
    }},
    ...
  ]
}}

Be realistic with the match score. Suggest 2-4 certifications to fill skill gaps.
Return ONLY valid JSON, no markdown, no explanation.

CANDIDATE SKILLS:
{skills}

JOB DESCRIPTION:
{job_description}
"""


@router.post("/analyze")
async def analyze_match(
    payload: schemas.JobMatchRequest,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    print("=== ANALYZE MATCH CALLED ===", flush=True)
    try:
        return await _do_analyze(payload, current_user, db)
    except HTTPException:
        raise
    except Exception as e:
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Unexpected: {str(e)}")


async def _do_analyze(payload, current_user, db):
    skills_text = ""
    if payload.cv_analysis_id:
        analysis = (
            db.query(models.CVAnalysis)
            .filter(
                models.CVAnalysis.id == payload.cv_analysis_id,
                models.CVAnalysis.user_id == current_user.id,
            )
            .first()
        )
        if analysis:
            skills = json.loads(analysis.skills or "[]")
            skills_text = ", ".join(s["name"] for s in skills)

    if not skills_text:
        skills_text = f"Target job: {current_user.target_job or 'Not specified'}"

    prompt = MATCH_PROMPT.format(
        skills=skills_text,
        job_description=payload.job_description[:5000],
    )

    try:
        client = get_client()
        response = await client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[{"role": "user", "content": prompt}],
            response_format={"type": "json_object"},
            temperature=0.3,
        )

        data = json.loads(response.choices[0].message.content)
    except Exception as e:
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"OpenAI error: {str(e)}")

    try:
        match = models.JobMatch(
            user_id=current_user.id,
            cv_analysis_id=payload.cv_analysis_id,
            job_title=payload.job_title,
            company=payload.company,
            job_description=payload.job_description[:5000],
            match_score=float(data.get("match_score", 0)),
            strong_skills=json.dumps(data.get("strong_skills", [])),
            missing_skills=json.dumps(data.get("missing_skills", [])),
            certifications=json.dumps(data.get("certifications", [])),
        )
        db.add(match)
        db.commit()
        db.refresh(match)
    except Exception as e:
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"DB error: {str(e)}")

    try:
        return _serialize(match)
    except Exception as e:
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Serialize error: {str(e)}")


@router.get("/history")
def match_history(
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    matches = (
        db.query(models.JobMatch)
        .filter(models.JobMatch.user_id == current_user.id)
        .order_by(models.JobMatch.created_at.desc())
        .limit(20)
        .all()
    )
    return [_serialize(m) for m in matches]


def _serialize(m: models.JobMatch) -> dict:
    return {
        "id": m.id,
        "job_title": m.job_title,
        "company": m.company,
        "match_score": m.match_score,
        "strong_skills": json.loads(m.strong_skills or "[]"),
        "missing_skills": json.loads(m.missing_skills or "[]"),
        "certifications": json.loads(m.certifications or "[]"),
        "created_at": m.created_at.isoformat() if m.created_at else None,
    }
