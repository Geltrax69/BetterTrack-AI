# DECISIONS.md — Decision Log

Each significant decision, the options considered, and why I chose what I chose.

---

### D1 — Currency conversion strategy
**Decision:** Convert every non-INR row to INR at a single documented rate
(`1 USD = ₹83`) held in `FX_RATES`.
**Options:** (a) leave amounts in mixed currencies; (b) live FX API; (c) one
fixed snapshot rate.
**Why:** (a) is exactly Priya's complaint ("the sheet pretends a dollar is a
rupee"). (b) adds a network dependency and makes results non-reproducible for a
graded export. (c) is deterministic, auditable, and trivially swappable for a
dated-rate table later. The rate is surfaced in the report so it's never a
"magic number".

### D2 — Membership windows (date-based applicability)
**Decision:** Each member has a `[joined, left]` window; a member is dropped from
any split whose date falls outside their window, and the expense is re-split.
**Options:** (a) split by whoever is listed in `split_with`; (b) date-gated
membership.
**Why:** (a) produces exactly Sam's bug — March electricity hitting someone who
moved in in April, and Meera being charged for April groceries. (b) encodes the
real-world truth. Meera ends `2026-03-31`, Sam starts `2026-04-08`.

### D3 — Destructive changes require approval
**Decision:** Anything that deletes or alters a record (duplicates, skips,
renormalised splits, membership edits) is **flagged `needs_approval`** rather
than applied silently.
**Options:** (a) auto-clean everything; (b) flag destructive changes for review.
**Why:** Meera explicitly asked to approve deletions/changes. Auto-cleaning is
faster but erases a human's record without consent. The report separates
**auto** (safe normalisation) from **⚠️ approval** (judgement calls).

### D4 — Duplicate detection threshold
**Decision:** Auto-flag only **exact** duplicates (same date + normalised
description + amount + currency, e.g. Marina Bites). **Suspected** duplicates
with differing payer/amount (Thalassa 2400 vs 2450) are surfaced but **both
kept** pending approval.
**Why:** Deleting one person's ₹2,450 because someone else logged ₹2,400 is a
data-loss risk. Exact matches are safe; near-matches need a human.

### D5 — Settlements vs expenses
**Decision:** A row with a blank `split_type` and a single counterparty is a
**transfer** (e.g. "Rohan paid Aisha back", "Sam deposit share"), recorded as a
settlement that moves balances but isn't split.
**Why:** Treating a repayment as a shared expense double-counts it. The CSV even
asks "this is a settlement not an expense??" — yes, it is.

### D6 — Ambiguous date `04/05/2026`
**Decision:** Read as **DD/MM = 4 May 2026**, and flag it.
**Options:** April 5 vs May 4.
**Why:** The file's dominant format is DD/MM, and the expense (Deep cleaning,
split Aisha/Rohan/Priya — no Meera, no Sam) only makes sense **after** Meera left
and excludes Sam, which fits May. Still flagged because it's a genuine guess.

### D7 — Percentages that don't sum to 100
**Decision:** **Renormalise** proportionally to 100% and flag (rows 15 & 32 sum to 110%).
**Options:** reject the row vs renormalise.
**Why:** Rejecting loses a real expense; renormalising preserves the intended
*ratios* while making the math valid. Flagged for transparency.

### D8 — `equal` + share details conflict (row 42)
**Decision:** Honour `split_type=equal`, ignore the stray share numbers, flag.
**Why:** The declared type is the clearer signal; the note confirms "someone
added shares anyway". Picking one and flagging beats guessing intent.

### D9 — Guest (Kabir) share
**Decision:** A guest's share is **absorbed by their sponsor** (Kabir → Dev).
**Options:** (a) split among flatmates only; (b) charge the guest (who'll never
settle); (c) sponsor absorbs.
**Why:** (b) leaves money uncollected and unbalances the flat. (c) matches social
reality ("Dev's friend") and keeps the system closed (sums to ₹0).

### D10 — Settle-up algorithm
**Decision:** Greedy **minimum-cash-flow** (largest debtor pays largest creditor).
**Options:** pairwise net (every debtor pays every creditor) vs min-cash-flow.
**Why:** Aisha wants the fewest "who pays whom" lines. Min-cash-flow yields 5
transfers for 6 people instead of up to 15. (Caveat noted: it can pair people
who never co-resided, e.g. Meera→Sam — acceptable for fewest transfers.)

### D11 — Missing payer (row 13)
**Decision:** **Skip** and flag; don't fabricate a payer.
**Why:** A credit must belong to someone real; guessing would silently shift
₹780. Better to surface it for a human to fill in.

### D12 — In-memory store now, schema-ready
**Decision:** Keep stores in-memory; model a relational schema (see SCOPE.md).
**Why:** Lets the engine and API be built and tested fast; the schema documents
the migration path to SQLite/Postgres without blocking the deliverable.

### D13 — AI provider & timeout
**Decision:** Gemini 2.5 Flash server-side; the app gives `/ai/chat` a 60s timeout.
**Why:** The user supplied a Gemini key; the assistant is non-critical so it
fails gracefully. The original single 10s client timeout caused "server took too
long" — fixed with a per-call timeout.

### D14 — App data-loading pattern
**Decision:** `AsyncValue` (loading/data/error) + a swappable `Repository`, with
a branded spinner, retry on error, and success/failure toasts everywhere.
**Why:** A money app must never show a blank or frozen screen on a flaky network;
consistent states make every async surface predictable and testable.
