import asyncio
from datetime import date, datetime
from app.services import travel_api_service as travel
from app.services import scheduler_service as scheduler


async def generate_itineraries(
    *,
    group_id: str,
    origin: str,
    destination: str,
    start_date: str,
    end_date: str,
    member_count: int,
    group_stats: dict,
    constraints: dict,
) -> list[dict]:
    # Orchestrate parallel travel data fetching and multi-variant itinerary generation
    s_date = date.fromisoformat(start_date)
    e_date = date.fromisoformat(end_date)

    if e_date <= s_date:
        raise ValueError("end_date must be after start_date.")

    dep_date_fmt = s_date.strftime("%Y%m%d")

    budget_avg = _safe_float(
        (group_stats or {}).get("budget", {}).get("group_avg") or
        (group_stats or {}).get("budget", {}).get("group_avg"),
        default=2000
    )

    trains, buses, hotels = await asyncio.gather(
        travel.fetch_trains(origin, destination, dep_date_fmt),
        travel.fetch_buses(origin, destination, dep_date_fmt),
        travel.fetch_hotels(destination, start_date, end_date, member_count, max_price_per_night=budget_avg),
    )

    print(f"[ItineraryService] Fetched {len(trains)} trains, {len(buses)} buses, {len(hotels)} hotels for {destination}")

    all_transport = trains + buses

    if not all_transport:
        raise RuntimeError("No transport options found for the route. Please check origin/destination codes.")
    if not hotels:
        raise RuntimeError("No hotels found for the destination and dates provided.")

    variants = scheduler.generate_variants(
        start_date=s_date,
        end_date=e_date,
        destination=destination,
        trains=trains,
        buses=buses,
        hotels=hotels,
        group_stats=group_stats or {},
        member_count=member_count,
    )

    print(f"[ItineraryService] Generated {len(variants)} itinerary variants.")
    return variants


async def recover_itinerary(
    *,
    group_id: str,
    itinerary: dict,
    missed_item_id: str,
    current_time: str,
) -> dict:
    # Reschedule itinerary items dynamically when a transport event is missed
    current_dt = datetime.fromisoformat(current_time)

    all_items = []
    for day in itinerary.get("items", []):
        all_items.append(day)

    missed_item = next((i for i in all_items if str(i.get("id", "")) == missed_item_id), None)

    next_transport = None
    if missed_item and missed_item.get("transitMode") in ("train", "bus"):
        dep_date_fmt = current_dt.strftime("%Y%m%d")
        trains, buses = await asyncio.gather(
            travel.fetch_trains("", itinerary.get("destination", ""), dep_date_fmt),
            travel.fetch_buses("", itinerary.get("destination", ""), dep_date_fmt),
        )
        all_transport = trains + buses
        current_time_str = current_dt.strftime("%H:%M")
        next_transport = next(
            (t for t in all_transport if (t.get("departureTime") or "00:00") > current_time_str),
            all_transport[0] if all_transport else None
        )

    updated_items, rescheduled_count = scheduler.recover_from_mishap(
        itinerary_items=all_items,
        missed_item_id=missed_item_id,
        current_time=current_dt,
        next_available_transport=next_transport,
    )

    transport_src = next_transport.get("source", "mock") if next_transport else "none"
    train_live = (transport_src == "railwayapi")
    recovery_data_sources = {
        "status": "live" if train_live else "mock",
        "isFullyLive": train_live,
        "hasLiveHotels": False,
        "hasLiveTrains": train_live,
        "hasLiveBuses": False,
        "trains": "live (IRCTC)" if train_live else "mock (simulated)",
        "hotels": "n/a",
        "buses": "n/a",
        "notice": "Rescheduled with live IRCTC transport." if train_live else "Rescheduled with simulated fallback transport.",
    }

    return {
        "variantType": "mishap_recovery",
        "summary": f"Recovery itinerary — {rescheduled_count} items rescheduled after missed transport.",
        "totalCostPerPerson": sum(float(i.get("estimatedCost") or 0) for i in updated_items),
        "constraints": {"mishap_recovery": True, "rescheduled_count": rescheduled_count, "dataSources": recovery_data_sources},
        "dataSources": recovery_data_sources,
        "days": _group_items_by_day(updated_items),
    }


def _group_items_by_day(items: list[dict]) -> list[dict]:
    # Group flat list of itinerary items by day number
    days_map = {}
    for item in items:
        day_num = item.get("dayNumber", 1)
        if day_num not in days_map:
            days_map[day_num] = {"dayNumber": day_num, "date": item.get("date", ""), "items": []}
        item_copy = {k: v for k, v in item.items() if k not in ("dayNumber", "date")}
        days_map[day_num]["items"].append(item_copy)
    return [days_map[k] for k in sorted(days_map)]


def _safe_float(val, default: float = 0.0) -> float:
    # Safely convert value to float with fallback
    try:
        return float(val)
    except (TypeError, ValueError):
        return default
