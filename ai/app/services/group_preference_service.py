import math
from sqlalchemy.orm import Session
from app.repositories.consensus_repository import (
    fetch_member_vectors,
    fetch_member_profiles,
    save_consensus,
)

BUDGET_MAP = {
    "backpacker": (0,    500,   250),
    "budget":     (300,  1000,  650),
    "moderate":   (800,  2500,  1650),
    "luxury":     (2000, 8000,  5000),
    "ultra_luxury": (5000, 50000, 27500),
}
DEFAULT_BUDGET = (500, 2000, 1250)

PACE_MAP = {"slow": 1, "moderate": 2, "fast": 3}
PACE_REVERSE = {1: "slow", 2: "moderate", 3: "fast"}


def _l2_norm(vector: list[float]) -> float:
    # Compute Euclidean L2 norm of a vector
    return math.sqrt(sum(x * x for x in vector))


def _normalize(vector: list[float]) -> list[float]:
    # Normalize vector to unit length
    mag = _l2_norm(vector)
    return vector if mag == 0 else [x / mag for x in vector]


def _compute_group_vector(vectors: list[list[float]]) -> list[float]:
    # Compute normalized centroid vector across all member embeddings
    n   = len(vectors)
    dim = len(vectors[0])
    centroid = [0.0] * dim
    for vec in vectors:
        for i, val in enumerate(vec):
            centroid[i] += val
    centroid = [x / n for x in centroid]
    return _normalize(centroid)


def _compute_budget_stats(profiles: list[dict]) -> dict:
    # Compute group-level min, max, and average daily budget statistics
    user_budgets = []

    for p in profiles:
        b_val = p.get("budget")
        tier = p.get("budget_tier")

        if b_val is not None:
            user_budgets.append(float(b_val))
        elif tier:
            key = (tier or "").lower()
            _, _, mid_val = BUDGET_MAP.get(key, DEFAULT_BUDGET)
            user_budgets.append(float(mid_val))

    if not user_budgets:
        return {
            "group_min": None,
            "group_max": None,
            "group_avg": None,
            "currency": "USD",
            "members_with_preference": 0,
        }

    group_min = min(user_budgets)
    group_max = max(user_budgets)
    group_avg = round(sum(user_budgets) / len(user_budgets), 2)

    return {
        "group_min":                group_min,
        "group_max":                group_max,
        "group_avg":                group_avg,
        "currency":                 "USD",
        "members_with_preference":  len(user_budgets),
        "note": (
            f"group_min={group_min} (lowest member preference), "
            f"group_max={group_max} (highest member preference), "
            f"group_avg={group_avg} (average member preference)"
        ),
    }


def _compute_pace_stats(profiles: list[dict]) -> dict:
    # Compute group pace distribution and determine majority preference
    paces = [p["pace_preference"] for p in profiles if p.get("pace_preference")]
    if not paces:
        return {"group_min": None, "group_max": None, "group_avg": None,
                "members_with_preference": 0, "pace_distribution": {}}

    scores = [PACE_MAP.get((p or "").lower(), 2) for p in paces]
    avg_score = round(sum(scores) / len(scores))

    pace_distribution: dict[str, int] = {}
    for p in paces:
        pace_distribution[p] = pace_distribution.get(p, 0) + 1

    majority_pace = max(pace_distribution, key=pace_distribution.get)

    return {
        "group_min":               PACE_REVERSE.get(min(scores), "slow"),
        "group_max":               PACE_REVERSE.get(max(scores), "fast"),
        "group_avg":               PACE_REVERSE.get(avg_score, "moderate"),
        "majority_pace":           majority_pace,
        "members_with_preference": len(paces),
        "pace_distribution":       pace_distribution,
    }


def _compute_age_stats(profiles: list[dict]) -> dict:
    # Compute member age summary statistics
    ages = [p["age"] for p in profiles if p.get("age") is not None]
    if not ages:
        return {"min": None, "max": None, "avg": None, "members_with_age": 0}
    return {
        "min":             min(ages),
        "max":             max(ages),
        "avg":             round(sum(ages) / len(ages), 1),
        "members_with_age": len(ages),
    }


def _compute_travel_styles(profiles: list[dict]) -> dict:
    # Aggregate member travel style preferences and determine majority style
    styles = [p["travel_style"] for p in profiles if p.get("travel_style")]
    if not styles:
        return {"all_styles": [], "style_distribution": {}, "majority_style": None}

    distribution: dict[str, int] = {}
    for s in styles:
        distribution[s] = distribution.get(s, 0) + 1

    majority = max(distribution, key=distribution.get)
    return {
        "all_styles":         list(set(styles)),
        "style_distribution": distribution,
        "majority_style":     majority,
        "members_count":      len(styles),
    }


def _compute_dietary(profiles: list[dict]) -> dict:
    # Aggregate dietary requirements using union logic to satisfy all members
    items = [p["dietary_preference"] for p in profiles if p.get("dietary_preference")]
    distribution: dict[str, int] = {}
    for d in items:
        distribution[d] = distribution.get(d, 0) + 1

    return {
        "all_preferences":    list(set(items)),
        "distribution":       distribution,
        "members_with_pref":  len(items),
        "strict_mode":        True,
        "note":               "All dietary constraints must be satisfied simultaneously.",
    }


def _compute_health_constraints(profiles: list[dict]) -> dict:
    # Aggregate member health constraints into a combined map
    combined: dict = {}
    members_count  = 0
    for p in profiles:
        hc = p.get("health_constraints")
        if hc:
            members_count += 1
            if isinstance(hc, dict):
                for key, val in hc.items():
                    if val:
                        combined[key] = combined.get(key, 0) + 1

    return {
        "combined_constraints":    combined,
        "members_with_constraints": members_count,
        "note": "Count shows how many members have each constraint. Any non-zero means the group is affected.",
    }


def _compute_climate_sensitivities(profiles: list[dict]) -> dict:
    # Aggregate climate sensitivities across all group members
    combined: dict = {}
    members_count  = 0
    for p in profiles:
        cs = p.get("climate_sensitivities")
        if cs:
            members_count += 1
            if isinstance(cs, dict):
                for key, val in cs.items():
                    if val:
                        combined[key] = combined.get(key, 0) + 1

    return {
        "combined_sensitivities":   combined,
        "members_with_sensitivities": members_count,
        "note": "Count shows how many members share each climate sensitivity.",
    }


def compute_and_save_group_preference(
    db: Session,
    group_id: str,
    member_ids: list[str],
) -> dict:
    # Compute group consensus vector and aggregate preference stats, then persist to DB
    vectors = fetch_member_vectors(db, member_ids)
    profiles = fetch_member_profiles(db, member_ids)
    group_vector = _compute_group_vector(vectors) if vectors else None

    group_stats = {
        "member_count":         len(member_ids),
        "profiles_found":       len(profiles),
        "budget":               _compute_budget_stats(profiles),
        "pace":                 _compute_pace_stats(profiles),
        "age":                  _compute_age_stats(profiles),
        "travel_styles":        _compute_travel_styles(profiles),
        "dietary":              _compute_dietary(profiles),
        "health_constraints":   _compute_health_constraints(profiles),
        "climate_sensitivities": _compute_climate_sensitivities(profiles),
    }

    save_consensus(db, group_id, group_vector, group_stats)

    return {
        "group_id":         group_id,
        "members_computed": len(vectors),
        "vector_dimensions": len(group_vector) if group_vector else 0,
        "message": (
            f"Group preference computed: {len(profiles)} profile(s) found, "
            f"{len(vectors)} embedding(s) averaged."
        ),
    }
