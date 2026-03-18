# FlowShield — Repo Implementation Plan

This file is the master map of what gets built where. Each folder also has its own `FLOW_SHIELD_PLAN.md` with file‑level notes.

## Folder Map

- `onchain/` — SlipShield core contracts and ActionRouter (Flow Actions).
- `onchain-scheduled/` — DrawdownShield scheduler prototype (deferred in current build).
- `frontend/` — Flow React SDK starter (Next.js + TypeScript) with FlowShield UI.
- `services/` — Off‑chain indexer + risk scoring + API.
- `docs/` — Architecture, deployment, and runbooks.

## Environment Files

- `.env.example` — shared placeholders for testnet config.
- `frontend/.env.local.example` — frontend‑specific envs.
- `services/.env.example` — service‑specific envs.

## Build Order (suggested)

1. `onchain/` — ProtectionVault, GuardPolicy, ActionRouter, and protected swap transaction.
2. `frontend/` — wallet connect, policy setup UI, protected swap UI.
3. `services/` — indexer + risk scoring + analytics endpoints.
4. `docs/` — finalize architecture + deployment guide for testnet.
