---
tags: [bettertrack, auth, feature]
created: 2026-06-14
---

# Auth & Login

Sign up / sign in. Part of [[Project Overview]].

## The AI chat bug (fixed)
The chat sometimes showed "The server took too long to respond." — the app's
HTTP client used a single 10s timeout for every call, but Gemini replies can
take longer. Fix: per-call timeouts; `/ai/chat` now gets **60s**. Other calls
stay at 10s. (The reply itself was real Gemini output — only slow ones failed.)

## Backend auth
- `POST /auth/signup` {name,email,password} → {token,name,email}
- `POST /auth/login` {email,password} → token (401 on bad creds)
- `POST /auth/google` {email,name} → token (demo; real OAuth verifies a Google
  ID token against the web client id)
- In-memory user store, salted SHA-256, opaque tokens. Swap for a DB + JWT later.

## App
- `LoginScreen` — Sign in / Sign up toggle, email + password (validation,
  show/hide), "Continue with Google", loading via `StateButton`.
- `AuthGate` shows `LoginScreen` until `AppSettings.token` is set, then the app;
  reacts instantly to sign-in / log-out. Token persisted in shared_preferences.
- Profile "Log out" clears the token → back to login.

## Firebase / Google config
From `google-services-2.json` (project `bettertrack-66f41`), values saved in
`backend/.env` (gitignored) and documented in `.env.example`:
`FIREBASE_PROJECT_ID/API_KEY/...`, `GOOGLE_OAUTH_WEB_CLIENT_ID`, etc.
The raw json is gitignored.

## Real Google Sign-In (future)
Needs `google_sign_in` + an iOS `GoogleService-Info.plist` (the provided file is
the Android `google-services.json`) and the reversed-client-id URL scheme.

## Verified
- curl: signup→token, login, wrong pw→401, dup→409, google→token.
- Login screen renders on the iOS Simulator; tests cover logged-out→login and
  logged-in→dashboard.
