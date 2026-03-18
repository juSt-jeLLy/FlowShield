# FlowShieldRepo

This repo is intentionally not a monorepo. It’s a single Git repo with clearly separated folders per component.

## Structure

- `onchain/`
  - Flow CLI scaffold: **DeFi Actions project** (composable DeFi connectors)
- `onchain-scheduled/`
  - Flow CLI scaffold: **Scheduled Transactions project**
- `frontend/`
  - Flow React SDK starter template (Next.js + TypeScript, testnet‑ready)
- `archive/`
  - Older client templates moved out of the main tree
- `services/`
  - Off‑chain services placeholder
- `docs/`
  - Technical docs and FlowShield build plan

## Quickstart (Local)

1. On‑chain (DeFi Actions)
   - `cd onchain`
   - `flow emulator`
   - `flow test`

2. On‑chain (Scheduled Transactions)
   - `cd onchain-scheduled`
   - `flow emulator`
   - `flow test`

3. Frontend
   - `cd frontend`
   - Follow the Flow React SDK starter README


## Notes

- The on‑chain folders were generated via `flow init` using the CLI scaffolds.
- For full Flow‑docs‑based build steps, see `docs/FlowShield-FlowDocs-Implementation.md`.
- The repo is configured for testnet usage by default in the frontend templates.
