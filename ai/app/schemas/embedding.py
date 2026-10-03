from pydantic import BaseModel
from typing import Optional, Any


class PreferenceEmbeddingRequest(BaseModel):
    # Request schema for generating preference embeddings
    user_id: str
    preference_text: str
    raw_profile: Optional[Any] = None


class PreferenceEmbeddingResponse(BaseModel):
    # Response schema returned after preference embedding generation
    status: str
    message: str
    user_id: str
    vector_dimensions: int
