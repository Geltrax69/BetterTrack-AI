"""CSV ingestion + settle-up engine for the flat's expense export.

Turns a messy `expenses_export.csv` into clean expenses, a who-pays-whom plan,
and a per-person itemised breakdown — while logging every anomaly and the action
taken. Maps to the flatmates' requests:

  • Aisha  → minimal who-pays-whom plan (`settle_up`)
  • Rohan  → itemised balance: every expense behind a number (`breakdown`)
  • Priya  → multi-currency: USD converted to INR (`FX_RATES`)
  • Sam    → membership periods: you don't owe for dates before you moved in
  • Meera  → destructive changes (dedupe/skip) are flagged for *approval*

All money is computed in INR (paise-safe via rounding at the end).
"""
from __future__ import annotations

import csv
import datetime as dt
import re
from dataclasses import dataclass, field
from pathlib import Path

# ── Documented assumptions (see DECISIONS.md) ──
FX_RATES = {"USD": 83.0, "INR": 1.0}          # fixed snapshot rate
DEFAULT_CURRENCY = "INR"                        # blank currency → INR

# Canonical flatmate names + membership windows (inclusive).
MEMBERSHIP = {
    "Aisha": (dt.date(2026, 1, 1), dt.date(2026, 12, 31)),
    "Rohan": (dt.date(2026, 1, 1), dt.date(2026, 12, 31)),
    "Priya": (dt.date(2026, 1, 1), dt.date(2026, 12, 31)),
    "Meera": (dt.date(2026, 1, 1), dt.date(2026, 3, 31)),   # moved out end of March
    "Sam":   (dt.date(2026, 4, 8),  dt.date(2026, 12, 31)),  # moved in mid-April
    "Dev":   (dt.date(2026, 1, 1), dt.date(2026, 12, 31)),   # recurring visitor
}
# Guests whose share is absorbed by the person who brought them.
GUEST_SPONSOR = {"Kabir": "Dev"}

# Name normalisation: lower-cased / stripped variants → canonical.
_NAME_MAP = {
    "priya s": "Priya",
    "dev's friend kabir": "Kabir",
}


def _canon_name(raw: str) -> str:
    n = (raw or "").strip()
    low = n.lower()
    if low in _NAME_MAP:
        return _NAME_MAP[low]
    return n[:1].upper() + n[1:] if n else ""


def _parse_amount(raw: str) -> float | None:
    s = (raw or "").strip().replace(",", "")
    if s == "":
        return None
    try:
        return float(s)
    except ValueError:
        return None


def _parse_date(raw: str) -> tuple[dt.date | None, str | None]:
    """Returns (date, ambiguity_note). Supports ISO, DD/MM/YYYY, 'Mon DD'."""
    s = (raw or "").strip()
    note = None
    # ISO
    try:
        return dt.date.fromisoformat(s), None
    except ValueError:
        pass
    # DD/MM/YYYY
    m = re.match(r"^(\d{1,2})/(\d{1,2})/(\d{4})$", s)
    if m:
        d, mo, y = int(m[1]), int(m[2]), int(m[3])
        if d <= 12 and mo <= 12 and d != mo:
            note = f"ambiguous date '{s}' — read as DD/MM ({d:02d}/{mo:02d})"
        try:
            return dt.date(y, mo, d), note
        except ValueError:
            return None, f"invalid date '{s}'"
    # 'Mar 14' (assume 2026)
    m = re.match(r"^([A-Za-z]{3,})\s+(\d{1,2})$", s)
    if m:
        try:
            parsed = dt.datetime.strptime(f"{m[1][:3]} {m[2]} 2026", "%b %d %Y").date()
            return parsed, f"year missing in '{s}' — assumed 2026"
        except ValueError:
            return None, f"unparseable date '{s}'"
    return None, f"unparseable date '{s}'"


def _split_people(raw: str) -> list[str]:
    return [_canon_name(p) for p in (raw or "").split(";") if p.strip()]


