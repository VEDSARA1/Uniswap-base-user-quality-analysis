-- Dune query 8733974 — canonical source: https://dune.com/queries/8733974
-- Uniswap on Base — Activity, Concentration & Return Behavior V1 · Query 4: Wallet-share vs transaction-share concentration
-- Window : 2026-08-16 .. 2026-09-15 inclusive (31 days)
-- Scope  : dex.trades, blockchain = 'base', project = 'uniswap' (v2, v3, v4)
-- Wallet : tx_from | Transaction: distinct tx_hash | Volume: SUM(amount_usd) over trade rows
-- Method : wallets ranked by transactions desc, split into 1,000 equal groups (0.1% of wallets each)
-- Data quality: three 2026-08-18 Uniswap v4 transactions with reported swap amounts not backed by
--               token transfers (~$28.23B) are excluded from VOLUME ONLY. Counts and ranking are unaffected.

WITH anomalous_volume_txs (tx_hash) AS (
  VALUES
    (0x818c97aad39b84bd6502bf8fe56559648a0218dce1f2e94d5aff2a16e1691553),
    (0x675ee1d70de1437ebb21e68a7d87740b57006ff38e42ba08be50452078690bbf),
    (0x82946e71476288c9a8dc58b3d5f03f0ab98280fb9d281bcc7d60ba9f996e5f47)
),

wallet_activity AS (
  SELECT
    t.tx_from,
    COUNT(DISTINCT t.tx_hash)                                             AS txs,
    COALESCE(SUM(CASE WHEN a.tx_hash IS NULL THEN t.amount_usd END), 0)   AS volume_usd
  FROM dex.trades t
  LEFT JOIN anomalous_volume_txs a ON a.tx_hash = t.tx_hash
  WHERE t.blockchain  = 'base'
    AND t.project     = 'uniswap'
    AND t.block_month BETWEEN DATE '2026-08-01' AND DATE '2026-09-01'
    AND t.block_date  BETWEEN DATE '2026-08-16' AND DATE '2026-09-15'
  GROUP BY 1
),

ranked AS (
  SELECT
    txs,
    volume_usd,
    NTILE(1000) OVER (ORDER BY txs DESC, tx_from) AS rank_group
  FROM wallet_activity
),

by_group AS (
  SELECT
    rank_group,
    COUNT(*)        AS wallets,
    SUM(txs)        AS txs,
    SUM(volume_usd) AS volume_usd
  FROM ranked
  GROUP BY 1
)

SELECT
  rank_group / 10.0                                                            AS top_wallets_pct,
  SUM(wallets) OVER (ORDER BY rank_group)                                      AS cumulative_wallets,
  100.0 * SUM(txs) OVER (ORDER BY rank_group) / SUM(txs) OVER ()               AS cumulative_tx_share_pct,
  100.0 * SUM(volume_usd) OVER (ORDER BY rank_group) / SUM(volume_usd) OVER () AS cumulative_volume_share_pct,
  rank_group / 10.0                                                            AS equal_share_reference_pct
FROM by_group
ORDER BY rank_group
