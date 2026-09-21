from pydantic import BaseModel
from typing import Optional, Any, List


# ── Interaction Embedding ─────────────────────────────────────────────────────

class InteractionEmbeddingRequest(BaseModel):
    group_id: str
    source_type: str   # "poll" | "chat_summary" | "vote"
    source_id: Optional[str] = None
    summary_text: str


class InteractionEmbeddingResponse(BaseModel):
    status: str
    message: str
    group_id: str
    source_type: str
    vector_dimensions: int


# ── Itinerary Generation ──────────────────────────────────────────────────────

class ItineraryItem(BaseModel):
    activityName: str
    description: Optional[str] = None
    location: Optional[str] = None
    timeSlot: str
    startTime: Optional[str] = None
    endTime: Optional[str] = None
    transitMode: Optional[str] = None
    estimatedCost: float = 0.0
    bookingRef: Optional[str] = None
    apiSource: Optional[str] = None
    rawApiData: Optional[Any] = None


class ItineraryDay(BaseModel):
    dayNumber: int
    date: str
    items: List[ItineraryItem]


class ItineraryVariant(BaseModel):
    variantType: str
    summary: str
    totalCostPerPerson: float
    constraints: Optional[Any] = None
    days: List[ItineraryDay]


class ItineraryGenerateRequest(BaseModel):
    group_id: str
    origin: str
    destination: str
    start_date: str   # "YYYY-MM-DD"
    end_date: str     # "YYYY-MM-DD"
    member_count: int = 2
    group_stats: Optional[Any] = None
    constraints: Optional[Any] = None


class ItineraryGenerateResponse(BaseModel):
    group_id: str
    destination: str
    itineraries: List[ItineraryVariant]
    total_variants: int


# ── Mishap Recovery ───────────────────────────────────────────────────────────

class MishapRecoverRequest(BaseModel):
    group_id: str
    itinerary: Any           # Full itinerary object from DB
    missed_item_id: str
    current_time: str         # ISO8601 datetime string


class MishapRecoverResponse(BaseModel):
    group_id: str
    itinerary: ItineraryVariant
    rescheduled_count: int
    message: str
