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

"""
Itinerary & Interaction Routes — WeTravel AI Backend
Layer: Routes (thin endpoint definitions)
"""

router = APIRouter(prefix="/api/ai", tags=["Itinerary & Interactions"])


@router.post(
    "/embeddings/interaction",
    response_model=InteractionEmbeddingResponse,
    summary="Generate and save interaction embedding (polls, chat summaries)",
    description="""
**Internal endpoint — called by Node.js backend after a poll is closed.**

Generates a 384-dimensional embedding from the poll result summary text
and saves it to `interaction_embeddings` for use in itinerary scoring.
    """,
)
def handle_interaction_webhook(
    payload: InteractionEmbeddingRequest,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    return handle_interaction_embedding(payload=payload, db=db)


@router.post(
    "/itinerary/generate",
    response_model=ItineraryGenerateResponse,
    summary="Generate 5 itinerary variants for a trip",
    description="""
**Internal endpoint — called by Node.js backend when trip admin requests itinerary generation.**

Fetches real-time trains (IRCTC), buses (mock), and hotels (Booking.com),
then runs the mathematical scheduler to produce up to 5 variants:
- **optimal**: best-fit to group_avg budget + majority pace
- **budget_flex_20**: +20% budget ceiling, upgraded accommodation
- **duration_extend_2d**: 2 extra days at destination
- **night_travel**: overnight transport, more daytime exploration
- **budget_strict**: at group_min budget, cheapest options
    """,
)
async def handle_generate(
    payload: ItineraryGenerateRequest,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    return await handle_generate_itinerary(payload=payload, db=db)


@router.post(
    "/itinerary/recover",
    response_model=MishapRecoverResponse,
    summary="Re-generate itinerary after a missed train/bus (mishap recovery)",
    description="""
**Internal endpoint — called by Node.js backend when a member reports a missed transport.**

Algorithm:
1. Identifies the missed event
2. Fetches next available train/bus after current time
3. Shifts all subsequent items by the delay delta
4. Compresses/drops lowest-priority items if schedule overruns trip end date
5. Returns rebuilt itinerary with rescheduled items flagged
    """,
)
async def handle_recovery(
    payload: MishapRecoverRequest,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    return await handle_mishap_recovery(payload=payload, db=db)
