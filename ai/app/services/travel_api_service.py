import os
import httpx

"""
Travel API Service — WeTravel AI Backend
Layer: Service (external API wrapper)

Integrations:
  - Trains:  Indian Railway IRCTC via RapidAPI (indian-railway-irctc.p.rapidapi.com)
  - Hotels:  Booking.com via RapidAPI (booking-com15.p.rapidapi.com)
  - Buses:   Mock data (RedBus key not yet configured)

To swap in real bus keys:
  1. Add RAPIDAPI_KEY to ai/.env
  2. Replace _mock_buses() return with a real httpx call
"""

RAPIDAPI_KEY = os.getenv("RAPIDAPI_KEY", "310a22e009msh27b357835fe98edp179b08jsn6eed694c1863")

TRAIN_HOST  = "indian-railway-irctc.p.rapidapi.com"
HOTEL_HOST  = "booking-com15.p.rapidapi.com"

RAPIDAPI_HEADERS = {
    "Content-Type": "application/json",
    "x-rapidapi-key": RAPIDAPI_KEY,
}


# ── Trains ───────────────────────────────────────────────────────────────────

async def fetch_trains(origin_code: str, destination_code: str, departure_date: str) -> list[dict]:
    """
    Fetch available trains from RailwayAPI (IRCTC via RapidAPI).
    departure_date format: YYYYMMDD
    Returns list of train dicts: { train_number, train_name, departure_time, arrival_time, duration, fare_sleeper, fare_3ac, fare_2ac, available_seats }
    """
    url = f"https://{TRAIN_HOST}/api/trains/v1/train/betweenStations"
    params = {
        "trainNo": "",
        "fromStation": origin_code,
        "toStation": destination_code,
        "date": departure_date,
        "isH5": "true",
        "client": "web",
    }
    headers = {**RAPIDAPI_HEADERS, "x-rapidapi-host": TRAIN_HOST, "x-rapid-api": "rapid-api-database"}

    try:
        async with httpx.AsyncClient(timeout=15) as client:
            response = await client.get(url, headers=headers, params=params)
            response.raise_for_status()
            data = response.json()
            trains = data.get("data", {}).get("trainList", [])
            return _normalize_trains(trains, departure_date)
    except Exception as e:
        print(f"[TravelAPI] Train fetch failed ({e}), using mock data.")
        return _mock_trains(origin_code, destination_code, departure_date)


def _normalize_trains(raw_trains: list, departure_date: str) -> list[dict]:
    result = []
    for t in raw_trains[:10]:  # Cap at 10 trains
        try:
            result.append({
                "trainNumber":    t.get("trainNumber", ""),
                "trainName":      t.get("trainName", "Unknown Train"),
                "departureTime":  t.get("departureTime", "06:00"),
                "arrivalTime":    t.get("arrivalTime", "14:00"),
                "duration":       t.get("duration", "8h 00m"),
                "faresSleeper":   _safe_float(t.get("fare", {}).get("sleeper", 500)),
                "faresThirdAC":   _safe_float(t.get("fare", {}).get("3A", 900)),
                "faresSecondAC":  _safe_float(t.get("fare", {}).get("2A", 1400)),
                "availableSeats": t.get("availableSeats", 20),
                "departureDate":  departure_date,
                "source":         "railwayapi",
            })
        except Exception:
            continue
    return result if result else _mock_trains("", "", departure_date)


def _mock_trains(origin: str, destination: str, departure_date: str) -> list[dict]:
    return [
        {
            "trainNumber": "12051", "trainName": "Shatabdi Express",
            "departureTime": "07:20", "arrivalTime": "13:45",
            "duration": "6h 25m",
            "faresSleeper": 650, "faresThirdAC": 1100, "faresSecondAC": 1550,
            "availableSeats": 30, "departureDate": departure_date, "source": "mock",
        },
        {
            "trainNumber": "14553", "trainName": "Himachal Express",
            "departureTime": "20:00", "arrivalTime": "06:00",
            "duration": "10h 00m",
            "faresSleeper": 450, "faresThirdAC": 900, "faresSecondAC": 1300,
            "availableSeats": 45, "departureDate": departure_date, "source": "mock",
        },
        {
            "trainNumber": "22687", "trainName": "Delhi Rajdhani",
            "departureTime": "16:35", "arrivalTime": "22:55",
            "duration": "6h 20m",
            "faresSleeper": 800, "faresThirdAC": 1350, "faresSecondAC": 1900,
            "availableSeats": 15, "departureDate": departure_date, "source": "mock",
        },
    ]


# ── Hotels ───────────────────────────────────────────────────────────────────

