from pydantic import BaseModel
from typing import Optional, Any


class OcrReceiptRequest(BaseModel):
    """
    Payload sent by Node.js backend after a user uploads a receipt image.
    Architecture layer: Schemas (Pydantic validation)

    Node.js sends the ImageKit CDN URL of the uploaded receipt photo.
    FastAPI fetches the image, runs OCR, and returns the extracted amount.
    """
    expense_id: str       # UUID of the expense record in Postgres
    image_url:  str       # Public CDN URL of the uploaded receipt (ImageKit)
    group_id:   str       # Group UUID — used to store interaction embedding


class OcrReceiptResponse(BaseModel):
    """
    Response returned to Node.js after OCR processing.

    Node.js uses `amount` to update the expense record and `category`
    to pre-fill the category field.  `raw_text` is stored as audit trail
    in `expenses.ocr_raw_metadata`.
    """
    status:     str
    expense_id: str
    amount:     Optional[float] = None    # None if extraction failed
    currency:   str = "INR"
    category:   Optional[str] = None
    raw_text:   Optional[str] = None      # Full OCR output for audit
    message:    str = ""
