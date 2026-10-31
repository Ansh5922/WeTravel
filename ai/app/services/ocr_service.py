import re
import io
import os
import sys
import shutil
import base64
from typing import Optional
import httpx

_AMOUNT_RE = re.compile(
    r'(?:[₹]|Rs\.?|INR|Total|Grand\s*Total|Net\s*Total|Net\s*Amount|Amount\s*Paid|Total\s*Payable|Bill\s*Amount|Paid)'
    r'\s*[:=\-]?\s*(?:[₹]|Rs\.?|INR)?\s*([0-9]{1,6}(?:,[0-9]{2,3})*(?:\.[0-9]{1,2})?)',
    re.IGNORECASE,
)

_PLAIN_NUMBER_RE = re.compile(
    r'\b([1-9][0-9]{1,5}(?:\.[0-9]{1,2})?)\b'
)

_CATEGORY_KEYWORDS: dict[str, list[str]] = {
    'Food':       ['restaurant', 'cafe', 'food', 'hotel', 'dine', 'swiggy', 'zomato',
                   'pizza', 'burger', 'biryani', 'dhaba', 'meal', 'lunch', 'dinner',
                   'breakfast', 'bakery', 'bar', 'grill', 'kitchen', 'bistro', 'canteen'],
    'Transit':    ['irctc', 'railway', 'train', 'bus', 'ticket', 'transport', 'cab',
                   'ola', 'uber', 'auto', 'fuel', 'petrol', 'diesel', 'toll', 'flight',
                   'airline', 'boarding', 'metro', 'fare'],
    'Stay':       ['hotel', 'hostel', 'resort', 'oyo', 'airbnb', 'room', 'check-in',
                   'accommodation', 'lodging', 'inn', 'stay', 'villa', 'cottage'],
    'Activities': ['adventure', 'trek', 'rafting', 'paragliding', 'ticket', 'entry',
                   'park', 'museum', 'tour', 'guide', 'experience', 'safari', 'water sports', 'boating'],
    'Shopping':   ['store', 'market', 'mall', 'supermarket', 'mart', 'retail', 'clothing',
                   'apparel', 'souvenir', 'bazaar', 'shop'],
}

_KNOWN_BRANDS: list[tuple[list[str], str, str]] = [
    (['mcdonald', 'mc donald'], "McDonald's", 'Food'),
    (['starbucks'], 'Starbucks Coffee', 'Food'),
    (['domino'], "Domino's Pizza", 'Food'),
    (['pizza hut'], 'Pizza Hut', 'Food'),
    (['subway'], 'Subway', 'Food'),
    (['kfc'], 'KFC', 'Food'),
    (['burger king'], 'Burger King', 'Food'),
    (['cafe coffee day', 'ccd'], 'Cafe Coffee Day', 'Food'),
    (['chai point'], 'Chai Point', 'Food'),
    (['haldiram'], 'Haldirams', 'Food'),
    (['swiggy'], 'Swiggy Order', 'Food'),
    (['zomato'], 'Zomato Order', 'Food'),
    (['uber'], 'Uber Ride', 'Transit'),
    (['ola'], 'Ola Ride', 'Transit'),
    (['irctc', 'indian railways'], 'IRCTC Railways', 'Transit'),
    (['indigo'], 'IndiGo Flight', 'Transit'),
    (['air india'], 'Air India Flight', 'Transit'),
    (['oyo'], 'OYO Rooms', 'Stay'),
    (['airbnb'], 'Airbnb Stay', 'Stay'),
    (['taj hotel', 'taj holiday', 'taj resort'], 'Taj Hotels', 'Stay'),
    (['decathlon'], 'Decathlon Sports', 'Shopping'),
    (['dmart', 'd-mart'], 'DMart Retail', 'Shopping'),
]

_HEADER_NOISE_RE = re.compile(
    r'^(?:tax\s+invoice|retail\s+invoice|cash\s+memo|receipt|bill|gstin|gst\b|cin\b|pan\b|'
    r'fssai|date|time|welcome|order|table|token|invoice|counter|customer|merchant|tel|phone|ph\b|'
    r'thank\s+you|visit\s+again|www\.|http)',
    re.IGNORECASE,
)


def _extract_amount(text: str) -> Optional[float]:
    # Scan OCR text to extract the payment total amount using regex matching
    lines = text.splitlines()
    keyword_amounts: list[float] = []
    all_amounts:     list[float] = []

    for line in lines:
        for match in _AMOUNT_RE.finditer(line):
            try:
                val = float(match.group(1).replace(',', ''))
                if 1.0 <= val <= 999_999:
                    keyword_amounts.append(val)
                    all_amounts.append(val)
            except ValueError:
                pass

    if keyword_amounts:
        return max(keyword_amounts)

    for match in _PLAIN_NUMBER_RE.finditer(text):
        try:
            val = float(match.group(1).replace(',', ''))
            if 10.0 <= val <= 999_999:
                all_amounts.append(val)
        except ValueError:
            pass

    return max(all_amounts) if all_amounts else None


