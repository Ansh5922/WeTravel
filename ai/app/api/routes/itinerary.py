from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.middleware.auth import get_current_user
from app.core.database import get_db
from app.schemas.itinerary import (
    InteractionEmbeddingRequest, InteractionEmbeddingResponse,
    ItineraryGenerateRequest, ItineraryGenerateResponse,
    MishapRecoverRequest, MishapRecoverResponse,
)
from app.controllers.itinerary_controller import (
    handle_interaction_embedding,
    handle_generate_itinerary,
    handle_mishap_recovery,
)

router = APIRouter(prefix="/api/ai", tags=["Itinerary & Interactions"])

# Save interaction embedding from poll results
@router.post(
    "/embeddings/interaction",
    response_model=InteractionEmbeddingResponse,
    summary="Generate and save interaction embedding",
)
def handle_interaction_webhook(
    payload: InteractionEmbeddingRequest,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    # Generate and save interaction embedding.
    return handle_interaction_embedding(payload=payload, db=db)

# Generate multi-variant itinerary plans for a trip
@router.post(
    "/itinerary/generate",
    response_model=ItineraryGenerateResponse,
    summary="Generate 5 itinerary variants for a trip",
)
async def handle_generate(
    payload: ItineraryGenerateRequest,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    # Generate up to 5 constraint-aware itinerary variants.
    return await handle_generate_itinerary(payload=payload, db=db)

# Recover and reschedule itinerary after a missed transit event
@router.post(
    "/itinerary/recover",
    response_model=MishapRecoverResponse,
    summary="Re-generate itinerary after a missed event",
)
async def handle_recovery(
    payload: MishapRecoverRequest,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    # Dynamic mishap recovery and schedule adjustment.
    return await handle_mishap_recovery(payload=payload, db=db)
