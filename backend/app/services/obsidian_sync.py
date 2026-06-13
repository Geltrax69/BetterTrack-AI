"""Write progress / activity notes into the Obsidian vault.

Two paths:
  1. Direct file write into the vault (always works — the vault is on disk).
  2. POST to the Semantic Notes Vault MCP HTTP server when an API key is set.

graphify (pip `graphifyy`) then builds the code knowledge-graph linking these
notes and the source so everything stays connected.
"""
from __future__ import annotations

import datetime as _dt
from pathlib import Path

import httpx

from ..config import get_settings

NOTES_SUBDIR = "BetterTrack/Backend Log"


def _vault() -> Path | None:
    s = get_settings()
    if not s.obsidian_vault_path:
        return None
    p = Path(s.obsidian_vault_path)
    return p if p.exists() else None


def write_note(title: str, body: str, tags: list[str] | None = None) -> dict:
    """Append a timestamped note into the vault. Returns a small status dict."""
    tags = tags or ["bettertrack", "backend"]
    ts = _dt.datetime.now().strftime("%Y-%m-%d %H:%M")
    front = "---\n" + f"created: {ts}\n" + "tags: [" + ", ".join(tags) + "]\n---\n\n"
    content = f"{front}# {title}\n\n{body}\n"

    result: dict = {"file": None, "mcp": None}

    vault = _vault()
    if vault:
        folder = vault / NOTES_SUBDIR
        folder.mkdir(parents=True, exist_ok=True)
        safe = "".join(c if c.isalnum() or c in " -_" else "_" for c in title)
        fpath = folder / f"{_dt.date.today()} {safe}.md"
        fpath.write_text(content, encoding="utf-8")
        result["file"] = str(fpath)

    result["mcp"] = _try_mcp(title, content)
    return result


def _try_mcp(title: str, content: str) -> str | None:
    s = get_settings()
    if not s.obsidian_api_key:
        return "skipped: no OBSIDIAN_API_KEY"
    url = f"http://{s.obsidian_host}:{s.obsidian_port}/mcp"
    payload = {
        "jsonrpc": "2.0",
        "id": 1,
        "method": "tools/call",
        "params": {
            "name": "create_note",
            "arguments": {"path": f"{NOTES_SUBDIR}/{title}.md", "content": content},
        },
    }
    try:
        r = httpx.post(
            url,
            json=payload,
            headers={
                "Authorization": f"Bearer {s.obsidian_api_key}",
                "Accept": "application/json, text/event-stream",
            },
            timeout=8,
        )
        return f"{r.status_code}"
    except Exception as e:  # noqa: BLE001
        return f"error: {e}"
