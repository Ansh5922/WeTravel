from sqlalchemy.orm import Session
from app.schemas.itinerary import (
    InteractionEmbeddingRequest, InteractionEmbeddingResponse,
    ItineraryGenerateRequest, ItineraryGenerateResponse,
    MishapRecoverRequest, MishapRecoverResponse,
)
from app.services.interaction_service import create_interaction_embedding
from app.services import itinerary_service

"""
Itinerary & Interaction Controllers — WeTravel AI Backend
Layer: Controller (Routes → Controller → Service)
"""


def handle_interaction_embedding(
    payload: InteractionEmbeddingRequest,
    db: Session,
) -> InteractionEmbeddingResponse:
    result = create_interaction_embedding(
        db=db,
        group_id=payload.group_id,
        source_type=payload.source_type,
        source_id=payload.source_id,
        summary_text=payload.summary_text,
    )
    return InteractionEmbeddingResponse(
        status="success",
        message="Interaction embedding generated and saved.",
        group_id=result["group_id"],
        source_type=result["source_type"],
        vector_dimensions=result["vector_dimensions"],
    )


async def handle_generate_itinerary(
    payload: ItineraryGenerateRequest,
    db: Session,
) -> ItineraryGenerateResponse:
    itineraries = await itinerary_service.generate_itineraries(
        group_id=payload.group_id,
        origin=payload.origin,
        destination=payload.destination,
        start_date=payload.start_date,
        end_date=payload.end_date,
        member_count=payload.member_count,
        group_stats=payload.group_stats or {},
        constraints=payload.constraints or {},
    )
    return ItineraryGenerateResponse(
        group_id=payload.group_id,
        destination=payload.destination,
        itineraries=itineraries,
        total_variants=len(itineraries),
    )


async def handle_mishap_recovery(
    payload: MishapRecoverRequest,
    db: Session,
) -> MishapRecoverResponse:
    result = await itinerary_service.recover_itinerary(
        group_id=payload.group_id,
        itinerary=payload.itinerary,
        missed_item_id=payload.missed_item_id,
        current_time=payload.current_time,
    )
    return MishapRecoverResponse(
        group_id=payload.group_id,
        itinerary=result,
        rescheduled_count=result["constraints"].get("rescheduled_count", 0),
        message=result["summary"],
    )
