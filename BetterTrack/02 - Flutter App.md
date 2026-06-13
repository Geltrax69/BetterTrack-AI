---
tags: [bettertrack, flutter]
created: 2026-06-13
---

# Flutter App

Path: `app/` · Flutter 3.41 · Dart 3.11. Implements [[Design System]].
Part of [[Project Overview]].

## Structure
```
app/lib/
  main.dart            # BetterTrackApp → HomeShell
  theme/               # app_colors, app_typography, app_spacing, app_theme
  models/models.dart   # Expense, Group, Budget, Activity, ChatMessage
  data/mock_data.dart  # sample content (no backend needed to run)
  widgets/             # balance_card, cards, common
  screens/             # dashboard, groups, analytics, profile,
                       # group_details (Overview/Expenses/Budgets/Members/Chat),
                       # ai_chat, home_shell (bottom nav)
```

## Design fidelity
- Colors / radius / spacing / type pulled 1:1 from `design.md.md`.
- Poppins bundled in `assets/fonts/` (offline-safe, no network fetch).
- Bottom nav: dark pill, radius 32, animated selected chip.
- AI accent FAB opens [[Backend API]]'s assistant (stubbed until key set).

## Dependencies
- `fl_chart` — analytics line + pie charts.
- `provider` — light state (reserved for live data wiring).

## Run
```
cd app && flutter run        # pick the iOS simulator / device
```
See [[Setup & Run]].