def _guess_category(text: str) -> str:
    # Infer expense category based on keyword matches in OCR text
    lower_text = text.lower()
    for category, keywords in _CATEGORY_KEYWORDS.items():
        if any(kw in lower_text for kw in keywords):
            return category
    return 'Other'


def _extract_merchant(text: str, fallback_category: str) -> str:
    # Extract merchant/store title or brand from receipt lines
    lower_text = text.lower()
    for brand_aliases, brand_name, _ in _KNOWN_BRANDS:
        if any(alias in lower_text for alias in brand_aliases):
            return brand_name

    lines = [l.strip() for l in text.splitlines() if l.strip()]
    for line in lines[:8]:
        # Clean line
        cleaned = re.sub(r'[^a-zA-Z0-9\s\'\.\-&]', '', line).strip()
        if len(cleaned) < 3:
            continue
        # Skip noise lines
        if _HEADER_NOISE_RE.search(cleaned):
            continue
        # Skip lines that are mostly numbers
        digits = sum(c.isdigit() for c in cleaned)
        if digits / len(cleaned) > 0.4:
            continue

        # If it looks like a valid merchant name
        if any(c.isalpha() for c in cleaned):
            # Title case if in ALL CAPS
            if cleaned.isupper():
                return cleaned.title()
            return cleaned

    # Fallback to category-based title
    cat = fallback_category if fallback_category and fallback_category != 'Other' else 'Trip'
    return f"{cat} Expense"


def _resolve_tesseract_cmd() -> Optional[str]:
    # 1. Check custom environment variable override (custom Docker/cloud deployment path)
    env_cmd = os.getenv("TESSERACT_CMD")
    if env_cmd and os.path.exists(env_cmd):
        return env_cmd

    # 2. Check system PATH (standard Linux / Docker / Windows PATH)
    path_cmd = shutil.which("tesseract")
    if path_cmd:
        return path_cmd

    # 3. Check known Windows standard installation locations
    if sys.platform.startswith("win"):
        win_candidates = [
            r"C:\Program Files\Tesseract-OCR\tesseract.exe",
            r"C:\Program Files (x86)\Tesseract-OCR\tesseract.exe",
            os.path.join(os.environ.get("LOCALAPPDATA", ""), "Programs", "Tesseract-OCR", "tesseract.exe"),
        ]
        for candidate in win_candidates:
            if candidate and os.path.exists(candidate):
                return candidate

    return None


def _run_tesseract(image_bytes: bytes) -> str:
    # Run Tesseract OCR on raw image bytes with dynamic path configuration
    try:
        import pytesseract
        from PIL import Image

        tesseract_cmd = _resolve_tesseract_cmd()
        if not tesseract_cmd:
            print("[OCR Service] Tesseract binary not detected on system or PATH. Falling back to manual entry.")
            return ""

        pytesseract.pytesseract.tesseract_cmd = tesseract_cmd

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
    # Download receipt image, run OCR extraction, and identify title, amount and category
    try:
        if image_url.startswith("data:") and ";base64," in image_url:
            _, encoded = image_url.split(";base64,", 1)
            image_bytes = base64.b64decode(encoded)
        else:
            response = httpx.get(image_url, timeout=15, follow_redirects=True)
            response.raise_for_status()
            image_bytes = response.content
    except Exception as exc:
        return {
            "success":  False,
            "title":    "Trip Expense",
            "merchant": None,
            "amount":   None,
            "currency": "INR",
            "category": "Other",
            "raw_text": "",
            "message":  f"Failed to load receipt image: {exc}",
        }

    raw_text = _run_tesseract(image_bytes)

    if not raw_text:
        return {
            "success":  False,
            "title":    "Trip Expense",
            "merchant": None,
            "amount":   None,
            "currency": "INR",
            "category": "Other",
            "raw_text": "",
            "message":  "OCR produced no text. pytesseract may not be installed, or "
                        "the image quality is too low. Please enter the amount manually.",
        }

    amount = _extract_amount(raw_text)
    category = _guess_category(raw_text)
    merchant = _extract_merchant(raw_text, category)

    return {
        "success":  amount is not None or bool(merchant),
        "title":    merchant,
        "merchant": merchant,
        "amount":   amount,
        "currency": "INR",
        "category": category,
        "raw_text": raw_text[:2000],
        "message":  "Receipt scanned successfully." if amount else
                    "Merchant identified. Please verify the amount.",
    }
