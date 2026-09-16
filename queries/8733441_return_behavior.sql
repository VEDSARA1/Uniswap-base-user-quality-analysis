-- Dune query 8733441 — canonical source: https://dune.com/queries/8733441
-- Uniswap on Base — Activity, Concentration & Return Behavior V1 · Query 5: Observed return behavior
-- Window      : 2026-08-16 .. 2026-09-15 inclusive (31 days)
-- Scope       : dex.trades, blockchain = 'base', project = 'uniswap' (v2, v3, v4)
-- Wallet      : tx_from | First active date: earliest block_date in window (not lifetime first trade)
-- Return      : activity on a later calendar day; "within N days" = any active day in first_date+1 .. first_date+N
--               "Returned on a later day" = activity on ANY later calendar day inside the window.
--               This is not conventional D2 retention and does not mean return within 48 hours.
-- Eligibility : later day first_date <= 2026-09-14 | D7 <= 2026-09-08 | D14 <= 2026-09-01 | D30 = 2026-08-16
-- Segments    : full-window tx count (descriptive only; overlaps the outcome period)
-- No anomaly exclusion: this query measures activity, not volume.

WITH wallet_days AS (
  SELECT
    tx_from,
    block_date,
    COUNT(DISTINCT tx_hash) AS txs
  FROM dex.trades
  WHERE blockchain  = 'base'
    AND project     = 'uniswap'
    AND block_month BETWEEN DATE '2026-08-01' AND DATE '2026-09-01'
    AND block_date  BETWEEN DATE '2026-08-16' AND DATE '2026-09-15'
  GROUP BY 1, 2
),

wallet_first AS (
  SELECT
    tx_from,
    MIN(block_date) AS first_date,
    SUM(txs)        AS txs,
    COUNT(*)        AS active_days
  FROM wallet_days
  GROUP BY 1
),

wallet_retention AS (
  SELECT
    f.tx_from,
    f.first_date,
    f.txs,
    f.active_days,
    COUNT_IF(d.block_date > f.first_date) > 0                                                        AS returned_any,
    COUNT_IF(d.block_date BETWEEN date_add('day', 1, f.first_date) AND date_add('day', 7,  f.first_date)) > 0 AS returned_7d,
    COUNT_IF(d.block_date BETWEEN date_add('day', 1, f.first_date) AND date_add('day', 14, f.first_date)) > 0 AS returned_14d,
    COUNT_IF(d.block_date BETWEEN date_add('day', 1, f.first_date) AND date_add('day', 30, f.first_date)) > 0 AS returned_30d
  FROM wallet_first f
  JOIN wallet_days d ON d.tx_from = f.tx_from
  GROUP BY 1, 2, 3, 4
),

segmented AS (
  SELECT
    *,
    CASE WHEN txs <= 10 THEN 1 WHEN txs <= 500 THEN 2 ELSE 3 END AS segment_order
  FROM wallet_retention
)

SELECT
  CASE WHEN GROUPING(segment_order) = 1 THEN 4 ELSE segment_order END        AS segment_order,
  CASE
    WHEN GROUPING(segment_order) = 1 THEN 'All wallets'
    WHEN segment_order = 1 THEN 'Casual (1-10 tx)'
    WHEN segment_order = 2 THEN 'Regular (11-500 tx)'
    ELSE 'High-frequency (>500 tx)'
  END                                                                         AS segment,
  COUNT(*)                                                                    AS wallets,
  approx_percentile(active_days, 0.5)                                         AS median_active_days,

  COUNT_IF(first_date <= DATE '2026-09-14')                                   AS eligible_2nd_day,
  100.0 * COUNT_IF(first_date <= DATE '2026-09-14' AND returned_any)
        / NULLIF(COUNT_IF(first_date <= DATE '2026-09-14'), 0)                AS pct_returned_2nd_day,

  COUNT_IF(first_date <= DATE '2026-09-08')                                   AS eligible_d7,
  100.0 * COUNT_IF(first_date <= DATE '2026-09-08' AND returned_7d)
        / NULLIF(COUNT_IF(first_date <= DATE '2026-09-08'), 0)                AS retention_d7_pct,

  COUNT_IF(first_date <= DATE '2026-09-01')                                   AS eligible_d14,
  100.0 * COUNT_IF(first_date <= DATE '2026-09-01' AND returned_14d)
        / NULLIF(COUNT_IF(first_date <= DATE '2026-09-01'), 0)                AS retention_d14_pct,

  COUNT_IF(first_date = DATE '2026-08-16')                                    AS eligible_d30,
  100.0 * COUNT_IF(first_date = DATE '2026-08-16' AND returned_30d)
        / NULLIF(COUNT_IF(first_date = DATE '2026-08-16'), 0)                 AS retention_d30_pct
FROM segmented
GROUP BY GROUPING SETS ((segment_order), ())
ORDER BY 1
