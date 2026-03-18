# On‑Chain Scheduled (DrawdownShield)

## Purpose
Implements Scheduled Transactions for automated drawdown checks and re‑entry ladders.

> Deferred in the current SlipShield‑only build.

## Files to Implement

### Contracts (`cadence/contracts/`)
- `DrawdownPolicy.cdc` — per‑user drawdown thresholds + re‑entry tiers.
- `PriceOracle.cdc` — Band Oracle adapter (FLOW/USDC default).
- `DrawdownScheduler.cdc` — handler invoked by FlowTransactionScheduler.

### Transactions (`cadence/transactions/`)
- `set_drawdown_policy.cdc` — create/update policy.
- `fund_oracle_fee_vault.cdc` — deposit FLOW to pay Band oracle fees.
- `register_drawdown_job.cdc` — register scheduled job for a user.
- `cancel_drawdown_job.cdc` — cancel scheduled job.
- `execute_drawdown_check.cdc` — transaction invoked by scheduler.

### Scripts (`cadence/scripts/`)
- `get_drawdown_policy.cdc` — read policy.
- `get_drawdown_status.cdc` — read status and last trigger time.
- `get_scheduled_jobs.cdc` — list scheduled jobs for a user.
- `get_oracle_fee_balance.cdc` — read available oracle fee balance.

### Tests (`cadence/tests/`)
- `drawdown_trigger_test.cdc` — trigger drawdown exit.
- `reentry_ladder_test.cdc` — validate re‑entry tiers.
