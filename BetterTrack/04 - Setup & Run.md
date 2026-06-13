---
tags: [bettertrack, setup]
created: 2026-06-13
---

# Setup & Run

Part of [[Project Overview]].

## Flutter app
```bash
cd app
flutter pub get
flutter run            # choose iOS simulator / Android / device
```

## Backend
```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env       # then fill in the keys
uvicorn app.main:app --reload --port 8000
# docs at http://127.0.0.1:8000/docs
```

## API keys (fill in `backend/.env` later)
- `ANTHROPIC_API_KEY=` → AI assistant (console.anthropic.com)
- `OCR_API_KEY=` → only if `OCR_PROVIDER` is a cloud service
- `OBSIDIAN_API_KEY=` → Semantic Vault MCP (port 3001) push
- `SECRET_KEY=` → `openssl rand -hex 32`

## Point the Flutter app at the backend
The app currently uses `data/mock_data.dart`. To go live, add an HTTP client
pointing at `http://127.0.0.1:8000/api` and replace the mock reads.

## Knowledge graph
See [[Obsidian + Graphify]] to rebuild the code graph after changes.
