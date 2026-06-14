# SCOPE.md — Anomaly Log & Data Schema

This documents every data problem found in `expenses_export.csv`, how the
ingestion engine (`backend/app/services/ingest.py`) handles it, and the schema
the data lands in. The live, generated version is [`IMPORT_REPORT.md`](IMPORT_REPORT.md).

## How the five requests shaped the engine

| Flatmate | Ask | Where it's handled |
|---|---|---|
| **Aisha** | "One number per person — who pays whom." | `settle_up()` — greedy minimum-cash-flow |
| **Rohan** | "No magic numbers — show the expenses behind a balance." | `breakdown()` → `GET /import/balance/{person}` |
| **Priya** | "Half the trip was in dollars." | `FX_RATES`, per-row USD→INR conversion |
| **Sam** | "March electricity shouldn't affect me." | `MEMBERSHIP` windows; off-period members dropped from splits |
| **Meera** | "Approve anything the app deletes or changes." | destructive anomalies carry `needs_approval = true` |

## Anomaly catalogue

### 1. Duplicate entries
- **Marina Bites** (rows 5 & 6): same date, payer (Dev), amount (3200); only the
  text differs (`Dinner at Marina Bites` vs `dinner - marina bites`). → Detected
  by normalised key `(date, lower-alnum description, amount, currency)`; the
  second is **skipped, flagged for approval**.
- **Thalassa dinner** (rows 24 & 25): same date, *different* payer/amount
  (Aisha 2400, Rohan 2450), note "Aisha also logged this." → Not an exact
  duplicate, so **both kept** but the note is a known suspected-duplicate; left
  for manual approval rather than auto-deleting someone's record.

### 2. Currency (Priya)
- USD rows: Goa villa (540), beach lunch (84), parasailing (150), refund (−30).
  → Converted to INR at **1 USD = ₹83** (documented snapshot).
- Row 28 "forgot to set currency" (blank). → **Assumed INR** + flagged.

### 3. Membership / dates (Sam & Meera)
- **Sam** moved in ~Apr 8 (row 38). His window starts `2026-04-08`, so March
  bills never include him. Any expense listing Sam before that date would have
  him **removed and re-split**.
- **Meera** moved out end of March (farewell row 33). Window ends `2026-03-31`.
  Row 36 "oops Meera still in the group list" (April groceries) → Meera
  **removed from the April split**, flagged for approval.

### 4. Number formats
- `"1,200"` (row 7, comma) and `" 1450 "` (row 29, whitespace) → stripped/parsed.
- `899.995` (row 10) → kept; INR rounding applied at share level.

### 5. Date formats
- ISO `YYYY-MM-DD`, `DD/MM/YYYY`, and `"Mar 14"` (row 27, no year → assumed 2026).
- `04/05/2026` (row 34, "is this April 5 or May 4?") → read as **DD/MM = 4 May**
  (consistent with the file's dominant format + the split excludes Sam/Meera,
  which only fits May). **Flagged** as ambiguous.

### 6. Settlements mislabelled as expenses
- Row 14 "Rohan paid Aisha back" 5000, blank split_type, single counterparty.
- Row 38 "Sam deposit share" — Sam paid Aisha 15000.
  → Both recorded as **transfers** (`is_settlement`), not shared expenses; they
  move balances but aren't split.

### 7. Split-type issues
- **Percentages ≠ 100**: rows 15 & 32 sum to 110% → **renormalised** to 100%, flagged.
- **equal + shares conflict** (row 42): `split_type=equal` but share details present
  → **honoured `equal`**, ignored the stray shares, flagged.
- **share ratios** (row 22 "Aisha 1; Rohan 2; …") → split by units.

### 8. Edge values
- **Zero amount** (row 31, "counted twice earlier") → **skipped** (no effect).
- **Negative** (row 26, −30 USD refund) → kept (valid refund).
- **Missing payer** (row 13, "can't remember who paid") → **skipped**, flagged —
  can't attribute a credit to nobody.

### 9. Names & guests
- `priya` / `Priya S` / `Priya` → canonicalised to **Priya**; `rohan ` trimmed.
- **Kabir** ("Dev's friend", row 23) is a guest → his share is **absorbed by Dev**
  (the sponsor), so the flat's balances stay closed.

## Data schema

In-memory today (resets on restart); modelled as a relational schema for a real DB:

```
members(id PK, name, joined_at DATE, left_at DATE NULL)

expenses(id PK, date DATE, description TEXT, paid_by FK→members,
         amount_original NUMERIC, currency TEXT, amount_inr NUMERIC,
         split_type TEXT, group_id FK, status TEXT)   -- active | duplicate | skipped

expense_shares(expense_id FK, member_id FK, share_inr NUMERIC,
               PRIMARY KEY(expense_id, member_id))

settlements(id PK, date DATE, from_member FK, to_member FK, amount_inr NUMERIC)

anomalies(id PK, row INT, kind TEXT, detail TEXT, action TEXT,
          needs_approval BOOL, status TEXT)           -- pending | approved | rejected

fx_rates(currency TEXT PK, rate_to_inr NUMERIC, as_of DATE)
```

**Invariants:** for every non-settlement expense, `sum(expense_shares.share_inr)
= amount_inr`; the sum of all member net balances is **0** (verified in
ingestion — see `net_balances` sum check).

**Relation to the code knowledge graph (Graphify):** `graphify` indexes the
source — including `ingest.py` and `routes.py` — into a `graph.json` so the
data-flow (CSV → `run_import` → `net_balances` → `settle_up` → endpoints) is
navigable. See [Obsidian + Graphify](BetterTrack/05%20-%20Obsidian%20+%20Graphify.md).
