# Services (Off‑Chain)

## Purpose
Indexer, risk scoring, and analytics for FlowShield.

## Files to Implement

- `src/config.ts` — service config (Access API endpoints, polling intervals).
- `src/types.ts` — shared types for events and policies.
- `src/storage.ts` — persistence layer (SQLite/Postgres or in‑memory).
- `src/indexer.ts` — event ingestion for refunds, swaps, policy updates.
- `src/risk.ts` — protection score computation and risk caps.
- `src/metrics.ts` — basic metrics and health counters.
- `src/api.ts` — REST API for frontend consumption.
