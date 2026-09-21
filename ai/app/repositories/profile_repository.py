from sqlalchemy.orm import Session
from sqlalchemy import text

"""
Profile Repository — FastAPI AI Backend
Responsibility: Raw database write operations for user_profiles table.
Architecture layer: Repository → Database

Uses raw SQL with pgvector's vector casting because SQLAlchemy ORM
doesn't natively handle the vector(384) column type.
"""


def update_preference_vector(db: Session, user_id: str, vector: list[float]) -> bool:
    """
    Upsert the preference_vector in the user_profiles table.
    Inserts the row if it doesn't exist, or updates the vector if it does.

    Args:
        db:      SQLAlchemy session
        user_id: UUID string of the user
        vector:  List of 384 floats (the embedding)

    Returns:
        True if successful
    """
    # Convert Python list to PostgreSQL vector literal: '[0.1, 0.2, ...]'
    vector_str = '[' + ','.join(str(v) for v in vector) + ']'

    db.execute(
        text("""
            INSERT INTO user_profiles (user_id, preference_vector)
            VALUES (:user_id, :vector::vector)
            ON CONFLICT (user_id)
            DO UPDATE SET preference_vector = EXCLUDED.preference_vector
        """),
        {"user_id": user_id, "vector": vector_str}
    )
    db.commit()
    return True
