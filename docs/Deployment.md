# Deployment (Testnet)

## 1) Deploy Contracts

From `onchain/`:

```bash
cd /Users/yagnesh/Desktop/FlowShieldRepo/onchain
flow project deploy --network testnet
```

Contracts deployed to: `0xd23d4404df96f641`

## 2) Start Services

```bash
cd /Users/yagnesh/Desktop/FlowShieldRepo/services
npm install
cp .env.example .env
npm run dev
```

Service default: `http://localhost:8787`

## 3) Start Frontend

```bash
cd /Users/yagnesh/Desktop/FlowShieldRepo/frontend
npm install
cp .env.local.example .env.local
npm run dev
```

Open: `http://localhost:3000`

## 4) Verify

1. Connect wallet (Flow testnet).
2. Save a policy in SlipShield.
3. Fetch a quote and execute a protected swap.
4. Check vault stats + refund events in the UI.
