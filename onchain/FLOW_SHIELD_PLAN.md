# On‑Chain (SlipShield + ActionRouter)

## Purpose
Implements slippage protection, refund vault logic, and ActionRouter‑based swaps.

## Files to Implement

### Contracts (`cadence/contracts/`)
- `FlowShieldTypes.cdc` — shared structs, events, and constants.
- `FlowShieldErrors.cdc` — shared error types.
- `ProtectionVault.cdc` — pooled slippage‑refund vault with entitlement‑gated withdrawals.
- `GuardPolicy.cdc` — per‑user slippage policy and parameters.
- `ActionRouter.cdc` — standardized swap execution using Flow Actions.
- `FlowShieldAdmin.cdc` — admin roles, emergency pause, risk caps.

### Transactions (`cadence/transactions/`)
- `setup_vault.cdc` — initializes ProtectionVault resources.
- `setup_user.cdc` — creates user policy storage + capabilities.
- `fund_vault.cdc` — deposits assets into the refund pool.
- `withdraw_vault.cdc` — admin or underwriter withdrawal (per rules).
- `profit_drip.cdc` — scheduled premium sweep to treasury receiver.
- `set_policy.cdc` — creates or updates GuardPolicy for a user.
- `protected_swap.cdc` — runs swap + checks slippage + triggers refund if needed.

### Scripts (`cadence/scripts/`)
- `get_policy.cdc` — read a user’s policy.
- `get_vault_stats.cdc` — read vault reserves + payout totals.
- `get_protection_limits.cdc` — read caps and coverage limits.

### Tests (`cadence/tests/`)
- `slippage_refund_test.cdc` — validates refund math.
- `policy_entitlements_test.cdc` — validates access control and entitlement gating.
- `vault_funding_test.cdc` — validates pool deposits and withdrawals.
