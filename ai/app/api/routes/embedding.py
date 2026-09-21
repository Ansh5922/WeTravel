from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.api.deps import get_current_user
from app.core.database import get_db
from app.schemas.embedding import PreferenceEmbeddingRequest, PreferenceEmbeddingResponse
from app.services.embedding_service import create_and_save_preference_embedding

"""
Embedding Router — FastAPI AI Backend
Architecture layer: Routes → Service → Repository → Database

Endpoint consumed by Node.js backend internally (fire-and-forget).
Protected by the same JWT that the client holds — Node.js signs
a short-lived internal token using the shared JWT_SECRET.
"""

router = APIRouter(prefix="/api/ai/embeddings", tags=["Embeddings"])


@router.post(
    "/preferences",
    response_model=PreferenceEmbeddingResponse,
    summary="Generate and save preference embedding for a user",
    description="""
**Internal endpoint — called by Node.js backend, NOT the client directly.**

After Node.js saves a user's profile preferences to the database,
it fires an asynchronous (fire-and-forget) POST request here.

This endpoint:
1. Receives the user_id and preference_text
2. Generates a 384-dimensional embedding using all-MiniLM-L6-v2
3. Saves the vector to `user_profiles.preference_vector` in Postgres

The client never waits for this — it already received a 200 from Node.js.
    """,
)
async def generate_preference_embedding(
    payload: PreferenceEmbeddingRequest,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db),
):
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
