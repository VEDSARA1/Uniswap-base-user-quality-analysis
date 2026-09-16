# Uniswap on Base — Activity, Concentration & Return Behavior (V1)

This study provides a 31-day descriptive analysis of Uniswap activity on Base, examining observed signer
participation, transaction frequency, activity concentration, and return behavior. It does not attempt to
identify individual humans, classify bots, or construct a formal measure of user quality.

**Observation window:** 16 August - 15 September 2026 (31 UTC calendar days)
**Scope:** Base, Uniswap v2/v3/v4, Dune Spellbook `dex.trades`
**Wallet unit:** `tx_from` (transaction signer)
**Transaction unit:** distinct `tx_hash`
**V1 snapshot date:** 16 September 2026

## Snapshot and reproducibility

V1 snapshot date: 16 September 2026. Dune's underlying datasets are continuously refreshed, so future query
executions may produce different results. The figures and conclusions in this report refer specifically to the
V1 analytical snapshot captured on 16 September 2026.

The [live Dune dashboard](https://dune.com/13seeker/uniswap-on-base-user-quality-activity-v1) is an interactive
reference that re-executes against current data; this repository and the report preserve the historical V1
record. The dashboard URL slug still contains the project's earlier working title and is kept unchanged so
existing links continue to resolve.

## Final V1 results

| Metric | Result |
|---|---:|
| Unique wallets (signers) | 569,864 |
| Distinct transactions | 19,932,002 |
| Adjusted reported volume | $8,260,205,266 |
| Average daily active wallets | 58,579 |
| Median transactions / wallet | 2 |
| Median active days / wallet | 1 |
| Wallets active on 2+ days | 37.08% |

## Main observations

- 82.8% of wallets made 10 or fewer transactions, while 0.42% of wallets made more than 1,000 and generated
  59.46% of all transactions.
- The top 1% of wallets represented 68.94% of transactions and 71.54% of adjusted reported volume.
- Across all eligible wallets, 38.26% returned on a later calendar day; 37.07% returned within 7 days.
  Segment-level return behavior is descriptive because the segment is defined over the full window.
- Three Uniswap v4 transactions produced about $28.23B of nominal reported volume on Aug 18. Raw V4 events
  matched `dex.trades` exactly, but reported USDC swap amounts were not backed by comparable ERC-20
  settlement. The three transactions were excluded from volume metrics only.

## Observed return behavior

Return means activity on a **later UTC calendar day** than the wallet's first observed active date inside the
window, subject to the eligibility cutoff for each horizon. The later-day metric is not conventional "D2
retention" and does not mean return within 48 hours. Same-day repeat activity never counts as a return.

| Segment | Wallets | Returned on a later day | Within 7 days | Within 14 days | Within 30 days |
|---|---:|---:|---:|---:|---:|
| Casual (1-10 tx) | 471,807 | 27.13% | 22.92% | 30.00% | 51.66% |
| Regular (11-500 tx) | 93,896 | 89.93% | 92.70% | 96.35% | 99.27% |
| High-frequency (>500 tx) | 4,161 | 99.93% | 99.46% | 99.79% | 99.97% |
| All wallets | 569,864 | 38.26% | 37.07% | 45.14% | 82.02% |

Eligibility: later-day return uses wallets first seen on or before 14 Sep; the 7-day horizon on or before
8 Sep; the 14-day horizon on or before 1 Sep. The 30-day horizon uses **only the 16 August cohort**
(37,975 eligible wallets) and must not be read as an ordinary all-wallet 30-day retention rate.

The SQL column names retain a `d7` / `d14` / `d30` shorthand so the published queries and dashboard panels
continue to resolve; the horizons they measure are the ones described above.

## Data-quality treatment

The anomaly investigation found a 1:1 match between raw V4 `PoolManager` Swap events and `dex.trades`,
zero-liquidity pools behind the largest nominal rows, and about 28.15B reported USDC swap amounts versus only
0.000247 USDC transferred into PoolManager and none leaving it. Aug 18 adjusted volume is $101,023,498.

See [`diagnostics/AUG18_ANOMALY.md`](diagnostics/AUG18_ANOMALY.md) and the full report.

## V1 limitations

- `tx_from` is the transaction signer, not necessarily a human user.
- A signer can represent a person, bot, smart contract, relayer, router, solver, or infrastructure.
- First active date is the first observed date inside the 31-day window, not lifetime first activity.
- Full-window transaction-count segments introduce temporal leakage, so segment-level return behavior is
  descriptive, not predictive.
- No bot or automation classification was performed.
- Summed `dex.trades` `amount_usd` is reported USD activity, not necessarily economically settled notional.
- Multi-hop swaps can contribute multiple trade rows to summed volume.
- Rows without USD pricing do not contribute to the reported volume.
- The three Aug 18 transactions were excluded from volume only, after transaction-level investigation.
- The 30-day horizon is only the 16 August cohort and should not be interpreted as ordinary all-wallet
  30-day retention.
- No cross-period, cross-chain, or competing-DEX benchmark is included.
- The analysis does not establish "user quality."

## Repository contents

```text
report/
  Uniswap_on_Base_Activity_Concentration_Return_Behavior_V1_3_Report.docx   (editable source)
  Uniswap_on_Base_Activity_Concentration_Return_Behavior_V1_3_Report.pdf    (rendered report)

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

[PDF report - V1.3](report/Uniswap_on_Base_Activity_Concentration_Return_Behavior_V1_3_Report.pdf)
[Editable DOCX source - V1.3](report/Uniswap_on_Base_Activity_Concentration_Return_Behavior_V1_3_Report.docx)

> **Note.** Both carry the V1.3 title, terminology, snapshot statement and limitations. One cosmetic
> difference remains: the PDF was exported before the running page header was corrected, so its page header
> still reads "USER QUALITY & ACTIVITY". The body text, all figures and the DOCX source are correct; a
> re-export from the current DOCX will clear it.

The Dune queries linked from [`queries/README.md`](queries/README.md) are the canonical production source; the
SQL files under `queries/` are readable versions maintained alongside them.

## Project status

**V1 complete and frozen.** No further analysis is planned under V1.
