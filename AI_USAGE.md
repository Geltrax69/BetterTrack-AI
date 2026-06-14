# AI_USAGE.md

How AI was used to build BetterTrack AI, the key prompts, and — importantly —
concrete cases where the AI was **wrong**, how it was caught, and what changed.

## Tools used

| Tool | Role |
|---|---|
| **Claude Code** (Opus 4.x) | Pair-programmer: wrote Flutter + FastAPI code, the CSV engine, tests, docs; ran the iOS simulator and git. |
| **Google Gemini 2.5 Flash** | In-app assistant (`/ai/chat`) — parses "I spent ₹500 on lunch" into a draft expense. |
| **graphify** (`graphifyy`) | Builds a code knowledge graph over the repo to keep app + backend connected. |

## Key prompts (paraphrased)

- "Read `design.md` and build the Flutter design system (colors, Poppins, spacing) 1:1."
- "Wire the app to live backend data with loading/error/success states everywhere."
- "Ingest `expenses_export.csv`: handle duplicates, USD→INR, membership periods,
  settlements, and produce an anomaly report with who-pays-whom."
- "Each destructive change must be flagged for approval, not applied silently."
- "Verify on the iOS simulator and push after each feature."

## Cases where the AI was wrong (caught & fixed)

### 1. Wrong currency-grouping regex → `₹81,50` instead of `₹8,150`
- **What the AI produced:** an Indian digit-grouping regex
  `(\d)(?=(\d{2})+(?!\d))` that grouped in 2s everywhere, so `8150` rendered as
  `81,50` and `12450` as `1,24,50`.
- **How I caught it:** a screenshot of the dashboard on the simulator — the
  balance card visibly read `+₹81,50`.
- **The fix:** corrected to `(\d)(?=(\d\d)+\d(?!\d))` (last 3 digits, then 2s) and
  added a unit test (`format_money_test.dart`) locking the behaviour.

### 2. AI chat "server took too long to respond"
- **What the AI produced:** a single global 10s HTTP timeout applied to *every*
  call, including the Gemini chat — which often takes longer.
- **How I caught it:** the user hit it live; the chat showed the timeout error
  even though Gemini was returning valid replies.
- **The fix:** per-call timeouts; `/ai/chat` now gets 60s while other calls stay
  at 10s.

### 3. Settle-up didn't net to zero (off by ₹2,490)
- **What the AI produced:** the equal-split used a dict comprehension
  `{p: amount/n for p in people}`. After reassigning the guest Kabir's share to
  Dev, `people` contained `Dev` twice — the comprehension collapsed the two keys,
  silently dropping ₹2,490 (one parasailing share).
- **How I caught it:** an invariant check — the sum of all member balances must be
  0 for a closed system; it printed `2490.0`. A per-expense diff isolated it to
  the Parasailing row.
- **The fix:** accumulate shares (`out[p] = out.get(p,0) + amount/n`) so a sponsor
  who absorbs a guest gets both shares; the system now nets to ₹0.00.

### Other AI misses caught during the build
- **Invalid Dart:** the AI put an `import` statement at the *bottom* of
  `dashboard_screen.dart`. Caught by `flutter analyze`; moved/removed.
- **Offline font crash:** it used `google_fonts` (runtime fetch) for Poppins;
  the simulator couldn't reach `fonts.gstatic.com` and threw. Caught on the
  simulator; switched to a bundled font asset.
- **Hero-tag collision:** two `FloatingActionButton`s shared the default hero tag.
  Caught as a runtime exception in the logs; gave each a unique `heroTag`.
- **Dependency pins too old for Python 3.14:** pinned `pydantic==2.10.4` failed to
  build a wheel. Caught on `pip install`; relaxed to compatible lower bounds.

## Takeaway
AI accelerated the build dramatically, but every numeric/financial result was
**verified independently** — screenshots, `flutter analyze`/`flutter test`, and a
hard balance-sums-to-zero invariant — because a money app can't trust a
plausible-looking wrong answer.
