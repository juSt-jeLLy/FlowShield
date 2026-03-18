# FlowShield — Flow Docs Implementation Map

This document maps every major build step to the Flow documentation that explains how to implement it. It’s intentionally technical and execution-focused.

---

## 1) What We’re Building (FlowShield)

FlowShield is a consumer‑DeFi protection layer focused on SlipShield.
DrawdownShield is intentionally deferred in this build.

SlipShield
- Adds slippage‑refund protection to swaps.
- Executes swaps via Flow Actions and only allows refunds through entitlement‑gated vault logic.

---

## 2) Flow Primitives We Use (and Where)

| Flow Primitive | Where It’s Used | Why It Matters | Docs |
| --- | --- | --- | --- |
| Flow Actions | SlipShield swap execution and protocol‑agnostic routing | Standardized, composable DeFi workflows | https://developers.flow.com/blockchain-development-tutorials/forte/flow-actions |
| Flow Actions: Intro | Defines Sources, Sinks, Swappers, Oracles, Flashers | Core building blocks for FlowShield swap logic | https://developers.flow.com/blockchain-development-tutorials/forte/flow-actions/intro-to-flow-actions |
| Flow Actions: Transaction | Shows how to assemble actions in a single atomic transaction | Used in ActionRouter transactions | https://developers.flow.com/blockchain-development-tutorials/forte/flow-actions/flow-actions-transaction |
| Flow Actions: Connectors | Adapter layer that binds Actions to real protocols | Needed for DEX adapters | https://developers.flow.com/blockchain-development-tutorials/forte/flow-actions/connectors |
| Flow Actions: Basic Combinations | Patterns for chaining Actions | Used for swap + refund workflows | https://developers.flow.com/blockchain-development-tutorials/forte/flow-actions/basic-combinations |
| Scheduled Transactions (tutorials) | Drawdown checks + re‑entry scheduling | Deferred | https://developers.flow.com/blockchain-development-tutorials/forte/scheduled-transactions |
| Scheduled Transactions (CLI) | Dev tooling + manager resource setup | Deferred | https://developers.flow.com/build/tools/flow-cli/scheduled-transactions |
| Cadence Access Control + Entitlements | ProtectionVault + GuardPolicy permissions | Fine‑grained control over sensitive calls | https://cadence-lang.org/docs/language/access-control |
| Cadence Capabilities | Safe account access + capability issuance | Used for entitlement‑scoped access | https://cadence-lang.org/docs/language/capabilities |
| Cadence References | Authorized references via entitlements | Used for escrow/refund vault gating | https://cadence-lang.org/docs/language/references |
| Gasless Transactions | User pays no gas | Consumer UX baseline | https://developers.flow.com/blockchain-development-tutorials/gasless-transactions |
| Native VRF | Randomized execution windows (optional) | Reduce predictability for execution | https://developers.flow.com/blockchain-development-tutorials/native-vrf |
| Access API (HTTP) | Offchain indexing, monitoring, analytics | Needed for pricing, risk scoring, dashboard | https://developers.flow.com/http-api |
| React SDK | Frontend wallet + tx UX | Rapid UI build for Flow apps | https://developers.flow.com/build/tools/react-sdk |
| Flow CLI | Local dev, deploy, scripting | Core dev workflow | https://developers.flow.com/build/tools/flow-cli |
| Flow Emulator | Local chain for tests | Local iteration for contracts + actions | https://developers.flow.com/build/tools/emulator |
| Third‑Party Integrations | Walletless onboarding + payments | Email/social login + gasless options | https://developers.flow.com/blockchain-development-tutorials/integrations |

---

## 3) Step‑By‑Step Technical Build Plan (with resources)

### Step 0 — Tooling + Local Dev
Goal: fast iteration before testnet.

Resources
- Flow CLI: https://developers.flow.com/build/tools/flow-cli
- Flow Emulator: https://developers.flow.com/build/tools/emulator

Execution
- Initialize project with `flow init`.
- Run local emulator, deploy contracts, and run Actions transactions against it.

---

### Step 1 — Cadence Security Model
Goal: model vault access with least‑privilege permissions.

Resources
- Access Control + Entitlements: https://cadence-lang.org/docs/language/access-control
- Capabilities: https://cadence-lang.org/docs/language/capabilities
- References: https://cadence-lang.org/docs/language/references

Execution
- Define entitlement sets for refund withdrawal and policy modification.
- Issue and revoke capabilities to contracts and user‑auth logic only.

---

### Step 2 — Core Contracts
Goal: deploy the on‑chain modules with entitlement‑gated access.

Contracts
- ProtectionVault.cdc
  - Holds slippage‑refund pool.
  - Only `auth(Refund)` can withdraw.
- GuardPolicy.cdc
  - Stores per‑user thresholds and recovery tiers.
  - Only `auth(PolicyAdmin)` can change.
