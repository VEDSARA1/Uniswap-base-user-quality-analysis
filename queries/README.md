# Query source

These six SQL files are the **canonical production SQL**, copied from the Dune queries that power the
[V1 dashboard](https://dune.com/13seeker/uniswap-on-base-user-quality-activity-v1). Running a file in the
Dune editor reproduces the dashboard panel it belongs to.

| Query | Purpose | Anomaly exclusion | Link |
|---|---|---|---|
| 8733968 | Overview KPIs | volume only | https://dune.com/queries/8733968 |
| 8733972 | Daily activity | volume only | https://dune.com/queries/8733972 |
| 8731863 | Transaction-frequency distribution | none | https://dune.com/queries/8731863 |
| 8733974 | Wallet/transaction concentration | volume only | https://dune.com/queries/8733974 |
| 8733441 | Observed return behavior | none | https://dune.com/queries/8733441 |
| 8733980 | Methodology and definitions | n/a (static table) | https://dune.com/queries/8733980 |

## Conventions used by every query

- **Partition pruning.** `dex.trades` is partitioned on `blockchain`, `project` and `block_month`.
  Every query filters all three plus `block_date`, which keeps a full refresh of the six queries at
  roughly 3.7 Dune credits. Dropping the `block_month` predicate scans all Base Uniswap history.
- **Transaction hashes are `varbinary`.** The excluded hashes are written as unquoted hex literals
  (`0x818c…`). Quoted strings raise a type error.
- **The exclusion never filters rows.** The three anomalous hashes sit in a `LEFT JOIN`ed CTE and are
  applied only inside `SUM(amount_usd)`, so wallet and transaction counts are identical with or
  without it.
- **"Returned on a 2nd day"** means activity on any later calendar day inside the window, not
  activity within two days.
