from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.middleware.auth import get_current_user
from app.core.database import get_db
from app.schemas.embedding import PreferenceEmbeddingRequest, PreferenceEmbeddingResponse
from app.controllers.embedding_controller import generate_embedding

"""
Embedding Routes — FastAPI AI Backend
Architecture layer: Routes (defines endpoints, wires middleware → controller)

Responsibility:
  - Define API endpoint paths and HTTP methods
  - Wire JWT middleware (Depends) and DB session injection
  - Delegate ALL request handling to the controller
  - NEVER contain business logic or response construction
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
async def handle_generate_preference_embedding(
    payload: PreferenceEmbeddingRequest,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    return generate_embedding(payload=payload, db=db)
