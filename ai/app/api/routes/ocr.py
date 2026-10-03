from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.middleware.auth import get_current_user
from app.core.database import get_db
from app.schemas.expense import OcrReceiptRequest, OcrReceiptResponse
from app.controllers.ocr_controller import handle_ocr_receipt

router = APIRouter(prefix="/api/ai/ocr", tags=["OCR"])

# Extract payment amount from a receipt image via OCR
@router.post(
    "/receipt",
    response_model=OcrReceiptResponse,
    summary="Extract payment amount from a receipt image",
)
async def handle_receipt_ocr(
    payload:      OcrReceiptRequest,
    current_user: dict    = Depends(get_current_user),
    db:           Session = Depends(get_db),
):
    # Run OCR on receipt image and extract monetary total
    return handle_ocr_receipt(payload=payload, db=db)
