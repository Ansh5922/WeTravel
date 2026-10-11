import os
from sqlalchemy.orm import Session
from sentence_transformers import SentenceTransformer
from app.repositories.profile_repository import update_preference_vector


# Suppress HuggingFace hub symlink warning
os.environ["HF_HUB_DISABLE_SYMLINKS_WARNING"] = "1"

# Load model — tries local disk cache first so it never downloads over network again
print("[Embedding Service] Loading model from local cache...")
try:
    _model = SentenceTransformer("all-MiniLM-L6-v2", local_files_only=True)
except Exception:
    _model = SentenceTransformer("all-MiniLM-L6-v2")

print("[Embedding Service] [OK] Model ready in RAM.")


def get_embedding_model():
    return _model


def generate_preference_embedding(text: str) -> list[float]:
    # Generate normalized 384-dimensional vector embedding for text
    if not text or not text.strip():
        raise ValueError("Preference text cannot be empty")

    embedding = _model.encode(text, normalize_embeddings=True)
    return embedding.tolist()


def create_and_save_preference_embedding(
    db: Session,
    user_id: str,
    preference_text: str,
) -> dict:
    # 1. Generate embedding vector
    vector = generate_preference_embedding(preference_text)

    # 2. Persist to user_profiles.preference_vector
    update_preference_vector(db, user_id, vector)
    return {
        "user_id": user_id,
        "vector_dimensions": len(vector),
    }
