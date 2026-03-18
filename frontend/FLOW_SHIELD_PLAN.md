# Frontend (Flow React SDK Starter)

## Purpose
User UI for configuring SlipShield and executing protected swaps.

## Files to Implement

### Flow SDK Wiring (`src/flow/`)
- `config.ts` — FCL config for testnet endpoints.
- `scripts.ts` — read‑only scripts: get policy, get vault stats.
- `transactions.ts` — protected swap and set policy.
- `types.ts` — shared TS types for policies and UI.
- `cadence/` — Cadence scripts/transactions embedded as string literals.

### UI (`src/components/flowshield/`)
- `SlipShieldCard.tsx` — UI to set slippage protection.
- `ProtectionStatus.tsx` — status display (coverage, refunds, active jobs).

### Pages (`src/app/`)
- `flowshield/page.tsx` — main FlowShield screen.
