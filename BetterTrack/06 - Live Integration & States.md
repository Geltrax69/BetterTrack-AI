---
tags: [bettertrack, frontend, backend, integration]
created: 2026-06-13
---

# Live Integration & States

The app now runs on **actual backend data** with full loading/error/success
handling. Part of [[Project Overview]]; builds on [[Flutter App]] + [[Backend API]].

## Networking layer (app)
- `services/api_client.dart` — HTTP wrapper, 10s timeout, maps SocketException /
  timeout / 5xx onto friendly `ApiException` messages.
- `services/repository.dart` — typed calls; `Repository.instance` is swappable
  (tests inject a `MockClient`, no real network).
- `services/async_value.dart` — `AsyncLoading / AsyncData / AsyncError`.
- `models` gained `fromJson`; `data/catalog.dart` maps API strings → typed UI.

## Every surface has 3 states
- **Loading** → `BrandSpinner` (animated gradient ring + pulsing wallet mark).
- **Error** → `ErrorState` card with the reason + **Retry** (via `AsyncView`).
- **Success** → content; actions also flash success/failure toasts.
- `StateButton` runs async work with idle → spinner → ✓ checkmark.

## Wired screens
- **Dashboard** → `/summary` `/budgets` `/activity` + pull-to-refresh.
- **Groups** → `/groups` + search + empty/error states.
- **Group Details › Expenses** → `/expenses?group_id=` + refresh.
- **Add Expense** sheet → `POST /expenses` (validation + feedback); on success
  the activity feed updates.
- **AI chat** → `POST /ai/chat` with a typing indicator; errors show inline + toast.

## Network resilience
If the backend is unreachable, screens show the error card with Retry instead
of crashing or hanging — pull-to-refresh or Retry recovers once it's back.

## Config
- Base URL: `http://127.0.0.1:8000/api` (override with
  `--dart-define=API_BASE_URL=...`; Android emulator = `10.0.2.2`).
- iOS `Info.plist` allows local-network cleartext HTTP for dev.

## Verified
- On iOS Simulator the dashboard renders live data (net ₹4,400).
- `POST /expenses` creates an expense and prepends it to `/activity`.
- `flutter analyze` clean; 9 widget/unit tests green (mock-backed).
