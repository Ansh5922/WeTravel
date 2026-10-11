from pydantic import BaseModel


class GroupPreferenceRequest(BaseModel):
    # Request payload containing group ID and member IDs for consensus calculation
    group_id: str
    member_ids: list[str]


class GroupPreferenceResponse(BaseModel):
    # Response returned after computing group consensus vector and statistics
    group_id: str
    vector_dimensions: int
    members_computed: int
    message: str
