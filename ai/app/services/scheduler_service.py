from datetime import datetime, date, timedelta
from typing import Any

"""
Scheduler Service — WeTravel AI Backend
Layer: Service (mathematical itinerary optimizer)

Algorithms:
  1. build_itinerary()    — Core day-by-day scheduler given transport + hotel candidate pool
  2. generate_variants()  — Produces 5 itinerary variants from the same candidate pool
  3. mishap_recovery()    — Re-schedules remaining trip after a missed transport event

Activity catalog per destination type (used when no live activity API is available).
"""

# ── Activity catalog (expandable per destination) ─────────────────────────────

ACTIVITY_CATALOG = {
    "manali": [
        {"name": "Solang Valley Snow Activities", "duration_hrs": 4, "cost": 600, "category": "adventure"},
        {"name": "Rohtang Pass Excursion", "duration_hrs": 6, "cost": 800, "category": "sightseeing"},
        {"name": "Old Manali Village Walk", "duration_hrs": 2, "cost": 0, "category": "culture"},
        {"name": "Hadimba Devi Temple", "duration_hrs": 1.5, "cost": 0, "category": "culture"},
        {"name": "Beas River Rafting", "duration_hrs": 3, "cost": 700, "category": "adventure"},
        {"name": "Naggar Castle Visit", "duration_hrs": 2, "cost": 100, "category": "sightseeing"},
        {"name": "Mall Road Shopping & Café", "duration_hrs": 2, "cost": 500, "category": "leisure"},
        {"name": "Paragliding at Solang", "duration_hrs": 2, "cost": 1200, "category": "adventure"},
        {"name": "Kullu Shawl Factory Tour", "duration_hrs": 1.5, "cost": 0, "category": "culture"},
        {"name": "Sunrise trek to Chika", "duration_hrs": 3, "cost": 200, "category": "adventure"},
    ],
    "default": [
        {"name": "City Heritage Walk", "duration_hrs": 2.5, "cost": 200, "category": "culture"},
        {"name": "Local Market Tour", "duration_hrs": 2, "cost": 300, "category": "leisure"},
        {"name": "Main Attraction Visit", "duration_hrs": 3, "cost": 400, "category": "sightseeing"},
        {"name": "Regional Cuisine Tasting", "duration_hrs": 1.5, "cost": 500, "category": "food"},
        {"name": "Nature Walk / Park", "duration_hrs": 2, "cost": 100, "category": "outdoor"},
        {"name": "Evening Cultural Show", "duration_hrs": 2.5, "cost": 600, "category": "culture"},
        {"name": "Day Trek / Hike", "duration_hrs": 5, "cost": 400, "category": "adventure"},
        {"name": "Boat Ride / Waterfront", "duration_hrs": 1.5, "cost": 300, "category": "leisure"},
    ],
}

# Activities per day by pace preference
PACE_SLOTS = {"slow": 2, "moderate": 3, "fast": 4}


# ── Core scheduler ────────────────────────────────────────────────────────────

