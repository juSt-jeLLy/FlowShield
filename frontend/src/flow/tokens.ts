export type TokenMeta = {
  symbol: string;
  name: string;
  typeId: string;
  storagePath: string;
  receiverPath: string;
};

export const TOKENS: TokenMeta[] = [
  {
    symbol: "FLOW",
    name: "Flow Token",
    typeId: "A.7e60df042a9c0868.FlowToken.Vault",
    storagePath: "/storage/flowTokenVault",
    receiverPath: "/public/flowTokenReceiver",
  },
  {
    symbol: "stFLOW",
    name: "Staked Flow",
    typeId: "A.e45c64ecfe31e465.stFlowToken.Vault",
    storagePath: "/storage/stFlowTokenVault",
    receiverPath: "/public/stFlowTokenReceiver",
  },
];

export const DEFAULT_TOKEN_IN = TOKENS[0];
export const DEFAULT_TOKEN_OUT = TOKENS[1];
