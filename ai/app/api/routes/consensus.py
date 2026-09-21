from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.api.deps import get_current_user
from app.core.database import SessionLocal
from app.schemas.group_preference import GroupPreferenceRequest, GroupPreferenceResponse
from app.services.group_preference_service import compute_and_save_group_preference

"""
Consensus Router — FastAPI AI Backend
Exposes the group preference computation endpoint called by Node.js
as a fire-and-forget background task whenever a member joins a trip.
"""


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


router = APIRouter(prefix="/api/ai", tags=["Group Consensus"])


@router.post("/consensus/group-preference", response_model=GroupPreferenceResponse)
def compute_group_preference(
    payload: GroupPreferenceRequest,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user),   # JWT protected — only Node.js can call this
):
    """
    Compute and save the group consensus preference vector.

    Called by Node.js as a fire-and-forget background task:
      - When a trip is first created  (admin's vector → initial consensus)
      - When a new member joins       (re-compute with all members)

    Algorithm: normalised centroid of all member preference vectors
    (maximises average cosine similarity to every member's vector).
    """
    result = compute_and_save_group_preference(
        db         = db,
        group_id   = payload.group_id,
        member_ids = payload.member_ids,
    )
    return GroupPreferenceResponse(**result)
