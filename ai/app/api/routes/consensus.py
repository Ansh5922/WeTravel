from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.middleware.auth import get_current_user
from app.core.database import get_db
from app.schemas.group_preference import GroupPreferenceRequest, GroupPreferenceResponse
from app.controllers.consensus_controller import compute_group_preference

"""
Consensus Routes — FastAPI AI Backend
Architecture layer: Routes (defines endpoints, wires middleware → controller)

Responsibility:
  - Define API endpoint paths and HTTP methods
  - Wire JWT middleware (Depends) and DB session injection
  - Delegate ALL request handling to the controller
  - NEVER contain business logic or response construction
"""

router = APIRouter(prefix="/api/ai", tags=["Group Consensus"])


@router.post("/consensus/group-preference", response_model=GroupPreferenceResponse)
def handle_compute_group_preference(
    payload: GroupPreferenceRequest,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    Compute and save the group consensus preference vector.

    Called by Node.js as a fire-and-forget background task:
      - When a trip is first created  (admin's vector → initial consensus)
      - When a new member joins       (re-compute with all members)

    Algorithm: normalised centroid of all member preference vectors
    (maximises average cosine similarity to every member's vector).
    """
    return compute_group_preference(payload=payload, db=db)
