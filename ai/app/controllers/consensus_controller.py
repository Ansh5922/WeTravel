from sqlalchemy.orm import Session
from app.schemas.group_preference import GroupPreferenceRequest, GroupPreferenceResponse
from app.services.group_preference_service import compute_and_save_group_preference

def compute_group_preference(
    payload: GroupPreferenceRequest,
    db: Session,
) -> GroupPreferenceResponse:
    # Controller for computing and saving group preference
    result = compute_and_save_group_preference(
        db=db,
        group_id=payload.group_id,
        member_ids=payload.member_ids,
    )

    return GroupPreferenceResponse(**result)