@dataclass
class Anomaly:
    row: int
    kind: str
    detail: str
    action: str
    needs_approval: bool = False


@dataclass
class Expense:
    row: int
    date: dt.date
    description: str
    paid_by: str
    amount_inr: float
    shares: dict[str, float]       # person -> amount owed (INR)
    is_settlement: bool = False
    recipient: str | None = None   # for settlements


@dataclass
class ImportResult:
    expenses: list[Expense] = field(default_factory=list)
    anomalies: list[Anomaly] = field(default_factory=list)
    skipped: int = 0


def _compute_shares(amount: float, people: list[str], split_type: str,
                    details: str, row: int, anomalies: list[Anomaly]) -> dict[str, float]:
    """Returns person -> owed amount (sums to `amount`)."""
    st = (split_type or "equal").strip().lower()

    def parse_pairs() -> dict[str, float]:
        out: dict[str, float] = {}
        for part in (details or "").split(";"):
            mt = re.match(r"\s*(.+?)\s+([0-9.]+)%?\s*$", part)
            if mt:
                out[_canon_name(mt[1])] = float(mt[2])
        return out

    if st in ("unequal", "exact") and details:
        pairs = parse_pairs()
        total = sum(pairs.values())
        if abs(total - amount) > 0.5:
            anomalies.append(Anomaly(row, "split_mismatch",
                f"unequal split sums to {total} but amount is {amount}",
                "scaled shares proportionally to the amount", True))
            pairs = {k: v / total * amount for k, v in pairs.items()} if total else {}
        return pairs

    if st == "percentage" and details:
        pairs = parse_pairs()
        pct = sum(pairs.values())
        if abs(pct - 100) > 0.1:
            anomalies.append(Anomaly(row, "percentage_sum",
                f"percentages sum to {pct}%, not 100%",
                "renormalised to 100%", True))
        return {k: amount * v / pct for k, v in pairs.items()} if pct else {}

    if st == "share" and details:
        pairs = parse_pairs()
        units = sum(pairs.values())
        return {k: amount * v / units for k, v in pairs.items()} if units else {}

    # equal (default). If shares were supplied anyway, ignore them (flag).
    if details and st == "equal":
        anomalies.append(Anomaly(row, "split_conflict",
            "split_type=equal but share details present",
            "honoured split_type=equal, ignored the share details", True))
    n = len(people)
    if not n:
        return {}
    # Accumulate so a sponsor who absorbed a guest gets both shares.
    out: dict[str, float] = {}
    for p in people:
        out[p] = out.get(p, 0) + amount / n
    return out


