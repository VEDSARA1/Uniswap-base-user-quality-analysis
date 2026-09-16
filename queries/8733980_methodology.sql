-- Dune query 8733980 — canonical source: https://dune.com/queries/8733980
-- Uniswap on Base — User Quality & Activity V1 · Query 6: Methodology & definitions
-- Static reference table (no table scans)

SELECT sort_order, section, item, definition
FROM (
  VALUES
    (1,  'Scope',        'Data source',            'dex.trades (Dune Spellbook), blockchain = ''base'', project = ''uniswap'', versions 2, 3 and 4.'),
    (2,  'Scope',        'Window',                 'Fixed: 2026-08-16 to 2026-09-15 inclusive (31 UTC calendar days), filtered on block_date with block_month partition pruning.'),
    (3,  'Definitions',  'Participating wallet',   'tx_from: the address that signed and sent the transaction. taker is not used because it is frequently a router or aggregator contract.'),
    (4,  'Definitions',  'Transaction',            'Distinct tx_hash. One transaction can produce multiple trade rows (multi-hop or multi-pool swaps).'),
    (5,  'Definitions',  'Volume (USD)',           'SUM(amount_usd) across trade rows, excluding the three anomalous transactions listed under Data quality. Multi-hop swaps count each hop; rows without a USD price (about 10%) contribute no volume.'),
    (6,  'Definitions',  'Active day',             'A UTC calendar day (block_date) on which the wallet made at least one Uniswap trade.'),
    (7,  'Distribution', 'Frequency buckets',      'Wallets grouped by distinct transactions in the window: 1, 2-10, 11-50, 51-100, 101-500, 501-1,000, >1,000. Descriptive only.'),
    (8,  'Concentration','Concentration curve',    'Wallets ranked by transactions (descending) and split into 1,000 equal groups; shows the cumulative share of transactions and USD volume held by the top X% of wallets.'),
    (9,  'Retention',    'First active date',      'Earliest block_date in the window. Not a lifetime first trade: wallets active before 2026-08-16 are included.'),
    (10, 'Retention',    'Retention',              'Activity on a later calendar day. Additional transactions on the same day do not count.'),
    (11, 'Retention',    'Returned within N days', 'Active on at least one day from first_date + 1 to first_date + N.'),
    (12, 'Retention',    'Cohort eligibility',     '2nd-day return: first_date <= 2026-09-14. D7: <= 2026-09-08. D14: <= 2026-09-01. D30: 2026-08-16 only.'),
    (13, 'Retention',    'Segments',               'Casual 1-10, Regular 11-500, High-frequency >500 transactions over the full window. Segments overlap the retention period, so segment-level retention is descriptive, not predictive.'),
    (14, 'Data quality', 'Aug 18 anomalous volume', 'On 2026-08-18, three Uniswap v4 transactions reported USD swap amounts inconsistent with observed ERC-20 settlement. Raw v4 swap events match dex.trades 1:1; the transactions contain unusually large swaps in zero-liquidity pools and associated counter-tokens minted directly to PoolManager, consistent with Uniswap v4''s atomic/flash-accounting design. Across the three transactions, about $28.15B of reported USDC swap amounts corresponded to under 0.001 USDC of ERC-20 transfers. Together they produced about $28.23B of anomalous reported volume (99.6% of that day).'),
    (15, 'Data quality', 'Excluded transactions',  '0x818c97aad39b84bd6502bf8fe56559648a0218dce1f2e94d5aff2a16e1691553, 0x675ee1d70de1437ebb21e68a7d87740b57006ff38e42ba08be50452078690bbf, 0x82946e71476288c9a8dc58b3d5f03f0ab98280fb9d281bcc7d60ba9f996e5f47.'),
    (16, 'Data quality', 'Exclusion scope',        'The three transactions are excluded from volume metrics only (Overview volume, Daily volume, volume concentration). Wallet counts, transaction counts, frequency distribution and retention include them. No generic amount_usd threshold is applied; smaller unbacked transactions, if any, are not removed.'),
    (17, 'Limitations',  'No bot exclusion',       'No wallets are excluded or labeled as bots. High-frequency wallets account for most transactions.'),
    (18, 'Limitations',  'Smart-contract wallets', 'ERC-4337 bundlers and relayers appear as a single tx_from representing many end users; EIP-7702 delegated EOAs appear as ordinary wallets.'),
    (19, 'Limitations',  'D30 cohort',             'D30 retention uses only the 2026-08-16 cohort, which is dominated by previously active wallets.')
) AS t (sort_order, section, item, definition)
ORDER BY sort_order
