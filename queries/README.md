# Query source

The six Dune queries listed below are the canonical production source for
[Uniswap on Base — Activity, Concentration & Return Behavior (V1)](https://dune.com/13seeker/uniswap-on-base-activity-concentration-return-behavior-v1).
The SQL files in this directory are readable versions of that production SQL, kept in the repository so the
V1 record is legible without a Dune account. Header comments differ where terminology was aligned at the V1
freeze; the logic, filters and output columns are the same.

| Query | Purpose | Anomaly exclusion | Link |
|---|---|---|---|
| 8733968 | Overview KPIs | volume only | https://dune.com/queries/8733968 |
| 8733972 | Daily activity | volume only | https://dune.com/queries/8733972 |
| 8731863 | Transaction-frequency distribution | none | https://dune.com/queries/8731863 |
| 8733974 | Wallet/transaction concentration | volume only | https://dune.com/queries/8733974 |
| 8733441 | Observed return behavior | none | https://dune.com/queries/8733441 |
| 8733980 | Methodology and definitions | n/a (static table) | https://dune.com/queries/8733980 |

Diagnostic queries used for the Aug 18 case study are listed in
[`../diagnostics/AUG18_ANOMALY.md`](../diagnostics/AUG18_ANOMALY.md).

## Conventions used by every query

- **Partition pruning.** `dex.trades` is partitioned on `blockchain`, `project` and `block_month`.
  Every query filters all three plus `block_date`, which keeps a full refresh of the six queries at
  roughly 3.7 Dune credits. Dropping the `block_month` predicate scans all Base Uniswap history.
- **Transaction hashes are `varbinary`.** The excluded hashes are written as unquoted hex literals
  (`0x818c…`). Quoted strings raise a type error.
- **The exclusion never filters rows.** The three anomalous hashes sit in a `LEFT JOIN`ed CTE and are
  applied only inside `SUM(amount_usd)`, so wallet and transaction counts are identical with or
  without it.
- **Return means a later calendar day.** The all-wallet 38.26% figure counts activity on any later UTC
  calendar day inside the window, not activity within 48 hours. Column names keep a `d7` / `d14` / `d30`
  shorthand so the published queries and dashboard panels continue to resolve.

## Snapshot

V1 snapshot date: 16 September 2026. Dune's datasets are continuously refreshed, so re-executing these
queries may produce different figures than the frozen V1 record.
