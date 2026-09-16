# Aug 18, 2026 data-quality case study

Three Uniswap v4 transactions accounted for approximately $28.23B of reported volume on Aug 18, 2026.

Excluded hashes:

- `0x818c97aad39b84bd6502bf8fe56559648a0218dce1f2e94d5aff2a16e1691553`
- `0x675ee1d70de1437ebb21e68a7d87740b57006ff38e42ba08be50452078690bbf`
- `0x82946e71476288c9a8dc58b3d5f03f0ab98280fb9d281bcc7d60ba9f996e5f47`

Key checks:

- Raw `uniswap_v4_base.poolmanager_evt_swap` events matched `dex.trades` rows 1:1: 510/510, 510/510, and 256/256.
- The largest nominal USDC rows came from pools with exactly zero liquidity.
- `dex.trades` reported about 28.15B USDC of swap amounts, while ERC-20 transfer logs showed only 0.000247 USDC transferred into PoolManager and none leaving it.
- The pattern is consistent with Uniswap v4 atomic/flash-accounting behavior and does not indicate a Dune transformation defect.
- The three transactions are excluded from volume metrics only. Wallet counts, transaction counts, frequency and return behavior retain them.
- No malicious intent is inferred.

## Diagnostic queries

| Query | Check | Link |
|---|---|---|
| 8740049 | Raw v4 Swap events reconciled 1:1 against `dex.trades` | https://dune.com/queries/8740049 |
| 8740085 | Reported token amounts vs ERC-20 transfers and net PoolManager settlement | https://dune.com/queries/8740085 |
