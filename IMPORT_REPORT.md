# Import Report

_Generated from `expenses_export.csv` — 2026-06-14._

## Summary

- Rows read: **42**
- Expenses kept: **38**
- Settlements/transfers: **1**
- Rows skipped: **3**
- Anomalies detected: **26** (**6** need approval)

## Who pays whom (final settle-up)

- **Priya → Aisha:** ₹61,159.06
- **Rohan → Aisha:** ₹30,951.88
- **Rohan → Dev:** ₹23,288.18
- **Meera → Dev:** ₹5,798.82
- **Meera → Sam:** ₹14,722.50

## Net position

| Person | Net (₹) |
|---|---|
| Aisha | +92,110.94 |
| Dev | +29,087.00 |
| Sam | +14,722.50 |
| Meera | -20,521.32 |
| Rohan | -54,240.06 |
| Priya | -61,159.06 |

## Anomalies & actions taken

| Row | Type | What we found | Action | Approval? |
|---|---|---|---|---|
| 6 | duplicate | 'dinner - marina bites' looks like a duplicate of row 5 (same payer/date/amount) | skipped as duplicate — restore on approval | ⚠️ yes |
| 13 | missing_payer | 'House cleaning supplies' has no paid_by | row skipped — cannot attribute | ⚠️ yes |
| 14 | settlement | 'Rohan paid Aisha back' is a transfer, not an expense | recorded as settlement Rohan → Aisha | auto |
| 15 | percentage_sum | percentages sum to 110.0%, not 100% | renormalised to 100% | ⚠️ yes |
| 16 | date | ambiguous date '01/03/2026' — read as DD/MM (01/03) | parsed with the noted assumption | auto |
| 18 | date | ambiguous date '05/03/2026' — read as DD/MM (05/03) | parsed with the noted assumption | auto |
| 19 | date | ambiguous date '08/03/2026' — read as DD/MM (08/03) | parsed with the noted assumption | auto |
| 20 | date | ambiguous date '09/03/2026' — read as DD/MM (09/03) | parsed with the noted assumption | auto |
| 20 | fx | 'Goa villa booking' 540.0 USD | converted to ₹44820.0 at 83.0/USD | auto |
| 21 | date | ambiguous date '10/03/2026' — read as DD/MM (10/03) | parsed with the noted assumption | auto |
| 21 | fx | 'Beach shack lunch' 84.0 USD | converted to ₹6972.0 at 83.0/USD | auto |
| 22 | date | ambiguous date '10/03/2026' — read as DD/MM (10/03) | parsed with the noted assumption | auto |
| 23 | date | ambiguous date '11/03/2026' — read as DD/MM (11/03) | parsed with the noted assumption | auto |
| 23 | fx | 'Parasailing' 150.0 USD | converted to ₹12450.0 at 83.0/USD | auto |
| 23 | guest | Kabir (guest) in 'Parasailing' | Kabir's share absorbed by Dev | auto |
| 24 | date | ambiguous date '11/03/2026' — read as DD/MM (11/03) | parsed with the noted assumption | auto |
| 25 | date | ambiguous date '11/03/2026' — read as DD/MM (11/03) | parsed with the noted assumption | auto |
| 26 | date | ambiguous date '12/03/2026' — read as DD/MM (12/03) | parsed with the noted assumption | auto |
| 26 | fx | 'Parasailing refund' -30.0 USD | converted to ₹-2490.0 at 83.0/USD | auto |
| 27 | date | year missing in 'Mar 14' — assumed 2026 | parsed with the noted assumption | auto |
| 28 | currency | 'Groceries DMart' has no currency | assumed INR | auto |
| 31 | zero_amount | 'Dinner order Swiggy' has amount 0 | row skipped (no financial effect) | auto |
| 32 | percentage_sum | percentages sum to 110.0%, not 100% | renormalised to 100% | ⚠️ yes |
| 34 | date | ambiguous date '04/05/2026' — read as DD/MM (04/05) | parsed with the noted assumption | auto |
| 36 | membership | Meera not resident on 2026-04-02 for 'Groceries BigBasket' | removed from the split; re-split among 3 | ⚠️ yes |
| 42 | split_conflict | split_type=equal but share details present | honoured split_type=equal, ignored the share details | ⚠️ yes |

## Assumptions
- FX: 1 USD = ₹83.0 (fixed snapshot).
- Blank currency → INR.
- Membership windows: Meera through Mar 2026; Sam from Apr 8 2026; others full period. Dev is a recurring visitor; Kabir is a guest whose share is absorbed by Dev.
- Settle-up uses greedy minimum-cash-flow (fewest transfers).
