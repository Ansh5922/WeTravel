from sqlalchemy.orm import Session
from app.schemas.embedding import PreferenceEmbeddingRequest, PreferenceEmbeddingResponse
from app.services.embedding_service import create_and_save_preference_embedding

"""
Embedding Controller — FastAPI AI Backend
Architecture layer: Controller (between Routes ↔ Service)

Responsibility:
  - Receive validated input from route handler
  - Call service methods
  - Build and return HTTP response
  - NEVER contain business logic or direct DB access
"""


def generate_embedding(
    payload: PreferenceEmbeddingRequest,
    db: Session,
) -> PreferenceEmbeddingResponse:
    """
    Controller for POST /api/ai/embeddings/preferences

    Receives Pydantic-validated payload from the route,
    delegates to the embedding service, and constructs the response.
    """
    result = create_and_save_preference_embedding(
        db=db,
        user_id=payload.user_id,
        preference_text=payload.preference_text,
    )

    return PreferenceEmbeddingResponse(
        status="success",
        message="Preference embedding generated and saved.",
        user_id=result["user_id"],
        vector_dimensions=result["vector_dimensions"],
    )
