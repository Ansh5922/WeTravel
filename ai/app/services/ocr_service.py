import re
import io
from typing import Optional
import httpx

_AMOUNT_RE = re.compile(
    r'(?:[₹]|Rs\.?|INR|Total|Grand\s*Total|Amount\s*Paid|Net\s*Amount|Paid)'
    r'\s*:?\s*([0-9]{1,6}(?:,[0-9]{2,3})*(?:\.[0-9]{1,2})?)',
    re.IGNORECASE,
)

_PLAIN_NUMBER_RE = re.compile(
    r'\b([1-9][0-9]{1,5}(?:\.[0-9]{1,2})?)\b'
)

_CATEGORY_KEYWORDS: dict[str, list[str]] = {
    'food':       ['restaurant', 'cafe', 'food', 'hotel', 'dine', 'swiggy', 'zomato',
                   'pizza', 'burger', 'biryani', 'dhaba', 'meal', 'lunch', 'dinner', 'breakfast'],
    'transit':    ['irctc', 'railway', 'train', 'bus', 'ticket', 'transport', 'cab',
                   'ola', 'uber', 'auto', 'fuel', 'petrol', 'diesel', 'toll'],
    'stay':       ['hotel', 'hostel', 'resort', 'oyo', 'airbnb', 'room', 'check-in',
                   'accommodation', 'lodging', 'inn', 'stay'],
    'activities': ['adventure', 'trek', 'rafting', 'paragliding', 'ticket', 'entry',
                   'park', 'museum', 'tour', 'guide', 'experience'],
}


def _extract_amount(text: str) -> Optional[float]:
    # Scan OCR text to extract the payment total amount using regex matching
    lines = text.splitlines()
    keyword_amounts: list[float] = []
    all_amounts:     list[float] = []

    for line in lines:
        for match in _AMOUNT_RE.finditer(line):
            try:
                val = float(match.group(1).replace(',', ''))
                if 10 <= val <= 999_999:
                    keyword_amounts.append(val)
                    all_amounts.append(val)
            except ValueError:
                pass

    if keyword_amounts:
        return max(keyword_amounts)

    for match in _PLAIN_NUMBER_RE.finditer(text):
        try:
            val = float(match.group(1).replace(',', ''))
            if 10 <= val <= 999_999:
                all_amounts.append(val)
        except ValueError:
            pass

    return max(all_amounts) if all_amounts else None


def _guess_category(text: str) -> Optional[str]:
    # Infer expense category based on keyword matches in OCR text
    lower_text = text.lower()
    for category, keywords in _CATEGORY_KEYWORDS.items():
        if any(kw in lower_text for kw in keywords):
            return category
    return 'misc'


def _run_tesseract(image_bytes: bytes) -> str:
    # Run Tesseract OCR on raw image bytes and return extracted text
    try:
        import pytesseract
        from PIL import Image

        image = Image.open(io.BytesIO(image_bytes))

        if image.mode not in ('RGB', 'L'):
            image = image.convert('RGB')

        try:
            text = pytesseract.image_to_string(image, lang='eng+hin')
        except pytesseract.pytesseract.TesseractError:
            text = pytesseract.image_to_string(image, lang='eng')

        return text.strip()

    except ImportError:
        print("[OCR Service] pytesseract / Pillow not installed — OCR unavailable.")
        return ""
    except Exception as exc:
        print(f"[OCR Service] Tesseract error: {exc}")
        return ""


def process_receipt(image_url: str) -> dict:
    # Download receipt image, run OCR extraction, and identify amount and category
    try:
        response = httpx.get(image_url, timeout=15, follow_redirects=True)
        response.raise_for_status()
        image_bytes = response.content
    except Exception as exc:
        return {
            "success":  False,
            "amount":   None,
            "currency": "INR",
            "category": None,
            "raw_text": "",
            "message":  f"Failed to download receipt image: {exc}",
        }

    raw_text = _run_tesseract(image_bytes)

    if not raw_text:
        return {
            "success":  False,
            "amount":   None,
            "currency": "INR",
            "category": None,
            "raw_text": "",
            "message":  "OCR produced no text. pytesseract may not be installed, or "
                        "the image quality is too low. Please enter the amount manually.",
        }

    amount = _extract_amount(raw_text)
    category = _guess_category(raw_text) if raw_text else None

    return {
        "success":  amount is not None,
        "amount":   amount,
        "currency": "INR",
        "category": category,
        "raw_text": raw_text[:2000],
        "message":  "Amount extracted successfully." if amount else
                    "Could not locate a payment total. Please enter the amount manually.",
    }
