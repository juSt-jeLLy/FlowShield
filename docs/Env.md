# Environment Variables

## Frontend (`frontend/.env.local`)

- `NEXT_PUBLIC_FLOW_NETWORK` — `testnet`
- `NEXT_PUBLIC_FLOW_ACCESS_NODE` — `https://rest-testnet.onflow.org`
- `NEXT_PUBLIC_FLOW_DISCOVERY_WALLET` — Flow wallet discovery URL
- `NEXT_PUBLIC_FLOWSHIELD_ADDRESS` — contract account address
- `NEXT_PUBLIC_FLOWSHIELD_SERVICE_URL` — service base URL

## Services (`services/.env`)

- `PORT` — service port
- `FLOW_NETWORK` — `testnet`
- `FLOW_ACCESS_NODE` — access node host
- `FLOWSHIELD_ADDRESS` — contract account
- `FLOWSHIELD_TOKEN_ID` — token type ID
- `INDEXER_POLL_INTERVAL_MS` — polling interval
- `INDEXER_BATCH_SIZE` — block range per poll

Quote + risk:
- `QUOTE_PRICE` — simple price scalar
- `LIQUIDITY_DEPTH` — depth for risk scoring
- `RISK_VOLATILITY_BPS` — volatility penalty

Profit drip:
- `DRIP_ENABLED`
- `DRIP_INTERVAL_MS`
- `DRIP_BPS`
- `DRIP_MIN_AMOUNT`