def build_itinerary(
    *,
    variant_type: str,
    start_date: date,
    end_date: date,
    destination: str,
    transport: dict,          # Selected train or bus
    hotel: dict,              # Selected hotel
    budget_per_person: float,
    pace: str = "moderate",
    travel_style: str = "moderate",
    constraints: dict = None,
) -> dict:
    """
    Build a single day-by-day itinerary given one transport option and one hotel.
    Returns the itinerary variant dict matching the ItineraryVariant Pydantic schema.
    """
    constraints = constraints or {}
    num_days = (end_date - start_date).days
    dest_key = _normalize_dest_key(destination)
    activities = ACTIVITY_CATALOG.get(dest_key, ACTIVITY_CATALOG["default"])
    activities_filtered = _filter_activities(activities, travel_style, budget_per_person)
    n_per_day = PACE_SLOTS.get(pace, 3)

    days = []
    total_cost = 0.0
    activity_idx = 0

    for day_num in range(num_days + 1):
        current_date = start_date + timedelta(days=day_num)
        items = []

        if day_num == 0:
            # Day 1: Departure + arrive + check-in
            items.append({
                "activityName": f"{transport['trainName'] if 'trainName' in transport else transport['busOperator']} — {_origin_label(transport)} → {destination}",
                "description": f"Journey to {destination}. Duration: {transport.get('duration', 'N/A')}",
                "location": destination,
                "timeSlot": transport.get("departureTime", "07:00"),
                "startTime": transport.get("departureTime", "07:00"),
                "endTime": transport.get("arrivalTime", "14:00"),
                "transitMode": "train" if "trainNumber" in transport else "bus",
                "estimatedCost": _get_transport_fare(transport, travel_style),
                "bookingRef": transport.get("trainNumber") or transport.get("busOperator", ""),
                "apiSource": transport.get("source", "mock"),
                "rawApiData": transport,
            })
            total_cost += _get_transport_fare(transport, travel_style)

            # Hotel check-in
            items.append({
                "activityName": f"Hotel Check-in: {hotel['hotelName']}",
                "description": f"Check in at {hotel['hotelName']}. Address: {hotel.get('address', '')}",
                "location": hotel["hotelName"],
                "timeSlot": "15:00",
                "startTime": "15:00",
                "endTime": "16:00",
                "transitMode": None,
                "estimatedCost": hotel["pricePerNight"],
                "bookingRef": hotel["hotelId"],
                "apiSource": hotel.get("source", "booking"),
                "rawApiData": {k: v for k, v in hotel.items() if k != "rawApiData"},
            })
            total_cost += hotel["pricePerNight"]

            # Evening activity
            if activities_filtered:
                eve = activities_filtered[activity_idx % len(activities_filtered)]
                items.append(_make_activity_item(eve, "17:00", "19:00"))
                total_cost += eve["cost"]
                activity_idx += 1

        elif day_num == num_days:
            # Last day: checkout + return journey
            items.append({
                "activityName": f"Hotel Checkout: {hotel['hotelName']}",
                "location": hotel["hotelName"],
                "timeSlot": "10:00", "startTime": "10:00", "endTime": "11:00",
                "transitMode": None, "estimatedCost": 0,
                "apiSource": hotel.get("source"), "rawApiData": None, "bookingRef": hotel["hotelId"],
                "description": "Check out and collect luggage.",
            })

            # Morning activity before departure
            if activities_filtered:
                morning = activities_filtered[activity_idx % len(activities_filtered)]
                items.append(_make_activity_item(morning, "07:00", "09:30"))
                total_cost += morning["cost"]
                activity_idx += 1

            # Return transport (overnight or morning)
            return_dep = "14:00"
            items.append({
                "activityName": f"Return Journey: {destination} → Home",
                "description": f"Return {transport.get('duration', 'N/A')} journey back home.",
                "location": "Departure Station / Bus Stand",
                "timeSlot": return_dep, "startTime": return_dep, "endTime": None,
                "transitMode": "train" if "trainNumber" in transport else "bus",
                "estimatedCost": _get_transport_fare(transport, travel_style),
                "bookingRef": transport.get("trainNumber") or transport.get("busOperator", ""),
                "apiSource": transport.get("source", "mock"),
                "rawApiData": None,
                "description": "Return journey.",
            })
            total_cost += _get_transport_fare(transport, travel_style)

        else:
            # Middle days: activity-packed exploration
            time_slots = _generate_time_slots(n_per_day)
            for slot_start, slot_end in time_slots:
                if activities_filtered:
                    act = activities_filtered[activity_idx % len(activities_filtered)]
                    items.append(_make_activity_item(act, slot_start, slot_end))
                    total_cost += act["cost"]
                    activity_idx += 1

            # Hotel night cost
            total_cost += hotel["pricePerNight"]

            # Add meal cost (₹500/day estimate)
            items.append({
                "activityName": "Meals (Breakfast + Lunch + Dinner)",
                "description": "Local dining exploring regional cuisine.",
                "location": destination,
                "timeSlot": "13:00", "startTime": "13:00", "endTime": "14:00",
                "transitMode": None, "estimatedCost": 500,
                "bookingRef": None, "apiSource": None, "rawApiData": None,
            })
            total_cost += 500

        days.append({"dayNumber": day_num + 1, "date": current_date.isoformat(), "items": items})

    return {
        "variantType": variant_type,
        "summary": _build_summary(variant_type, destination, transport, hotel, num_days, total_cost),
        "totalCostPerPerson": round(total_cost, 2),
        "constraints": constraints,
        "days": days,
    }


# ── Variant generator ─────────────────────────────────────────────────────────