def run_import(csv_path: str | Path) -> ImportResult:
    result = ImportResult()
    rows = list(csv.DictReader(Path(csv_path).open(encoding="utf-8")))
    seen: dict[tuple, int] = {}   # (date, normdesc, amount, currency) -> row

    for i, r in enumerate(rows, start=2):  # row 1 is the header
        A = result.anomalies.append
        desc = (r["description"] or "").strip()
        norm_desc = re.sub(r"[^a-z0-9]", "", desc.lower())

        date, dnote = _parse_date(r["date"])
        if dnote:
            A(Anomaly(i, "date", dnote, "parsed with the noted assumption"))
        if date is None:
            A(Anomaly(i, "date", f"could not parse date '{r['date']}'",
                      "row skipped", True))
            result.skipped += 1
            continue

        amount = _parse_amount(r["amount"])
        if amount is None:
            A(Anomaly(i, "amount", f"unparseable amount '{r['amount']}'",
                      "row skipped", True))
            result.skipped += 1
            continue
        if amount == 0:
            A(Anomaly(i, "zero_amount", f"'{desc}' has amount 0",
                      "row skipped (no financial effect)"))
            result.skipped += 1
            continue

        currency = (r["currency"] or "").strip().upper()
        if currency == "":
            currency = DEFAULT_CURRENCY
            A(Anomaly(i, "currency", f"'{desc}' has no currency",
                      f"assumed {DEFAULT_CURRENCY}"))
        rate = FX_RATES.get(currency)
        if rate is None:
            A(Anomaly(i, "currency", f"unknown currency '{currency}'",
                      "assumed INR", True))
            rate = 1.0
        if currency != "INR":
            A(Anomaly(i, "fx", f"'{desc}' {amount} {currency}",
                      f"converted to ₹{round(amount*rate,2)} at {rate}/USD"))
        amount_inr = round(amount * rate, 2)

        payer = _canon_name(r["paid_by"])
        if not payer:
            A(Anomaly(i, "missing_payer", f"'{desc}' has no paid_by",
                      "row skipped — cannot attribute", True))
            result.skipped += 1
            continue

        # Duplicate: same payer + date + amount + currency, even if the text
        # differs ("Dinner at Marina Bites" vs "dinner - marina bites").
        key = (date, payer, amount, currency)
        if key in seen:
            A(Anomaly(i, "duplicate",
                      f"'{desc}' looks like a duplicate of row {seen[key]} "
                      f"(same payer/date/amount)",
                      "skipped as duplicate — restore on approval", True))
            result.skipped += 1
            continue
        seen[key] = i

        split_type = (r["split_type"] or "").strip()
        people = _split_people(r["split_with"])

        # Settlement: blank split_type + a single counterparty → a transfer.
        if split_type == "" and len(people) == 1:
            A(Anomaly(i, "settlement", f"'{desc}' is a transfer, not an expense",
                      f"recorded as settlement {payer} → {people[0]}"))
            result.expenses.append(Expense(
                row=i, date=date, description=desc, paid_by=payer,
                amount_inr=amount_inr, shares={}, is_settlement=True,
                recipient=people[0]))
            continue

        # Membership: drop participants not active on this date.
        active, dropped = [], []
        for p in people:
            win = MEMBERSHIP.get(p)
            if win and not (win[0] <= date <= win[1]):
                dropped.append(p)
            else:
                active.append(p)
        if dropped:
            A(Anomaly(i, "membership",
                      f"{', '.join(dropped)} not resident on {date} for '{desc}'",
                      f"removed from the split; re-split among {len(active)}", True))
        people = active

        # Reassign guest shares to their sponsor.
        for guest, sponsor in GUEST_SPONSOR.items():
            if guest in people:
                people = [sponsor if x == guest else x for x in people]
                A(Anomaly(i, "guest", f"{guest} (guest) in '{desc}'",
                          f"{guest}'s share absorbed by {sponsor}"))

        if not people:
            A(Anomaly(i, "empty_split", f"'{desc}' has no active participants",
                      "row skipped", True))
            result.skipped += 1
            continue

        shares = _compute_shares(amount_inr, people, split_type,
                                 r["split_details"], i, result.anomalies)
        # Merge any duplicate keys produced by guest reassignment.
        merged: dict[str, float] = {}
        for k, v in shares.items():
            merged[k] = round(merged.get(k, 0) + v, 2)

        result.expenses.append(Expense(
            row=i, date=date, description=desc, paid_by=payer,
            amount_inr=amount_inr, shares=merged))

    return result


def net_balances(result: ImportResult) -> dict[str, float]:
    """Per person: positive = owed to them, negative = they owe."""
    bal: dict[str, float] = {}
    for e in result.expenses:
        if e.is_settlement:
            # payer paid recipient back → payer owes less, recipient owed less.
            bal[e.paid_by] = round(bal.get(e.paid_by, 0) + e.amount_inr, 2)
            if e.recipient:
                bal[e.recipient] = round(bal.get(e.recipient, 0) - e.amount_inr, 2)
            continue
        bal[e.paid_by] = round(bal.get(e.paid_by, 0) + e.amount_inr, 2)
        for person, owed in e.shares.items():
            bal[person] = round(bal.get(person, 0) - owed, 2)
    return {k: round(v, 2) for k, v in bal.items()}