async def fetch_hotels(destination: str, checkin_date: str, checkout_date: str, guests: int, max_price_per_night: float) -> list[dict]:
    """
    Fetch available hotels from Booking.com via RapidAPI.
    Returns list of hotel dicts: { hotelId, hotelName, pricePerNight, rating, address, imageUrl }
    """
    url = f"https://{HOTEL_HOST}/api/v1/hotels/searchHotels"
    params = {
        "dest_id": destination,
        "search_type": "city",
        "arrival_date": checkin_date,
        "departure_date": checkout_date,
        "adults": str(guests),
        "room_qty": "1",
        "page_number": "1",
        "units": "metric",
        "temperature_unit": "c",
        "languagecode": "en-us",
        "currency_code": "INR",
    }
    headers = {**RAPIDAPI_HEADERS, "x-rapidapi-host": HOTEL_HOST}

    try:
        async with httpx.AsyncClient(timeout=15) as client:
            response = await client.get(url, headers=headers, params=params)
            response.raise_for_status()
            data = response.json()
            hotels = data.get("data", {}).get("hotels", [])
            return _normalize_hotels(hotels, max_price_per_night, checkin_date, checkout_date)
    except Exception as e:
        print(f"[TravelAPI] Hotel fetch failed ({e}), using mock data.")
        return _mock_hotels(destination, checkin_date, checkout_date, max_price_per_night)


def _normalize_hotels(raw_hotels: list, max_price: float, checkin: str, checkout: str) -> list[dict]:
    result = []
    for h in raw_hotels[:15]:
        try:
            price = _safe_float(h.get("priceBreakdown", {}).get("grossPrice", {}).get("value", 2000))
            if price > max_price * 1.2:
                continue
            result.append({
                "hotelId":        str(h.get("hotelId", "")),
                "hotelName":      h.get("name", "Hotel"),
                "pricePerNight":  price,
                "rating":         _safe_float(h.get("reviewScore", 7.0)),
                "address":        h.get("address", ""),
                "checkin":        checkin,
                "checkout":       checkout,
                "imageUrl":       (h.get("photoUrls") or [""])[0],
                "source":         "booking",
            })
        except Exception:
            continue
    return sorted(result, key=lambda x: -x["rating"]) if result else _mock_hotels("", checkin, checkout, max_price)


def _mock_hotels(destination: str, checkin: str, checkout: str, max_price: float) -> list[dict]:
    budget_cap = max_price or 2000
    return [
        {"hotelId": "H001", "hotelName": "Snow Valley Resorts",
         "pricePerNight": min(1800, budget_cap), "rating": 8.2,
         "address": "Mall Road, Manali", "checkin": checkin, "checkout": checkout, "imageUrl": "", "source": "mock"},
        {"hotelId": "H002", "hotelName": "Beas Riverside Camp",
         "pricePerNight": min(900, budget_cap), "rating": 7.5,
         "address": "Old Manali", "checkin": checkin, "checkout": checkout, "imageUrl": "", "source": "mock"},
        {"hotelId": "H003", "hotelName": "The Himalayan Hotel",
         "pricePerNight": min(2400, budget_cap * 1.2), "rating": 8.7,
         "address": "Circuit House Road, Manali", "checkin": checkin, "checkout": checkout, "imageUrl": "", "source": "mock"},
        {"hotelId": "H004", "hotelName": "Mountain Hostel Manali",
         "pricePerNight": min(400, budget_cap * 0.4), "rating": 7.0,
         "address": "Old Manali Road", "checkin": checkin, "checkout": checkout, "imageUrl": "", "source": "mock"},
    ]


# ── Buses (Mock — swap with RedBus API when key is available) ─────────────────

async def fetch_buses(origin: str, destination: str, departure_date: str) -> list[dict]:
    """
    Mock bus data. Replace with RedBus or AbhiBus API call when API key is available.
    """
    return _mock_buses(origin, destination, departure_date)


def _mock_buses(origin: str, destination: str, departure_date: str) -> list[dict]:
    return [
        {"busOperator": "HRTC Volvo", "busType": "Volvo AC Semi-Sleeper",
         "departureTime": "18:00", "arrivalTime": "06:00", "duration": "12h 00m",
         "fare": 900, "availableSeats": 20, "departureDate": departure_date, "source": "mock"},
        {"busOperator": "Manali Travels", "busType": "Non-AC Sleeper",
         "departureTime": "21:00", "arrivalTime": "08:30", "duration": "11h 30m",
         "fare": 550, "availableSeats": 35, "departureDate": departure_date, "source": "mock"},
    ]


# ── Helpers ───────────────────────────────────────────────────────────────────

def _safe_float(val, default=0.0) -> float:
    try:
        return float(val)
    except (TypeError, ValueError):
        return default
