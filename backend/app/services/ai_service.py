"""AI assistant service. Uses Gemini or Claude when a key is set, else a
deterministic stub so the app works end-to-end before keys are entered."""
from __future__ import annotations

import httpx

from ..config import get_settings
from ..models.schemas import AiChatRequest, AiChatResponse

SYSTEM_PROMPT = (
    "You are BetterTrack AI, a friendly financial assistant inside a group "
    "expense app. Help users add expenses, split bills, check balances and "
    "budgets. Be concise. When the user describes a spend, propose a draft "
    "expense for them to confirm."
)


async def chat(req: AiChatRequest) -> AiChatResponse:
    settings = get_settings()

    if not settings.ai_ready:
        return AiChatResponse(
            reply=(
                "AI is not configured yet. Add a GEMINI_API_KEY (or "
                "ANTHROPIC_API_KEY) to backend/.env to enable smart replies. "
                f'(You said: "{req.message}")'
            ),
            used_ai=False,
        )

    if settings.ai_provider == "gemini":
        return await _gemini(req, settings)
    return await _anthropic(req, settings)


async def _gemini(req: AiChatRequest, settings) -> AiChatResponse:
    url = (
        "https://generativelanguage.googleapis.com/v1beta/models/"
        f"{settings.gemini_model}:generateContent"
    )
    payload = {
        "system_instruction": {"parts": [{"text": SYSTEM_PROMPT}]},
        "contents": [{"role": "user", "parts": [{"text": req.message}]}],
    }
    try:
        async with httpx.AsyncClient(timeout=30) as client:
            res = await client.post(
                url,
                headers={
                    "Content-Type": "application/json",
                    "X-goog-api-key": settings.gemini_api_key,
                },
                json=payload,
            )
        res.raise_for_status()
        data = res.json()
        text = data["candidates"][0]["content"]["parts"][0]["text"].strip()
        return AiChatResponse(reply=text, used_ai=True)
    except Exception as e:  # noqa: BLE001 — surface a clean message to the app
        return AiChatResponse(
            reply=f"AI request failed: {e}", used_ai=False
        )


async def _anthropic(req: AiChatRequest, settings) -> AiChatResponse:
    from anthropic import AsyncAnthropic

    client = AsyncAnthropic(api_key=settings.anthropic_api_key)
    msg = await client.messages.create(
        model=settings.ai_model,
        max_tokens=512,
        system=SYSTEM_PROMPT,
        messages=[{"role": "user", "content": req.message}],
    )
    text = "".join(
        block.text for block in msg.content if getattr(block, "type", "") == "text"
    )
    return AiChatResponse(reply=text, used_ai=True)
