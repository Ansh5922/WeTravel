from pydantic import BaseModel
from typing import Optional, Any, List


class InteractionEmbeddingRequest(BaseModel):
    # Request payload to generate and record an interaction embedding
    group_id: str
    source_type: str
    source_id: Optional[str] = None
    summary_text: str


class InteractionEmbeddingResponse(BaseModel):
    # Response returned after recording an interaction embedding
    status: str
    message: str
    group_id: str
    source_type: str
    vector_dimensions: int


# Itinerary Generation

class ItineraryItem(BaseModel):
    # Individual activity or transit item in a scheduled day
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
    # Daily schedule breakdown containing an ordered list of itinerary items
    dayNumber: int
    date: str
    items: List[ItineraryItem]


class ItineraryVariant(BaseModel):
    # Full itinerary option variant with cost and day breakdowns
    variantType: str
    summary: str
    totalCostPerPerson: float
    constraints: Optional[Any] = None
    dataSources: Optional[Any] = None
    days: List[ItineraryDay]


class ItineraryGenerateRequest(BaseModel):
    # Request payload to trigger multi-variant itinerary generation
    group_id: str
    origin: str
    destination: str
    start_date: str
    end_date: str
    member_count: int = 2
    group_stats: Optional[Any] = None
    constraints: Optional[Any] = None


class ItineraryGenerateResponse(BaseModel):
    # Response payload containing generated itinerary variants
    group_id: str
    destination: str
    itineraries: List[ItineraryVariant]
    total_variants: int


class MishapRecoverRequest(BaseModel):
    # Request payload to dynamically reschedule an itinerary after a missed event
    group_id: str
    itinerary: Any
    missed_item_id: str
    current_time: str


class MishapRecoverResponse(BaseModel):
    # Response payload containing rescheduled itinerary and recovery count
    group_id: str
    itinerary: ItineraryVariant
    rescheduled_count: int
    message: str
