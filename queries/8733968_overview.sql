-- Dune query 8733968 — canonical source: https://dune.com/queries/8733968
-- Uniswap on Base — Activity, Concentration & Return Behavior V1 · Query 1: Overview KPIs
-- Window : 2026-08-16 .. 2026-09-15 inclusive (31 days)
-- Scope  : dex.trades, blockchain = 'base', project = 'uniswap' (v2, v3, v4)
-- Wallet : tx_from | Transaction: distinct tx_hash | Volume: SUM(amount_usd) over trade rows
-- Data quality: three 2026-08-18 Uniswap v4 transactions with reported swap amounts not backed by
--               token transfers (~$28.23B) are excluded from VOLUME ONLY. Counts are unaffected.

WITH anomalous_volume_txs (tx_hash) AS (
  VALUES
    (0x818c97aad39b84bd6502bf8fe56559648a0218dce1f2e94d5aff2a16e1691553),
    (0x675ee1d70de1437ebb21e68a7d87740b57006ff38e42ba08be50452078690bbf),
    (0x82946e71476288c9a8dc58b3d5f03f0ab98280fb9d281bcc7d60ba9f996e5f47)
),

wallet_activity AS (
  SELECT
    t.tx_from,
    COUNT(DISTINCT t.tx_hash)                                   AS txs,
    COUNT(DISTINCT t.block_date)                                AS active_days,
    SUM(CASE WHEN a.tx_hash IS NULL THEN t.amount_usd END)      AS volume_usd
  FROM dex.trades t
  LEFT JOIN anomalous_volume_txs a ON a.tx_hash = t.tx_hash
  WHERE t.blockchain  = 'base'
    AND t.project     = 'uniswap'
    AND t.block_month BETWEEN DATE '2026-08-01' AND DATE '2026-09-01'
    AND t.block_date  BETWEEN DATE '2026-08-16' AND DATE '2026-09-15'
  GROUP BY 1
)

SELECT
  COUNT(*)                                          AS unique_wallets,
  SUM(txs)                                          AS transactions,
  SUM(volume_usd)                                   AS volume_usd,
  SUM(active_days) / 31.0                           AS avg_daily_active_wallets,
  approx_percentile(txs, 0.5)                       AS median_txs_per_wallet,
  approx_percentile(active_days, 0.5)               AS median_active_days,
  100.0 * COUNT_IF(active_days >= 2) / COUNT(*)     AS pct_wallets_active_2plus_days
FROM wallet_activity
