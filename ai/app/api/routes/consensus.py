from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.middleware.auth import get_current_user
from app.core.database import get_db
from app.schemas.group_preference import GroupPreferenceRequest, GroupPreferenceResponse
from app.controllers.consensus_controller import compute_group_preference

router = APIRouter(prefix="/api/ai", tags=["Group Consensus"])

# Compute and save the group consensus preference vector
@router.post("/consensus/group-preference", response_model=GroupPreferenceResponse)
def handle_compute_group_preference(
    payload: GroupPreferenceRequest,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    # Compute and save the group consensus preference vector
    return compute_group_preference(payload=payload, db=db)
