"""Outbound notifications via a Zapier Catch Hook.

Best-effort: if ZAPIER_HOOK_URL is unset or the call fails, we silently skip —
notifications are never allowed to break a request.
"""
from __future__ import annotations

import httpx

from ..config import get_settings


def send(event: str, payload: dict) -> None:
    url = get_settings().zapier_hook_url
    if not url:
        return
    try:
        httpx.post(url, json={"event": event, **payload}, timeout=5)
    except Exception:  # noqa: BLE001 — notifications must never break the app
        pass
