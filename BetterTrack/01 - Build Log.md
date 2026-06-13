---
tags: [bettertrack, log]
created: 2026-06-13
---

# Build Log

Chronological record of what was made. Part of [[Project Overview]].

## Session 1 — 2026-06-13
1. Read `design.md.md` → extracted colors, type, spacing into Flutter tokens.
2. `flutter create app` (org `ai.bettertrack`, name `bettertrack`).
3. Built [[Flutter App]] design system:
   - `theme/` — colors, typography (Poppins), spacing/radius, ThemeData.
   - `models/` + `data/mock_data.dart` — sample groups/expenses/budgets.
   - `widgets/` — BalanceCard, BudgetCard, ExpenseCard, GroupCard, QuickAction, ActivityTile, EmptyState.
   - `screens/` — Dashboard, Groups, Analytics, Profile, GroupDetails (5 tabs), AI Chat.
4. Built [[Backend API]] (FastAPI): config, schemas, routes, AI/OCR/Obsidian services.
5. Installed `graphifyy` (CLI `graphify`) in backend venv → [[Obsidian + Graphify]].
6. Tested in iOS Simulator (iPhone 16e). Fixed:
   - **google_fonts offline crash** → bundled Poppins as local asset.
   - **Hero tag collision** between two FABs → unique `heroTag`s.
   - **BalanceCard 6px overflow** → trimmed number size + pill padding.
   - **Money format bug** (`81,50` → `8,150`) → corrected Indian-grouping regex.
7. `git init`, `.gitignore` secrets, pushed to GitHub.

## Verified
- `flutter analyze` → No issues found. `flutter test` → all green (9 tests).
- Backend `/api/health`, `/api/groups`, `/api/ai/chat`, `/api/expenses` all 200.
- Creating an expense writes a note to `BetterTrack/Backend Log/`.
- `requirements.txt` installs cleanly on Python 3.14 (relaxed pins).
- Graphify code graph built: app/lib = 266 nodes / 365 edges, backend/app =
  59 nodes / 94 edges. See [[Obsidian + Graphify]].

## Pushed (process-wise)
1. Foundation (README, design.md, .gitignore)
2. Flutter app
3. Backend
4. Obsidian notes (this)
