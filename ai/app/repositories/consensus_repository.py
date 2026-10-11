import json
from sqlalchemy.orm import Session
from sqlalchemy import text


def fetch_member_vectors(db: Session, member_ids: list[str]) -> list[list[float]]:
    # Fetch preference vectors for specified members from database
    if not member_ids:
        return []

    placeholders = ', '.join(f':id_{i}' for i in range(len(member_ids)))
    params       = {f'id_{i}': uid for i, uid in enumerate(member_ids)}

    rows = db.execute(
        text(f"""
            SELECT preference_vector::text
            FROM   user_profiles
            WHERE  user_id IN ({placeholders})
              AND  preference_vector IS NOT NULL
        """),
        params,
    ).fetchall()

    vectors = []
    for (vec_str,) in rows:
        cleaned = vec_str.strip('[]')
        floats  = [float(x) for x in cleaned.split(',')]
        vectors.append(floats)

    return vectors


def fetch_member_profiles(db: Session, member_ids: list[str]) -> list[dict]:
    # Fetch profile preference attributes for specified members
    if not member_ids:
        return []

    placeholders = ', '.join(f':id_{i}' for i in range(len(member_ids)))
    params       = {f'id_{i}': uid for i, uid in enumerate(member_ids)}

    rows = db.execute(
        text(f"""
            SELECT
                user_id,
                age,
                dietary_preference,
                travel_style,
                budget,
                budget_tier,
                pace_preference,
                health_constraints,
                climate_sensitivities,
                raw_preference_notes
            FROM user_profiles
            WHERE user_id IN ({placeholders})
        """),
        params,
    ).fetchall()

    profiles = []
    for row in rows:
        profiles.append({
            "user_id":               str(row[0]),
            "age":                   row[1],
            "dietary_preference":    row[2],
            "travel_style":         row[3],
            "budget":                float(row[4]) if row[4] is not None else None,
            "budget_tier":          row[5],
            "pace_preference":      row[6],
            "health_constraints":   row[7],
            "climate_sensitivities": row[8],
            "raw_preference_notes": row[9],
        })

    return profiles


def save_consensus(
    db: Session,
    group_id: str,
    vector: list[float] | None,
    group_stats: dict,
) -> bool:
    # Upsert consensus vector and aggregated stats into group_consensus_profiles
    stats_json  = json.dumps(group_stats)
    budget_json = json.dumps(group_stats.get("budget", {}))

    if vector is not None:
        vector_str = '[' + ','.join(str(v) for v in vector) + ']'
        db.execute(
            text("""
                INSERT INTO group_consensus_profiles
                    (id, group_id, consensus_vector, group_stats, computed_budget_range)
                VALUES
                    (gen_random_uuid(), :group_id, CAST(:vector AS vector),
                     CAST(:stats AS jsonb), CAST(:budget AS jsonb))
                ON CONFLICT (group_id) DO UPDATE
                    SET consensus_vector      = EXCLUDED.consensus_vector,
                        group_stats           = EXCLUDED.group_stats,
                        computed_budget_range = EXCLUDED.computed_budget_range
            """),
            {"group_id": group_id, "vector": vector_str,
             "stats": stats_json, "budget": budget_json},
        )
    else:
        # No vectors yet — save only text stats so the UI still has data
        db.execute(
            text("""
                INSERT INTO group_consensus_profiles
                    (id, group_id, group_stats, computed_budget_range)
                VALUES
                    (gen_random_uuid(), :group_id,
                     CAST(:stats AS jsonb), CAST(:budget AS jsonb))
                ON CONFLICT (group_id) DO UPDATE
                    SET group_stats           = EXCLUDED.group_stats,
                        computed_budget_range = EXCLUDED.computed_budget_range
            """),
            {"group_id": group_id, "stats": stats_json, "budget": budget_json},
        )

    db.commit()
    return True
