"""AI assistant service. Uses Claude when ANTHROPIC_API_KEY is set, else a
deterministic stub so the app works end-to-end before keys are entered."""
from __future__ import annotations

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
        # No key yet — graceful fallback.
        return AiChatResponse(
            reply=(
                "AI is not configured yet. Add ANTHROPIC_API_KEY to backend/.env "
                "to enable smart replies. (You said: "
                f"\"{req.message}\")"
            ),
            used_ai=False,
        )

    # Lazy import so the package is only needed when a key is present.
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
