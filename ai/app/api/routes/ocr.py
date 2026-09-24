from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.middleware.auth import get_current_user
from app.core.database import get_db
from app.schemas.expense import OcrReceiptRequest, OcrReceiptResponse
from app.controllers.ocr_controller import handle_ocr_receipt

"""
OCR Routes — WeTravel AI Backend
Layer: Routes (defines endpoints, wires middleware → controller)
Architecture: Routes → Controller → Service → Repository → DB

Responsibility:
  - Define API endpoint paths and HTTP methods
  - Wire JWT middleware (Depends) and DB session injection
  - Delegate ALL request handling to the controller
  - NEVER contain business logic or response construction
"""

router = APIRouter(prefix="/api/ai/ocr", tags=["OCR"])


@router.post(
    "/receipt",
    response_model=OcrReceiptResponse,
    summary="Extract payment amount from a receipt image",
    description="""
**Internal endpoint — called by Node.js backend, NOT the client directly.**

After a user uploads a receipt photo to ImageKit and the frontend sends
the CDN URL to Node.js, Node.js fires an async (fire-and-forget) POST here.

Pipeline:
1. Fetch the receipt image from the ImageKit CDN URL.
2. Run Tesseract OCR to extract all text from the image.
3. Apply regex patterns to identify the total / grand-total amount.
4. Guess the expense category from text keywords (food, transit, stay, …).
5. Store a semantic embedding of the receipt summary in `interaction_embeddings`.

Returns the extracted amount (and optional category) so Node.js can update
the `expenses` record and notify connected clients via WebSocket
(`EXPENSE_OCR_COMPLETED`).

**Requires the `pytesseract` package + Tesseract binary installed on the server.**
If OCR libraries are missing, the endpoint returns `amount: null` — Node.js
will then prompt the user to enter the amount manually.
    """,
)
async def handle_receipt_ocr(
    payload:      OcrReceiptRequest,
    current_user: dict    = Depends(get_current_user),
    db:           Session = Depends(get_db),
):
    return handle_ocr_receipt(payload=payload, db=db)
