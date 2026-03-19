import dotenv from "dotenv";

dotenv.config();

const numberEnv = (value: string | undefined, fallback: number) => {
  if (!value) return fallback;
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : fallback;
};

const boolEnv = (value: string | undefined, fallback: boolean) => {
  if (!value) return fallback;
  return value.toLowerCase() === "true";
};

const rawAddress = process.env.FLOWSHIELD_ADDRESS ?? "d23d4404df96f641";
const contractAddress = rawAddress.replace(/^0x/, "");
const contractAddressHex = `0x${contractAddress}`;

export const config = {
  port: numberEnv(process.env.PORT, 8787),
  flowNetwork: process.env.FLOW_NETWORK ?? "testnet",
  accessNode:
    process.env.FLOW_ACCESS_NODE ?? "https://rest-testnet.onflow.org",
  contractAddress,
  contractAddressHex,
  tokenId:
    process.env.FLOWSHIELD_TOKEN_ID ??
    "A.7e60df042a9c0868.FlowToken.Vault",
  indexerPollIntervalMs: numberEnv(
    process.env.INDEXER_POLL_INTERVAL_MS,
    6000
  ),
  indexerBatchSize: numberEnv(process.env.INDEXER_BATCH_SIZE, 250),
  quotePrice: numberEnv(process.env.QUOTE_PRICE, 1.0),
  liquidityDepth: numberEnv(process.env.LIQUIDITY_DEPTH, 100_000),
  volatilityBps: numberEnv(process.env.RISK_VOLATILITY_BPS, 40),
  dripEnabled: boolEnv(process.env.DRIP_ENABLED, false),
  dripIntervalMs: numberEnv(process.env.DRIP_INTERVAL_MS, 3600_000),
  dripBps: numberEnv(process.env.DRIP_BPS, 1000),
  dripMinAmount: numberEnv(process.env.DRIP_MIN_AMOUNT, 1.0),
};
