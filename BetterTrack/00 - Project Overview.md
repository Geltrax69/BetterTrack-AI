---
tags: [bettertrack, overview]
created: 2026-06-13
---

# BetterTrack AI — Project Overview

AI-native expense, budget & group settle-up app (Splitwise + Revolut + Apple Wallet vibe).
Built from [[Design System]] (`design.md.md`).

## Repo layout
- `app/` → [[Flutter App]] (Dart / Flutter 3.41)
- `backend/` → [[Backend API]] (Python / FastAPI)
- `BetterTrack/` → these Obsidian notes
- pushed to **https://github.com/Geltrax69/BetterTrack-AI.git**

## Connected tooling
- [[Obsidian + Graphify]] — knowledge graph linking notes + code
- Obsidian *Semantic Notes Vault MCP* on port `3001`

## Status (2026-06-13)
- ✅ Flutter design system + 4 main screens + group details + AI chat
- ✅ FastAPI backend skeleton (AI, OCR, expenses, groups, budgets)
- ✅ Backend writes activity notes back into this vault
- ⏳ API keys to be added in `backend/.env` (see [[Setup & Run]])

See [[Build Log]] for the step-by-step record.
