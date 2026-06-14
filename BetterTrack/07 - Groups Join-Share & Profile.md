---
tags: [bettertrack, feature]
created: 2026-06-14
---

# Groups Join/Share & Profile

Round 3 of features. Part of [[Project Overview]]; builds on
[[Live Integration & States]].

## Group join codes + sharing
- Each group has a short `code` (e.g. `GOA123`), unambiguous alphabet.
- Backend: `POST /groups` generates it, `GET /groups/{code}` looks up,
  `POST /groups/join` adds a member (friendly 404 on bad code).
- App:
  - **Join** button on the Groups screen → `JoinGroupSheet` (enter code,
    auto-uppercase) → joins and opens the group.
  - **Share**: invite card in Group Details + app-bar share icon →
    `ShareGroupSheet` with big code, **Copy** (clipboard) and native **Share**
    (`share_plus`) of code + link `https://bettertrack.ai/join/<code>`.

## Profile — every row works now
Backed by `AppSettings` (`shared_preferences`, reactive singleton):
- **Edit profile** (name / email), reflected live on the header.
- **Default currency** picker (₹ / $ / € / £), persisted.
- **Notifications** toggles (expense / settlement / budget / AI).
- **AI preferences** (model = Gemini 2.5 Flash, suggestion toggles).
- **Privacy & security** (app lock, hide amounts, analytics).
- **Payment methods** — add / remove, persisted.
- **Help & support** — FAQ + contact.
- **Log out** — confirmation dialog.

## Verified on iOS Simulator
- Joined "Goa Trip" with code `GOA123`; share sheet renders code + Copy/Share.
- Created groups get codes; Profile rows open real screens; toggles persist.

## Still open (future)
- Settle-up flow, Scan Receipt (OCR) UI, real auth, propagate the chosen
  default currency to every money label app-wide.
