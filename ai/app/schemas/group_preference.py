from pydantic import BaseModel
from typing import Optional

"""
Schemas for Group Consensus Preference endpoints.
"""


class GroupPreferenceRequest(BaseModel):
    group_id: str       # UUID of the trip
    member_ids: list[str]  # UUIDs of ALL current trip members


class GroupPreferenceResponse(BaseModel):
    group_id: str
    vector_dimensions: int
    members_computed: int
    message: str
