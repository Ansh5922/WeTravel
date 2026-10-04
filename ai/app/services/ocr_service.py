import re
import io
from typing import Optional

"""
OCR Service — WeTravel AI Backend
Layer: Service (image-to-amount extraction)

Pipeline:
  1. Fetch receipt image from the CDN URL (httpx).
  2. Run Tesseract OCR via pytesseract (CPU, no GPU required).
     Falls back gracefully if pytesseract / Tesseract is not installed —
     returns None amount so Node.js prompts the user for manual entry.
  3. Apply deterministic regex patterns to locate the total/grand-total amount.
  4. Guess the expense category from keywords in the OCR text.

────────────────────────────────────────────────────────────────────────────────
INSTALLATION NOTES (one-time, run on the server):
  pip install pillow pytesseract
  # Also install the Tesseract binary:
  #   Ubuntu/Debian:  sudo apt-get install tesseract-ocr
  #   macOS:          brew install tesseract
  #   Windows:        https://github.com/UB-Mannheim/tesseract/wiki
────────────────────────────────────────────────────────────────────────────────
"""

# ── Regex patterns ────────────────────────────────────────────────────────────

# Matches Indian currency amounts like: ₹1,234.56 | Rs. 500 | INR 2000 | 1250.00
_AMOUNT_RE = re.compile(
    r'(?:[₹]|Rs\.?|INR|Total|Grand\s*Total|Amount\s*Paid|Net\s*Amount|Paid)'
    r'\s*:?\s*([0-9]{1,6}(?:,[0-9]{2,3})*(?:\.[0-9]{1,2})?)',
    re.IGNORECASE,
)

# Fallback: any plain number that looks like a plausible payment amount
_PLAIN_NUMBER_RE = re.compile(
    r'\b([1-9][0-9]{1,5}(?:\.[0-9]{1,2})?)\b'
)

# Category keyword mapping (checked against full OCR text)
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


# ── Internal helpers ──────────────────────────────────────────────────────────

def _extract_amount(text: str) -> Optional[float]:
    """
    Scan OCR text for the largest monetary total.

    Strategy:
      1. Look for lines containing payment keywords (Total, Grand Total, Paid…).
         If found, return the largest amount on those lines.
      2. Fallback: return the largest plain number in the entire text that is
         ≥ 10 (to skip single-digit noise) and ≤ 999999.
    """
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

    # Fallback: plain numbers anywhere in text
    for match in _PLAIN_NUMBER_RE.finditer(text):
        try:
            val = float(match.group(1).replace(',', ''))
            if 10 <= val <= 999_999:
                all_amounts.append(val)
        except ValueError:
            pass

    return max(all_amounts) if all_amounts else None


def _guess_category(text: str) -> Optional[str]:
    """Return the first category whose keywords appear in the OCR text."""
    lower_text = text.lower()
    for category, keywords in _CATEGORY_KEYWORDS.items():
        if any(kw in lower_text for kw in keywords):
            return category
    return 'misc'


def _run_tesseract(image_bytes: bytes) -> str:
    """
    Run Tesseract OCR on raw image bytes.
    Returns empty string if pytesseract or the Tesseract binary is unavailable.
    """
    try:
        import pytesseract
        from PIL import Image

        image = Image.open(io.BytesIO(image_bytes))

        # Convert to RGB if necessary (PNG/WEBP may have alpha channel)
        if image.mode not in ('RGB', 'L'):
            image = image.convert('RGB')

        # Use English + Hindi for Indian receipts; fall back to English only
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


# ── Public API ────────────────────────────────────────────────────────────────

def process_receipt(image_url: str) -> dict:
    """
    Full OCR pipeline: fetch image → OCR → regex extract → category guess.

    Returns:
        {
            "success":  bool,
            "amount":   float | None,
            "currency": "INR",
            "category": str | None,
            "raw_text": str,
            "message":  str,
        }
    """
    import httpx  # imported here to keep module-level imports clean

    # 1. Download image from CDN
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

    # 2. OCR
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

    # 3. Amount extraction
    amount = _extract_amount(raw_text)

    # 4. Category guess
    category = _guess_category(raw_text) if raw_text else None

    return {
        "success":  amount is not None,
        "amount":   amount,
        "currency": "INR",
        "category": category,
        "raw_text": raw_text[:2000],    # cap stored text to 2 KB
        "message":  "Amount extracted successfully." if amount else
                    "Could not locate a payment total. Please enter the amount manually.",
    }
