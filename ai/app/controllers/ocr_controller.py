from sqlalchemy.orm import Session
from app.schemas.expense import OcrReceiptRequest, OcrReceiptResponse
from app.services.ocr_service import process_receipt
from app.services.interaction_service import create_interaction_embedding

def handle_ocr_receipt(
    payload: OcrReceiptRequest,
    db: Session,
) -> OcrReceiptResponse:
    # Controller for processing receipt image and returning extracted total
    result = process_receipt(payload.image_url)

    # Store interaction embedding if OCR succeeded — this embedding is
    # retained permanently even after chats expire and contributes to the
    # group's AI context for future itinerary generation
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
