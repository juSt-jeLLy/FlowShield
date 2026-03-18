# Runbook

## Operational Checklist

1. Confirm contracts deployed on testnet.
2. Ensure the service is running and indexing events.
3. Validate the frontend is connected to testnet.
4. Run a protected swap and verify refund events.

## Health Checks

- Service: `GET /health`
- Metrics: `GET /metrics`
- Vault stats: `GET /vault/:tokenId`

## Common Issues

**Invalid receiver capability**
- Output vault not initialized.
- Ensure the wallet has the correct vault + public receiver path.

**No policy found**
- Save a SlipShield policy first.

**Swap fails with low output**
- Increase slippage bps or check DEX liquidity.

**Indexer not updating**
- Confirm `FLOW_ACCESS_NODE` is reachable.
- Check `INDEXER_POLL_INTERVAL_MS` and logs.

## Recovery Steps

1. Restart services and frontend.
2. Re‑deploy contracts if Flow CLI reports stale code.
3. Clear browser storage and re‑connect wallet.
