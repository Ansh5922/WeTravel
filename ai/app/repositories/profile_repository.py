from sqlalchemy.orm import Session
from sqlalchemy import text


def update_preference_vector(db: Session, user_id: str, vector: list[float]) -> bool:
    # Upsert 384-dimensional preference vector for a user profile in database
    vector_str = '[' + ','.join(str(v) for v in vector) + ']'

    db.execute(
        text("""
            INSERT INTO user_profiles (user_id, preference_vector)
            VALUES (:user_id, CAST(:vector AS vector))
            ON CONFLICT (user_id)
            DO UPDATE SET preference_vector = EXCLUDED.preference_vector
        """),
        {"user_id": user_id, "vector": vector_str}
    )

    db.commit()
    return True