def generate_variants(
    *,
    start_date: date,
    end_date: date,
    destination: str,
    trains: list,
    buses: list,
    hotels: list,
    group_stats: dict,
    member_count: int,
) -> list[dict]:
    """
    Generates up to 5 itinerary variants from the candidate pool.
    """
    budget_avg  = _extract_budget(group_stats, "avg", 2000)
    budget_min  = _extract_budget(group_stats, "min", 1000)
    budget_max  = _extract_budget(group_stats, "max", 3000)
    pace        = _extract_pace(group_stats)
    style       = _extract_style(group_stats)

    num_days = (end_date - start_date).days

    # Pick best transport options
    best_train  = _pick_best_transport(trains, budget_avg)
    night_train = _pick_overnight(trains + buses)
    cheap_train = _pick_cheapest(trains + buses)

    # Pick hotel tiers
    best_hotel    = _pick_hotel(hotels, budget_avg * num_days / max(num_days, 1))
    budget_hotel  = _pick_hotel(hotels, budget_min * num_days / max(num_days, 1))
    premium_hotel = _pick_hotel(hotels, budget_max * num_days / max(num_days, 1), prefer_high=True)

    variants = []

    # V0 — Optimal
    if best_train and best_hotel:
        variants.append(build_itinerary(
            variant_type="optimal", start_date=start_date, end_date=end_date,
            destination=destination, transport=best_train, hotel=best_hotel,
            budget_per_person=budget_avg, pace=pace, travel_style=style,
        ))

    # V1 — Budget flex +20%
    if best_train and premium_hotel:
        variants.append(build_itinerary(
            variant_type="budget_flex_20", start_date=start_date, end_date=end_date,
            destination=destination, transport=best_train, hotel=premium_hotel,
            budget_per_person=budget_avg * 1.2, pace=pace, travel_style=style,
            constraints={"budget_increase_pct": 20},
        ))

    # V2 — Duration extend +2 days
    if best_train and best_hotel:
        variants.append(build_itinerary(
            variant_type="duration_extend_2d", start_date=start_date, end_date=end_date + timedelta(days=2),
            destination=destination, transport=best_train, hotel=best_hotel,
            budget_per_person=budget_avg, pace=pace, travel_style=style,
            constraints={"extra_days": 2},
        ))

    # V3 — Night travel (overnight train/bus → saves 1 hotel night)
    if night_train:
        night_hotel = best_hotel or budget_hotel
        if night_hotel:
            variants.append(build_itinerary(
                variant_type="night_travel", start_date=start_date, end_date=end_date,
                destination=destination, transport=night_train, hotel=night_hotel,
                budget_per_person=budget_avg, pace="fast", travel_style=style,
                constraints={"overnight_journey": True},
            ))

    # V4 — Budget strict (group_min)
    if cheap_train and budget_hotel:
        variants.append(build_itinerary(
            variant_type="budget_strict", start_date=start_date, end_date=end_date,
            destination=destination, transport=cheap_train, hotel=budget_hotel,
            budget_per_person=budget_min, pace="slow", travel_style=style,
            constraints={"budget_mode": True},
        ))

    return variants


# ── Mishap recovery algorithm ─────────────────────────────────────────────────

def recover_from_mishap(
    *,
    itinerary_items: list[dict],
    missed_item_id: str,
    current_time: datetime,
    next_available_transport: dict | None,
) -> tuple[list[dict], int]:
    """
    Re-schedules all items after the missed item.
    Returns (updated_items_list, rescheduled_count).
    """
    missed_idx = next((i for i, item in enumerate(itinerary_items) if item.get("id") == missed_item_id), -1)
    if missed_idx == -1:
        return itinerary_items, 0

    # Mark missed item
    itinerary_items[missed_idx]["isMissed"] = True

    if not next_available_transport:
        return itinerary_items, 0

    # Calculate delay
    missed_start = _parse_time(itinerary_items[missed_idx].get("startTime", "08:00"), current_time.date())
    next_dep     = _parse_time(next_available_transport.get("departureTime", "12:00"), current_time.date())
    delay_hrs    = max(0, (next_dep - missed_start).total_seconds() / 3600)

    rescheduled_count = 0
    for item in itinerary_items[missed_idx + 1:]:
        if item.get("startTime"):
            orig = _parse_time(item["startTime"], current_time.date())
            new_start = orig + timedelta(hours=delay_hrs)
            item["startTime"] = new_start.strftime("%H:%M")
            if item.get("endTime"):
                orig_end = _parse_time(item["endTime"], current_time.date())
                item["endTime"] = (orig_end + timedelta(hours=delay_hrs)).strftime("%H:%M")
            item["isRescheduled"] = True
            rescheduled_count += 1

    # Update the missed transport item to the next available
    itinerary_items[missed_idx + 1] = {
        **itinerary_items[missed_idx],
        "activityName": f"Alternative Transport: {next_available_transport.get('trainName', next_available_transport.get('busOperator', 'Next Available'))}",
        "startTime": next_available_transport.get("departureTime"),
        "endTime": next_available_transport.get("arrivalTime"),
        "isMissed": False,
        "isRescheduled": True,
        "rawApiData": next_available_transport,
    }

    return itinerary_items, rescheduled_count


# ── Private helpers ───────────────────────────────────────────────────────────

def _normalize_dest_key(dest: str) -> str:
    return dest.lower().split(",")[0].split(" ")[0]


