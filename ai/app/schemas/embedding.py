from pydantic import BaseModel
from typing import Optional, Any


class PreferenceEmbeddingRequest(BaseModel):
    """
    Schema for the internal request from Node.js to generate preference embeddings.
    Architecture layer: Schemas (Pydantic data validation)
    """
    user_id: str
    preference_text: str          # Natural language string built by Node.js service
    raw_profile: Optional[Any] = None   # Full profile dict for reference (optional)


class PreferenceEmbeddingResponse(BaseModel):
    """
    Schema for the response returned to Node.js after embedding generation.
    """
    status: str
    message: str
    user_id: str
    vector_dimensions: int