def settle_up(balances: dict[str, float]) -> list[tuple[str, str, float]]:
    """Greedy minimum-cash-flow: list of (debtor, creditor, amount)."""
    creditors = sorted(((p, v) for p, v in balances.items() if v > 0.5),
                       key=lambda x: -x[1])
    debtors = sorted(((p, -v) for p, v in balances.items() if v < -0.5),
                     key=lambda x: -x[1])
    creditors = [list(c) for c in creditors]
    debtors = [list(d) for d in debtors]
    plan: list[tuple[str, str, float]] = []
    i = j = 0
    while i < len(debtors) and j < len(creditors):
        pay = min(debtors[i][1], creditors[j][1])
        plan.append((debtors[i][0], creditors[j][0], round(pay, 2)))
        debtors[i][1] -= pay
        creditors[j][1] -= pay
        if debtors[i][1] < 0.5:
            i += 1
        if creditors[j][1] < 0.5:
            j += 1
    return plan


def report_markdown(result: ImportResult) -> str:
    bal = net_balances(result)
    plan = settle_up(bal)
    kept = [e for e in result.expenses if not e.is_settlement]
    setts = [e for e in result.expenses if e.is_settlement]
    approvals = [a for a in result.anomalies if a.needs_approval]

    out = ["# Import Report", "",
           f"_Generated from `expenses_export.csv` — "
           f"{dt.date.today().isoformat()}._", "",
           "## Summary", "",
           f"- Rows read: **{len(kept) + len(setts) + result.skipped}**",
           f"- Expenses kept: **{len(kept)}**",
           f"- Settlements/transfers: **{len(setts)}**",
           f"- Rows skipped: **{result.skipped}**",
           f"- Anomalies detected: **{len(result.anomalies)}** "
           f"(**{len(approvals)}** need approval)", "",
           "## Who pays whom (final settle-up)", ""]
    for d, c, a in plan:
        out.append(f"- **{d} → {c}:** ₹{a:,.2f}")
    out += ["", "## Net position", "",
            "| Person | Net (₹) |", "|---|---|"]
    for p, v in sorted(bal.items(), key=lambda x: -x[1]):
        out.append(f"| {p} | {v:+,.2f} |")

    out += ["", "## Anomalies & actions taken", "",
            "| Row | Type | What we found | Action | Approval? |",
            "|---|---|---|---|---|"]
    for a in result.anomalies:
        out.append(f"| {a.row} | {a.kind} | {a.detail} | {a.action} | "
                   f"{'⚠️ yes' if a.needs_approval else 'auto'} |")

    out += ["", "## Assumptions",
            f"- FX: 1 USD = ₹{FX_RATES['USD']} (fixed snapshot).",
            "- Blank currency → INR.",
            "- Membership windows: Meera through Mar 2026; Sam from Apr 8 2026; "
            "others full period. Dev is a recurring visitor; Kabir is a guest "
            "whose share is absorbed by Dev.",
            "- Settle-up uses greedy minimum-cash-flow (fewest transfers)."]
    return "\n".join(out) + "\n"


def breakdown(result: ImportResult, person: str) -> list[dict]:
    """Every line behind a person's balance (for Rohan)."""
    lines = []
    for e in result.expenses:
        if e.is_settlement:
            if e.paid_by == person:
                lines.append({"date": str(e.date), "description": e.description,
                              "effect": +e.amount_inr, "note": f"you paid {e.recipient}"})
            elif e.recipient == person:
                lines.append({"date": str(e.date), "description": e.description,
                              "effect": -e.amount_inr, "note": f"{e.paid_by} paid you"})
            continue
        owed = e.shares.get(person, 0)
        paid = e.amount_inr if e.paid_by == person else 0
        if owed or paid:
            lines.append({"date": str(e.date), "description": e.description,
                          "paid": round(paid, 2), "your_share": round(owed, 2),
                          "effect": round(paid - owed, 2)})
    return lines
