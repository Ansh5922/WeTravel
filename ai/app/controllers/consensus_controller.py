from sqlalchemy.orm import Session
from app.schemas.group_preference import GroupPreferenceRequest, GroupPreferenceResponse
from app.services.group_preference_service import compute_and_save_group_preference

"""
Consensus Controller — FastAPI AI Backend
Architecture layer: Controller (between Routes ↔ Service)

Responsibility:
  - Receive validated input from route handler
  - Call service methods
  - Build and return HTTP response
  - NEVER contain business logic or direct DB access
"""


def compute_group_preference(
    payload: GroupPreferenceRequest,
    db: Session,
) -> GroupPreferenceResponse:
    """
    Controller for POST /api/ai/consensus/group-preference

    Receives Pydantic-validated payload from the route,
    delegates to the group preference service, and constructs the response.
    """
    result = compute_and_save_group_preference(
        db=db,
        group_id=payload.group_id,
        member_ids=payload.member_ids,
    )

    return GroupPreferenceResponse(**result)
