from sqlalchemy.orm import Session
from sqlalchemy import text
from app.services.embedding_service import get_embedding_model


def create_interaction_embedding(
    *,
    db: Session,
    group_id: str,
    source_type: str,
    source_id: str | None,
    summary_text: str,
) -> dict:
    # Generate embedding for interaction summary and save to interaction_embeddings table
    model = get_embedding_model()
    embedding = model.encode(summary_text).tolist()
    vector_str = "[" + ",".join(str(v) for v in embedding) + "]"

    db.execute(text("""
        INSERT INTO interaction_embeddings
            (id, group_id, source_type, source_id, summary_text, context_vector)
        VALUES
            (gen_random_uuid(), :group_id, :source_type, :source_id, :summary_text, :vector::vector(384))
    """), {
        "group_id": group_id,
        "source_type": source_type,
        "source_id": source_id,
        "summary_text": summary_text,
        "vector": vector_str,
    })
    db.commit()

    print(f"[InteractionService] Embedding saved for group {group_id}, type={source_type}")

    return {
        "group_id": group_id,
        "source_type": source_type,
        "vector_dimensions": len(embedding),
    }
