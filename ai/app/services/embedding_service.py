import os
import threading
from typing import Optional, Any
from sqlalchemy.orm import Session
from app.repositories.profile_repository import update_preference_vector

# Suppress HuggingFace hub symlink and tokenizers parallelism warnings
os.environ["HF_HUB_DISABLE_SYMLINKS_WARNING"] = "1"
os.environ["TOKENIZERS_PARALLELISM"] = "false"

# Global model singleton and thread lock
_model: Optional[Any] = None
_model_lock = threading.Lock()

# Load SentenceTransformer model into RAM with thread safety and cache preference
def load_embedding_model() -> Any:
    global _model
    if _model is not None:
        return _model

    with _model_lock:
        if _model is None:
            model_target = os.getenv("MODEL_NAME_OR_PATH", "all-MiniLM-L6-v2")
            print(f"[Embedding Service] Loading SentenceTransformer model ({model_target}) into RAM...")
            from sentence_transformers import SentenceTransformer
            import torch

            device = "cuda" if torch.cuda.is_available() else "cpu"

            try:
                # 1. Try local cache or pre-baked directory first
                _model = SentenceTransformer(model_target, local_files_only=True, device=device)
                print(f"[Embedding Service] [OK] Model loaded from local cache on device '{device}'.")
            except Exception as local_err:
                # 2. Fallback to downloading if local cache is not populated
                try:
                    print(f"[Embedding Service] Local files not found ({local_err}). Fetching model from HuggingFace...")
                    _model = SentenceTransformer(model_target, device=device)
                    print(f"[Embedding Service] [OK] Model downloaded and ready on device '{device}'.")
                except Exception as net_err:
                    raise RuntimeError(
                        f"[Embedding Service] Failed to load model '{model_target}'. "
                        f"For container/offline deployment, ensure weights are pre-cached in HF_HOME "
                        f"or provide MODEL_NAME_OR_PATH. Error: {net_err}"
                    ) from net_err
    return _model

# Return the loaded SentenceTransformer singleton (lazy loading if not yet initialized)
def get_embedding_model() -> Any:
    if _model is None:
        return load_embedding_model()
    return _model

# Generate normalized 384-dimensional vector embedding for text
def generate_preference_embedding(text: str) -> list[float]:
    if not text or not text.strip():
        raise ValueError("Preference text cannot be empty")

    model = get_embedding_model()
    embedding = model.encode(text, normalize_embeddings=True)
    return embedding.tolist()

# Full pipeline: text -> embedding vector -> save to DB
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
