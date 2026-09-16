# Uniswap on Base - User Quality & Activity (V1)

A 31-day on-chain analysis of Uniswap activity on Base, focused on participation, transaction-frequency concentration, wallet concentration, observed return behavior, and data quality.

**Observation window:** 16 August - 15 September 2026 (31 UTC calendar days)  
**Scope:** Base, Uniswap v2/v3/v4, Dune Spellbook `dex.trades`  
**Wallet unit:** `tx_from` (transaction signer)  
**Transaction unit:** distinct `tx_hash`

## Dashboard

[Open the Dune dashboard](https://dune.com/13seeker/uniswap-on-base-user-quality-activity-v1)

## Final V1 results

| Metric | Result |
|---|---:|
| Unique wallets | 569,864 |
| Distinct transactions | 19,932,002 |
| Adjusted reported volume | $8,260,205,266 |
| Average daily active wallets | 58,579 |
| Median transactions / wallet | 2 |
| Median active days / wallet | 1 |
| Wallets active on 2+ days | 37.08% |

## Main observations

- 82.8% of wallets made 10 or fewer transactions, while 0.42% of wallets made more than 1,000 and generated 59.46% of all transactions.
- The top 1% of wallets represented 68.94% of transactions and 71.54% of adjusted reported volume.
- Across all eligible wallets, observed return was 38.26% at D2 and 37.07% at D7. Segment-level return is descriptive because the segment is defined over the full window.
- Three Uniswap v4 transactions produced about $28.23B of nominal reported volume on Aug 18. Raw V4 events matched `dex.trades` exactly, but reported USDC swap amounts were not backed by comparable ERC-20 settlement. The three transactions were excluded from volume metrics only.

## Data-quality treatment

The anomaly investigation found a 1:1 match between raw V4 `PoolManager` Swap events and `dex.trades`, zero-liquidity pools behind the largest nominal rows, and about 28.15B reported USDC swap amounts versus only 0.000247 USDC transferred into PoolManager and none leaving it.

See [`diagnostics/AUG18_ANOMALY.md`](diagnostics/AUG18_ANOMALY.md) and the full report.

## Methodology boundaries

- No wallets are labeled as bots.
- `tx_from` is an observed signer, not necessarily a final end-user identity.
- First active date is the earliest date within the 31-day window, not a lifetime-first interaction.
- D30 is based only on the Aug 16 cohort.
- Return segments use full-window transaction counts, so segment-level comparisons contain temporal leakage.
- Multi-hop swaps count each trade row toward summed volume.
- Rows without USD pricing contribute no volume.
- The anomaly treatment is an auditable transaction-hash exclusion, not a generic `amount_usd` threshold.

## Repository contents

```text
report/
  Uniswap_on_Base_User_Quality_Activity_V1_2_Serious_Report.docx   (current)
  Uniswap_on_Base_User_Quality_Activity_V1_1_Serious_Report.pdf    (older rendering)

queries/
  8733968_overview.sql
  8733972_daily_activity.sql
  8731863_transaction_frequency.sql
  8733974_concentration.sql
  8733441_return_behavior.sql
  8733980_methodology.sql
  README.md

diagnostics/
  AUG18_ANOMALY.md
```

## Report

[Editable DOCX report - V1.2, current](report/Uniswap_on_Base_User_Quality_Activity_V1_2_Serious_Report.docx)  
[PDF report - V1.1](report/Uniswap_on_Base_User_Quality_Activity_V1_1_Serious_Report.pdf)

> **Note.** V1.2 renames the all-wallet return metric from "D2" to "2nd-day return", because it measures
> activity on *any* later calendar day inside the window, not activity within two days. No figure changed.
> The PDF is still the V1.1 rendering and carries the old label; re-export it from the V1.2 DOCX to refresh it.

The Dune queries linked above are the production source of truth; the SQL files under `queries/` are exact copies of that production SQL.

## Project status

**V1 complete.**
