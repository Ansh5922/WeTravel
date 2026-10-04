from sqlalchemy.orm import Session
from app.schemas.expense import OcrReceiptRequest, OcrReceiptResponse
from app.services.ocr_service import process_receipt
from app.services.interaction_service import create_interaction_embedding

"""
OCR Controller — WeTravel AI Backend
Layer: Controller (between Routes ↔ Service)
Architecture: Routes → Controller → Service → Repository → DB

Responsibility:
  - Receive the validated Pydantic payload from the route
  - Call ocr_service.process_receipt() to run the OCR pipeline
  - Optionally persist a context embedding for the receipt summary
  - Build and return the OcrReceiptResponse
  - NEVER contain business/ML logic
"""


def handle_ocr_receipt(
    payload: OcrReceiptRequest,
    db: Session,
) -> OcrReceiptResponse:
    """
    Controller for POST /api/ai/ocr/receipt

    Receives the receipt image URL from Node.js, runs the full OCR pipeline,
    stores a semantic interaction embedding of the result, and returns the
    extracted amount so Node.js can update the expense record.
    """
    # 1. Run OCR pipeline (fetch image → Tesseract → regex extract)
    result = process_receipt(payload.image_url)

    # 2. Store interaction embedding if OCR succeeded — this embedding is
    #    retained permanently even after chats expire and contributes to the
    #    group's AI context for future itinerary generation.
    if result["success"] and result["amount"]:
        summary_text = (
            f"Receipt expense of ₹{result['amount']} ({result['currency']}) "
            f"in category '{result['category'] or 'misc'}' "
            f"submitted for group {payload.group_id}."
        )
        try:
            create_interaction_embedding(
                db=db,
                group_id=payload.group_id,
                source_type="receipt_summary",
                source_id=payload.expense_id,
                summary_text=summary_text,
            )
        except Exception as embed_err:
            # Embedding failure must never block the OCR response
            print(f"[OCR Controller] Embedding save failed (non-fatal): {embed_err}")

    return OcrReceiptResponse(
        status=     "success" if result["success"] else "partial",
        expense_id= payload.expense_id,
        amount=     result.get("amount"),
        currency=   result.get("currency", "INR"),
        category=   result.get("category"),
        raw_text=   result.get("raw_text", ""),
        message=    result.get("message", ""),
    )