def _filter_activities(activities: list, style: str, budget: float) -> list:
    if style == "adventure":
        order = ["adventure", "sightseeing", "culture", "leisure", "food"]
    elif style == "luxury":
        order = ["leisure", "culture", "sightseeing", "food", "adventure"]
    else:
        order = ["sightseeing", "culture", "outdoor", "food", "adventure", "leisure"]

    sorted_acts = sorted(activities, key=lambda a: order.index(a["category"]) if a["category"] in order else 99)
    return [a for a in sorted_acts if a["cost"] <= budget * 0.15]  # Activity ≤ 15% of daily budget


def _generate_time_slots(n: int) -> list[tuple[str, str]]:
    slots_map = {
        1: [("09:00", "14:00")],
        2: [("08:00", "11:00"), ("15:00", "18:00")],
        3: [("07:00", "10:00"), ("11:00", "14:00"), ("16:00", "19:00")],
        4: [("06:30", "09:00"), ("10:00", "12:30"), ("14:00", "16:30"), ("17:30", "19:30")],
    }
    return slots_map.get(n, slots_map[3])


def _make_activity_item(act: dict, start: str, end: str) -> dict:
    return {
        "activityName": act["name"],
        "description": f"{act['category'].capitalize()} activity.",
        "location": None,
        "timeSlot": start,
        "startTime": start,
        "endTime": end,
        "transitMode": None,
        "estimatedCost": act["cost"],
        "bookingRef": None,
        "apiSource": None,
        "rawApiData": None,
    }


def _get_transport_fare(transport: dict, style: str) -> float:
    if "trainNumber" in transport:
        if style == "luxury":
            return transport.get("faresSecondAC", 1400)
        elif style == "adventure" or style == "moderate":
            return transport.get("faresThirdAC", 900)
        else:
            return transport.get("faresSleeper", 600)
    return transport.get("fare", 700)


def _origin_label(transport: dict) -> str:
    return transport.get("fromStation", "Origin")


def _pick_best_transport(transports: list, budget: float) -> dict | None:
    if not transports:
        return None
    affordable = [t for t in transports if _get_transport_fare(t, "moderate") <= budget * 0.4]
    return affordable[0] if affordable else transports[0]


def _pick_overnight(transports: list) -> dict | None:
    for t in transports:
        dep_hr = _parse_hour(t.get("departureTime", ""))
        if dep_hr >= 18 or dep_hr <= 4:
            return t
    return transports[-1] if transports else None


def _pick_cheapest(transports: list) -> dict | None:
    if not transports:
        return None
    return min(transports, key=lambda t: _get_transport_fare(t, "slow"))


def _pick_hotel(hotels: list, budget: float, prefer_high: bool = False) -> dict | None:
    if not hotels:
        return None
    fits = [h for h in hotels if h["pricePerNight"] <= budget]
    if not fits:
        fits = hotels
    return max(fits, key=lambda h: h["rating"]) if prefer_high else max(fits, key=lambda h: h["rating"] / max(h["pricePerNight"], 1))


def _extract_budget(group_stats: dict, key: str, default: float) -> float:
    try:
        return float(group_stats.get("budget", {}).get(f"group_{key}", default))
    except (TypeError, ValueError):
        return default


def _extract_pace(group_stats: dict) -> str:
    try:
        return group_stats.get("pace", {}).get("majority_pace", "moderate")
    except Exception:
        return "moderate"


def _extract_style(group_stats: dict) -> str:
    try:
        return group_stats.get("travel_styles", {}).get("majority_style", "moderate")
    except Exception:
        return "moderate"


def _build_summary(variant_type: str, dest: str, transport: dict, hotel: dict, days: int, cost: float) -> str:
    labels = {
        "optimal":            f"Best-fit itinerary — {days} days in {dest}",
        "budget_flex_20":     f"Upgraded comfort (+20% budget) — {days} days in {dest}",
        "duration_extend_2d": f"Extended trip (+2 days) — {days + 2} days in {dest}",
        "night_travel":       f"Overnight travel variant — {days} days in {dest}, more daytime exploration",
        "budget_strict":      f"Budget-optimized — {days} days in {dest}, under tightest constraints",
        "mishap_recovery":    f"Recovery itinerary after schedule change",
    }
    base = labels.get(variant_type, f"{variant_type} — {days} days")
    t_name = transport.get("trainName") or transport.get("busOperator", "Transport")
    h_name = hotel.get("hotelName", "Hotel")
    return f"{base}. Transport: {t_name}. Stay: {h_name}. Est. cost/person: ₹{cost:,.0f}."


def _parse_time(time_str: str, ref_date: date) -> datetime:
    try:
        hm = time_str.strip()[:5]
        t = datetime.strptime(hm, "%H:%M")
        return datetime.combine(ref_date, t.time())
    except Exception:
        return datetime.combine(ref_date, datetime.min.time().replace(hour=9))


def _parse_hour(time_str: str) -> int:
    try:
        return int(time_str.split(":")[0])
    except Exception:
        return 9
