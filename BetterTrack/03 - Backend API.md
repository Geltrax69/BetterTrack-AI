---
tags: [bettertrack, backend]
created: 2026-06-13
---

# Backend API

Path: `backend/` · Python · FastAPI. Part of [[Project Overview]].

## Structure
```
backend/
  app/
    main.py             # FastAPI app + CORS, mounts /api
    config.py           # typed settings from .env
    models/schemas.py   # Pydantic models (mirror Flutter models)
    api/routes.py       # /health /groups /expenses /budgets /ai/chat /ocr/scan
    services/
      ai_service.py     # Claude chat (falls back gracefully w/o key)
      ocr_service.py    # receipt OCR (Tesseract local / cloud)
      obsidian_sync.py  # writes activity notes into this vault
  requirements.txt
  .env.example          # copy → .env, fill keys (see [[Setup & Run]])
```

## Endpoints
| Method | Path | Purpose |
|---|---|---|
| GET | `/api/health` | status + which keys are configured |
| GET | `/api/groups` | list groups |
| GET/POST | `/api/expenses` | list / create (create → Obsidian note) |
| GET | `/api/budgets` | list budgets |
| POST | `/api/ai/chat` | AI assistant (Claude) |
| POST | `/api/ocr/scan` | receipt OCR → draft expense |

## Keys needed (in `.env`)
- `ANTHROPIC_API_KEY` — AI assistant
- `OCR_API_KEY` — only if using a cloud OCR provider
- `OBSIDIAN_API_KEY` — for MCP push (file write works without it)

Without keys the app still runs — AI/OCR return graceful "not configured" responses.
Connected to vault via [[Obsidian + Graphify]].
