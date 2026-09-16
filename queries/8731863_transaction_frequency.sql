-- Dune query 8731863 — canonical source: https://dune.com/queries/8731863
-- Uniswap on Base — User Quality & Activity V1 · Query 3: Transaction-frequency distribution
-- Window : 2026-08-16 .. 2026-09-15 inclusive (31 days)
-- Scope  : dex.trades, blockchain = 'base', project = 'uniswap' (v2, v3, v4)
-- Wallet : tx_from | Transaction: distinct tx_hash | Buckets are descriptive only
-- No anomaly exclusion: this query counts wallets and transactions, not volume.

WITH wallet_activity AS (
  SELECT
    tx_from,
    COUNT(DISTINCT tx_hash)    AS txs,
    COUNT(DISTINCT block_date) AS active_days
  FROM dex.trades
  WHERE blockchain  = 'base'
    AND project     = 'uniswap'
    AND block_month BETWEEN DATE '2026-08-01' AND DATE '2026-09-01'
    AND block_date  BETWEEN DATE '2026-08-16' AND DATE '2026-09-15'
  GROUP BY 1
),

bucketed AS (
  SELECT
    txs,
    active_days,
    CASE
      WHEN txs = 1     THEN 1
      WHEN txs <= 10   THEN 2
      WHEN txs <= 50   THEN 3
      WHEN txs <= 100  THEN 4
      WHEN txs <= 500  THEN 5
      WHEN txs <= 1000 THEN 6
      ELSE 7
    END AS bucket_order
  FROM wallet_activity
)

SELECT
  bucket_order,
  CASE bucket_order
    WHEN 1 THEN '1'      WHEN 2 THEN '2-10'    WHEN 3 THEN '11-50'
    WHEN 4 THEN '51-100' WHEN 5 THEN '101-500' WHEN 6 THEN '501-1,000'
    ELSE '>1,000'
  END                                              AS tx_bucket,
  COUNT(*)                                         AS wallets,
  100.0 * COUNT(*) / SUM(COUNT(*)) OVER ()         AS pct_wallets,
  SUM(txs)                                         AS transactions,
  100.0 * SUM(txs) / SUM(SUM(txs)) OVER ()         AS pct_transactions,
  approx_percentile(active_days, 0.5)              AS median_active_days,
  AVG(CAST(active_days AS double))                 AS avg_active_days
FROM bucketed
GROUP BY 1
ORDER BY 1
