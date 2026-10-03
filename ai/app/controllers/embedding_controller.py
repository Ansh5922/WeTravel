from sqlalchemy.orm import Session
from app.schemas.embedding import PreferenceEmbeddingRequest, PreferenceEmbeddingResponse
from app.services.embedding_service import create_and_save_preference_embedding

def generate_embedding(
    payload: PreferenceEmbeddingRequest,
    db: Session,
) -> PreferenceEmbeddingResponse:
    # Controller for user preference embedding generation
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
