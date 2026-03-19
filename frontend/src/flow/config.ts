export const flowConfig = {
  accessNodeUrl:
    process.env.NEXT_PUBLIC_FLOW_ACCESS_NODE ??
    "https://rest-testnet.onflow.org",
  discoveryWallet:
    process.env.NEXT_PUBLIC_FLOW_DISCOVERY_WALLET ??
    "https://fcl-discovery.onflow.org/testnet/authn",
  discoveryAuthnEndpoint:
    "https://fcl-discovery.onflow.org/api/testnet/authn",
  flowNetwork: process.env.NEXT_PUBLIC_FLOW_NETWORK ?? "testnet",
  appDetailTitle: "FlowShield",
  appDetailDescription: "SlipShield protected swaps on Flow",
  appDetailIcon: "https://flow.com/favicon.ico",
};

export const flowShieldAddress =
  process.env.NEXT_PUBLIC_FLOWSHIELD_ADDRESS ?? "0xd23d4404df96f641";

export const flowShieldServiceUrl =
  process.env.NEXT_PUBLIC_FLOWSHIELD_SERVICE_URL ??
  "http://localhost:8787";

export const fungibleTokenAddress = "0x9a0766d93b6608b7";
export const stFlowTokenAddress = "0xe45c64ecfe31e465";
