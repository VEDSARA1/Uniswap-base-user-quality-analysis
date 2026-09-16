-- Dune query 8733980 — canonical source: https://dune.com/queries/8733980
-- Uniswap on Base — Activity, Concentration & Return Behavior V1 · Query 6: Methodology & definitions
-- Static reference table (no table scans)

SELECT sort_order, section, item, definition
FROM (
  VALUES
    (1,  'Scope',        'Data source',            'dex.trades (Dune Spellbook), blockchain = ''base'', project = ''uniswap'', versions 2, 3 and 4.'),
    (2,  'Scope',        'Window',                 'Fixed: 2026-08-16 to 2026-09-15 inclusive (31 UTC calendar days), filtered on block_date with block_month partition pruning.'),
    (3,  'Scope',        'V1 snapshot',            'Snapshot date 2026-09-16. Dune datasets are continuously refreshed, so later executions may return different figures than the frozen V1 record.'),
    (4,  'Definitions',  'Participating wallet',   'tx_from: the address that signed and sent the transaction. taker is not used because it is frequently a router or aggregator contract.'),
    (5,  'Definitions',  'Transaction',            'Distinct tx_hash. One transaction can produce multiple trade rows (multi-hop or multi-pool swaps).'),
    (6,  'Definitions',  'Volume (USD)',           'SUM(amount_usd) across trade rows, excluding the three anomalous transactions listed under Data quality. This is reported USD activity, not necessarily economically settled notional. Multi-hop swaps count each hop; rows without a USD price (about 10%) contribute no volume.'),
    (7,  'Definitions',  'Active day',             'A UTC calendar day (block_date) on which the wallet made at least one Uniswap trade.'),
    (8,  'Distribution', 'Frequency buckets',      'Wallets grouped by distinct transactions in the window: 1, 2-10, 11-50, 51-100, 101-500, 501-1,000, >1,000. Descriptive only.'),
    (9,  'Concentration','Concentration curve',    'Wallets ranked by transactions (descending) and split into 1,000 equal groups; shows the cumulative share of transactions and USD volume held by the top X% of wallets.'),
    (10, 'Return',       'First active date',      'Earliest block_date in the window. Not a lifetime first trade: wallets active before 2026-08-16 are included.'),
    (11, 'Return',       'Observed return',        'Activity on a later UTC calendar day than the first active date. Additional transactions on the same day do not count. This is not conventional D2 retention and does not mean return within 48 hours.'),
    (12, 'Return',       'Returned within N days', 'Active on at least one day from first_date + 1 to first_date + N.'),
    (13, 'Return',       'Cohort eligibility',     'Later-day return: first_date <= 2026-09-14. 7-day: <= 2026-09-08. 14-day: <= 2026-09-01. 30-day: 2026-08-16 cohort only.'),
    (14, 'Return',       'Segments',               'Casual 1-10, Regular 11-500, High-frequency >500 transactions over the full window. Segments overlap the observation period, so segment-level return behavior is descriptive, not predictive.'),
    (15, 'Data quality', 'Aug 18 anomalous volume', 'On 2026-08-18, three Uniswap v4 transactions reported USD swap amounts inconsistent with observed ERC-20 settlement. Raw v4 swap events match dex.trades 1:1; the transactions contain unusually large swaps in zero-liquidity pools and associated counter-tokens minted directly to PoolManager, consistent with Uniswap v4''s atomic/flash-accounting design. Across the three transactions, about $28.15B of reported USDC swap amounts corresponded to under 0.001 USDC of ERC-20 transfers. Together they produced about $28.23B of anomalous reported volume (99.6% of that day).'),
    (16, 'Data quality', 'Excluded transactions',  '0x818c97aad39b84bd6502bf8fe56559648a0218dce1f2e94d5aff2a16e1691553, 0x675ee1d70de1437ebb21e68a7d87740b57006ff38e42ba08be50452078690bbf, 0x82946e71476288c9a8dc58b3d5f03f0ab98280fb9d281bcc7d60ba9f996e5f47.'),
    (17, 'Data quality', 'Exclusion scope',        'The three transactions are excluded from volume metrics only (Overview volume, Daily volume, volume concentration). Wallet counts, transaction counts, frequency distribution and return behavior include them. No generic amount_usd threshold is applied; smaller unbacked transactions, if any, are not removed.'),
    (18, 'Limitations',  'Signer is not a user',   'tx_from is the transaction signer, not necessarily a human user. A signer can represent a person, bot, smart contract, relayer, router, solver or other infrastructure.'),
    (19, 'Limitations',  'No bot classification',  'No wallets are excluded or labeled as bots. High-frequency wallets account for most transactions.'),
    (20, 'Limitations',  'Smart-contract wallets', 'ERC-4337 bundlers and relayers appear as a single tx_from representing many end users; EIP-7702 delegated EOAs appear as ordinary wallets.'),
    (21, 'Limitations',  '30-day cohort',          'The 30-day horizon uses only the 2026-08-16 cohort, which is dominated by previously active wallets, and should not be read as ordinary all-wallet 30-day retention.'),
    (22, 'Limitations',  'No benchmark',           'No cross-period, cross-chain or competing-DEX comparison is included.'),
    (23, 'Limitations',  'Scope of conclusions',   'V1 is a descriptive activity study. It does not identify individual humans, classify automation, or establish user quality.')
) AS t (sort_order, section, item, definition)
ORDER BY sort_order
