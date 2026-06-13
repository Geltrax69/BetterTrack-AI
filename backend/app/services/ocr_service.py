"""Receipt OCR service. Local Tesseract by default; cloud providers need a key.
Returns a draft expense the user confirms (design.md OCR flow)."""
from __future__ import annotations

import re

from ..config import get_settings
from ..models.schemas import OcrResult

_CATEGORY_HINTS = {
    "food": ["restaurant", "cafe", "pizza", "burger", "dinner", "lunch", "swiggy", "zomato"],
    "travel": ["uber", "ola", "flight", "fuel", "petrol", "cab", "metro"],
    "shopping": ["mart", "store", "amazon", "mall", "grocery"],
    "entertainment": ["cinema", "movie", "netflix", "bookmyshow"],
}


def _guess_category(text: str) -> str | None:
    low = text.lower()
    for cat, hints in _CATEGORY_HINTS.items():
        if any(h in low for h in hints):
            return cat
    return None


def _guess_total(text: str) -> float | None:
    # Grab the largest currency-looking number — usually the grand total.
    nums = re.findall(r"(?:₹|rs\.?|inr|\$)?\s*([0-9]+(?:\.[0-9]{1,2})?)", text.lower())
    vals = [float(n) for n in nums if float(n) > 0]
    return max(vals) if vals else None


async def scan(image_bytes: bytes) -> OcrResult:
    settings = get_settings()

    if settings.ocr_provider == "tesseract":
        try:
            import io

            import pytesseract
            from PIL import Image

            text = pytesseract.image_to_string(Image.open(io.BytesIO(image_bytes)))
        except Exception:  # tesseract binary missing or bad image
            return OcrResult(
                raw_text="",
                used_ocr=False,
            )
        return OcrResult(
            merchant=(text.strip().splitlines() or [None])[0],
            total=_guess_total(text),
            category=_guess_category(text),
            raw_text=text,
            used_ocr=True,
        )

    # Cloud providers (google / mindee / textract) — wire up once OCR_API_KEY set.
    if not settings.ocr_api_key:
        return OcrResult(raw_text="OCR_API_KEY not set", used_ocr=False)

    raise NotImplementedError(
        f"OCR provider '{settings.ocr_provider}' not implemented yet."
    )
