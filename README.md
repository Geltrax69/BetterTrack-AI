# BetterTrack AI

AI-native expense, budget & group settle-up app — *Splitwise × Revolut × Apple Wallet*.

Built from a design system (`design.md.md`) into a Flutter app + FastAPI backend,
with progress tracked as an Obsidian knowledge graph (linked via `graphify`).

## Repo layout
| Path | What |
|---|---|
| `app/` | Flutter app (Dart 3.11 / Flutter 3.41) — the full UI |
| `backend/` | FastAPI backend (AI assistant, receipt OCR, expenses, groups, budgets) |
| `BetterTrack/` | Obsidian notes documenting the build (start at `00 - Project Overview`) |
| `design.md.md` | The source design system (colors, type, spacing, screens) |

## Quick start

### App
```bash
cd app
flutter pub get
flutter run            # pick an iOS simulator / Android / device
```

### Backend
```bash
cd backend
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env   # then fill in your API keys
uvicorn app.main:app --reload --port 8000   # docs: http://127.0.0.1:8000/docs
```

## API keys
Configure these in `backend/.env` (gitignored — never committed):
- `ANTHROPIC_API_KEY` — AI assistant (Claude)
- `OCR_API_KEY` — only if using a cloud OCR provider
- `OBSIDIAN_API_KEY` — Semantic Vault MCP push (optional)

Without keys the app still runs end-to-end; AI/OCR return graceful "not configured" responses.

## Verified
- `flutter analyze` → no issues; `flutter test` → all green.
- Runs on the iOS Simulator (iPhone 16e), dashboard screenshot-verified.
- Backend endpoints return 200; creating an expense writes a note into the vault.
