from pydantic import BaseModel
from typing import Optional


class OcrReceiptRequest(BaseModel):
    # Payload sent by backend service after receipt image upload
    expense_id: Optional[str] = None
    image_url: str
    group_id: Optional[str] = None


class OcrReceiptResponse(BaseModel):
    # Response returned after OCR processing on a receipt image
    status: str
    expense_id: Optional[str] = None
    title: Optional[str] = None
    merchant: Optional[str] = None
    amount: Optional[float] = None
    currency: str = "INR"
    category: Optional[str] = None
    raw_text: Optional[str] = None
    message: str = ""