- ActionRouter.cdc
  - Executes Actions‑based swap workflow.
- Scheduler.cdc
  - Registers scheduled jobs and executes Drawdown checks.

Resources
- Access Control + Entitlements: https://cadence-lang.org/docs/language/access-control
- Capabilities: https://cadence-lang.org/docs/language/capabilities

Execution
- Deploy contracts to emulator/testnet.
- Add scripts for read‑only dashboards (policy + vault stats).

---

### Step 3 — Flow Actions Integration (SlipShield)
Goal: wrap swaps via Actions and enforce slippage refund logic.

Resources
- Flow Actions Overview: https://developers.flow.com/blockchain-development-tutorials/forte/flow-actions
- Intro to Actions (Sources/Sinks/Swappers): https://developers.flow.com/blockchain-development-tutorials/forte/flow-actions/intro-to-flow-actions
- Actions Transaction: https://developers.flow.com/blockchain-development-tutorials/forte/flow-actions/flow-actions-transaction
- Connectors (DEX adapters): https://developers.flow.com/blockchain-development-tutorials/forte/flow-actions/connectors
- Basic Combinations: https://developers.flow.com/blockchain-development-tutorials/forte/flow-actions/basic-combinations

Execution
- Build ActionRouter transaction that composes:
  - Source → Swapper → Sink
  - Post‑swap check: compare output vs user slippage limit
  - If below threshold: trigger refund from ProtectionVault
- Write DEX connector(s) for the target protocol(s).

---

### Step 4 — Scheduled Transactions (DrawdownShield, deferred)
Goal: autonomous stop‑loss checks + re‑entry ladder.

Resources
- Scheduled Transactions tutorials: https://developers.flow.com/blockchain-development-tutorials/forte/scheduled-transactions
- CLI Scheduled Transactions: https://developers.flow.com/build/tools/flow-cli/scheduled-transactions

Execution
- Register a Scheduled Transaction per user policy.
- Use a Manager resource to track and manage scheduled jobs.
- Implement Drawdown check handlers that exit positions and schedule re‑entry tiers.

---

### Step 5 — Gasless UX
Goal: users never touch gas fees.

Resources
- Gasless Transactions: https://developers.flow.com/blockchain-development-tutorials/gasless-transactions

Execution
- Use Flow Wallet sponsorship by default.
- For EVM flows or backend‑sponsored calls, use the gasless EVM endpoint approach.

---

### Step 6 — Randomized Execution Windows (Optional)
Goal: avoid predictable execution for adversaries.

Resources
- Native VRF: https://developers.flow.com/blockchain-development-tutorials/native-vrf

Execution
- Use Flow’s built‑in randomness to pick execution offsets inside a time window.

---

### Step 7 — Frontend (React SDK)
Goal: ship a clean consumer UI quickly.

Resources
- React SDK: https://developers.flow.com/build/tools/react-sdk

Execution
- Wrap app in `FlowProvider`.
- Use hooks for account/session and transaction execution.
- Use components like `Connect` for wallet onboarding.

---

### Step 8 — Off‑Chain Services (Risk + Monitoring)
Goal: price feeds, risk scoring, analytics dashboard.

Resources
- Access API (HTTP): https://developers.flow.com/http-api

Execution
- Use Access API to fetch:
  - transaction results
  - events for refunds, swaps, and policy updates
  - scheduled transaction results
- Feed into risk scoring + user analytics.

---

### Step 9 — Walletless Onboarding + Payments
Goal: email/social login and Web2‑style UX.

Resources
- Third‑Party Integrations: https://developers.flow.com/blockchain-development-tutorials/integrations

Execution
- Integrate providers like Crossmint for auth + payments.
- Use Gelato Smart Wallet (if EVM flows are required).

---

## 4) How Each Module Executes (Runtime Summary)

SlipShield
- User sets max slippage.
- ActionRouter composes the swap via Actions.
- If output < min‑acceptable, ProtectionVault refunds the delta.

DrawdownShield (Deferred)
- Scheduled Transaction checks price thresholds.
- If drawdown breached, execute exit transaction.
- Schedule re‑entry ladder based on recovery thresholds.

---

## 5) Minimum Viable Build (Order of Work)

1. CLI + Emulator setup
2. Cadence access control + entitlements
3. ProtectionVault + GuardPolicy contracts
4. Flow Actions swap transaction + connector for 1 DEX
5. Frontend UI with React SDK
6. Gasless UX + analytics layer

---

## 6) Notes on Stability

Flow Actions are being reviewed under a FLIP and may change. Keep connectors modular so you can swap implementations without rewriting the whole router.

---

## 7) What We Can Add Later (Still Flow‑Native)

- LP‑guard mode using Flow Actions combos.
- Auto‑rebalance vaults using Scheduled Transactions.
- Protection score engine based on onchain metrics from Access API.
