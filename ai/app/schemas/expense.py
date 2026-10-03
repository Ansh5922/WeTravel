from pydantic import BaseModel
from typing import Optional


class OcrReceiptRequest(BaseModel):
    # Payload sent by backend service after receipt image upload
    expense_id: str
    image_url: str
    group_id: str


class OcrReceiptResponse(BaseModel):
    # Response returned after OCR processing on a receipt image
    status: str
    expense_id: str
    amount: Optional[float] = None
    currency: str = "INR"
    category: Optional[str] = None
    raw_text: Optional[str] = None
    message: str = ""
