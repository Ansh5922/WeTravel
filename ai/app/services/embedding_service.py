from sqlalchemy.orm import Session
from app.repositories.profile_repository import update_preference_vector

"""
Embedding Service — FastAPI AI Backend
Responsibility: Generate preference vector embeddings and persist them.
Architecture layer: Service (orchestrates model + repository)

Uses sentence-transformers `all-MiniLM-L6-v2` which outputs 384-dimensional
vectors — exactly matching the vector(384) column in user_profiles.

The model is loaded once at module level (singleton) for performance.
"""

from sentence_transformers import SentenceTransformer

# Load model once at startup — this avoids reinitializing on every request
print("[Embedding Service] Loading sentence-transformers model...")
_model = SentenceTransformer("all-MiniLM-L6-v2")
print("[Embedding Service] ✅ Model loaded.")


def generate_preference_embedding(text: str) -> list[float]:
    """
    Convert a preference text string into a 384-dimensional embedding vector.

    Args:
        text: Natural language preference string built by Node.js

    Returns:
        List of 384 floats
    """
    if not text or not text.strip():
        raise ValueError("Preference text cannot be empty")

    embedding = _model.encode(text, normalize_embeddings=True)
    return embedding.tolist()


def create_and_save_preference_embedding(
    db: Session,
    user_id: str,
    preference_text: str,
) -> dict:
    """
    Full pipeline: text → embedding vector → save to DB.

    Args:
        db:               SQLAlchemy database session
        user_id:          User UUID string
        preference_text:  Natural language preference string

    Returns:
        dict with status and vector_dimensions
    """
    # 1. Generate embedding vector
    vector = generate_preference_embedding(preference_text)

    # 2. Persist to user_profiles.preference_vector
    update_preference_vector(db, user_id, vector)

    return {
        "user_id": user_id,
        "vector_dimensions": len(vector),
    }
