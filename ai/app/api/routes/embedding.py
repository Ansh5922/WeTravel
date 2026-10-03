from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.middleware.auth import get_current_user
from app.core.database import get_db
from app.schemas.embedding import PreferenceEmbeddingRequest, PreferenceEmbeddingResponse
from app.controllers.embedding_controller import generate_embedding

router = APIRouter(prefix="/api/ai/embeddings", tags=["Embeddings"])

# Generate and save preference embedding for a user
@router.post(
    "/preferences",
    response_model=PreferenceEmbeddingResponse,
    summary="Generate and save preference embedding for a user",
)
async def handle_generate_preference_embedding(
    payload: PreferenceEmbeddingRequest,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    # Generate and persist user preference embedding.
    return generate_embedding(payload=payload, db=db)
