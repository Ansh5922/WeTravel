import math
from sqlalchemy.orm import Session
from app.repositories.consensus_repository import (
    fetch_member_vectors,
    fetch_member_profiles,
    save_consensus,
)

"""
Group Preference Service — FastAPI AI Backend
Responsibility: Compute group consensus in BOTH formats:
  1. Vector (384-dim) — for AI similarity search
  2. Human-readable groupStats JSON — for UI display and itinerary generation

Architecture layer: Service

──────────────────────────────────────────────────────────────
BUDGET TIER → NUMERIC RANGE MAPPING
──────────────────────────────────────────────────────────────
Each budget tier name maps to a numeric daily spend range (USD).
When we compute group budget stats:
  - group_min    = lowest member's tier_min
  - group_max    = highest member's tier_max
  - group_avg    = mean of all members' tier_mid values

This gives the itinerary builder 3 targets:
  → "budget itinerary"  uses group_min
  → "average itinerary" uses group_avg
  → "luxury itinerary"  uses group_max

──────────────────────────────────────────────────────────────
PACE PREFERENCE → NUMERIC MAPPING
──────────────────────────────────────────────────────────────
slow=1, moderate=2, fast=3. Group stats provide min/max/avg
so itineraries can be generated for the slowest preference
(most accessible) or the majority preference.

──────────────────────────────────────────────────────────────
DIETARY / HEALTH / CLIMATE
──────────────────────────────────────────────────────────────
These are UNION-based — the strictest constraints from any
member apply to the whole group. "If one person is vegan,
the group can't go to a steakhouse."
"""

# ── Budget tier → (min $/day, max $/day, mid $/day) ──────────────────────────
BUDGET_MAP = {
    "backpacker": (0,    500,   250),
    "budget":     (300,  1000,  650),
    "moderate":   (800,  2500,  1650),
    "luxury":     (2000, 8000,  5000),
    "ultra_luxury": (5000, 50000, 27500),
}
DEFAULT_BUDGET = (500, 2000, 1250)  # fallback if tier unknown

# ── Pace tier → numeric score ─────────────────────────────────────────────────
PACE_MAP = {"slow": 1, "moderate": 2, "fast": 3}
PACE_REVERSE = {1: "slow", 2: "moderate", 3: "fast"}


# ── Vector helpers ────────────────────────────────────────────────────────────

def _l2_norm(vector: list[float]) -> float:
    return math.sqrt(sum(x * x for x in vector))


def _normalize(vector: list[float]) -> list[float]:
    mag = _l2_norm(vector)
    return vector if mag == 0 else [x / mag for x in vector]


def _compute_group_vector(vectors: list[list[float]]) -> list[float]:
    """
    Normalised centroid of all member embedding vectors.
    Maximises average cosine similarity across all members.
    """
    n   = len(vectors)
    dim = len(vectors[0])
    centroid = [0.0] * dim
    for vec in vectors:
        for i, val in enumerate(vec):
            centroid[i] += val
    centroid = [x / n for x in centroid]
    return _normalize(centroid)


# ── Stat computation helpers ──────────────────────────────────────────────────

def _compute_budget_stats(profiles: list[dict]) -> dict:
    """
    For each member's single numerical budget preference (or legacy budget_tier fallback),
    compute group-level min, max, and average daily budget.
    """
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
    """
    Map pace strings to 1/2/3 and compute min, max, avg.
    Also records which pace describes the majority.

    Example [slow, moderate, fast, fast]:
      scores = [1, 2, 3, 3]
      min=slow, max=fast, avg=moderate
    """
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
    """
    Count how many members share each travel style.
    The itinerary builder should lean toward the majority styles.
    """
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
    """
    Union of all dietary preferences — strictest rule wins.
    "If one member is vegan, the whole group needs vegan options."
    """
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
    """
    Union of all health constraints across all members.
    Each member's constraints object is merged into one combined set.
    """
    combined: dict = {}
    members_count  = 0
    for p in profiles:
        hc = p.get("health_constraints")
        if hc:
            members_count += 1
            if isinstance(hc, dict):
                for key, val in hc.items():
                    if val:  # only include truthy constraints
                        combined[key] = combined.get(key, 0) + 1

    return {
        "combined_constraints":    combined,
        "members_with_constraints": members_count,
        "note": "Count shows how many members have each constraint. Any non-zero means the group is affected.",
    }


def _compute_climate_sensitivities(profiles: list[dict]) -> dict:
    """
    Union of all climate sensitivities across members.
    """
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


# ── Main pipeline ─────────────────────────────────────────────────────────────

def compute_and_save_group_preference(
    db: Session,
    group_id: str,
    member_ids: list[str],
) -> dict:
    """
    Full dual-format pipeline:

      member_ids
        │
        ├─► fetch_member_vectors()  → compute 384-dim consensus_vector
        │
        └─► fetch_member_profiles() → compute human-readable groupStats
                                       (budget, pace, age, styles, dietary, health, climate)
        │
        └─► save_consensus()  → writes BOTH to group_consensus_profiles in one upsert

    Returns info dict used as the API response.
    """
    # 1. Fetch embedding vectors for consensus_vector computation
    vectors = fetch_member_vectors(db, member_ids)

    # 2. Fetch profile text fields for human-readable stats computation
    profiles = fetch_member_profiles(db, member_ids)

    # 3. Compute consensus vector (may be None if no embeddings yet)
    group_vector = _compute_group_vector(vectors) if vectors else None

    # 4. Compute all human-readable stats
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

    # 5. Save both in one DB upsert
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
