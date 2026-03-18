// types.ts
// Shared TS types for building FlowShield transactions.

export type UFix64String = string;

export type PolicyConfigInput = {
  enabled: boolean;
  maxSlippageBps: number;
  maxRefundPerSwap: UFix64String;
  maxRefundPerEpoch: UFix64String;
  epochSeconds: UFix64String;
  premiumBps: number;
};

export type ProtectedSwapInput = {
  amountIn: UFix64String;
  expectedOut: UFix64String;
  minOut: UFix64String;
  inVaultType: string;
  outVaultType: string;
  inVaultPath: string;
  outReceiverPath: string;
};

export type FundVaultInput = {
  amount: UFix64String;
  fromVaultPath: string;
};

export type ProfitDripInput = {
  tokenId: string;
  amount: UFix64String;
  receiverPath: string;
};

export type PolicySnapshot = {
  config: PolicyConfigInput;
  usage: {
    epochStart: UFix64String;
    usedThisEpoch: UFix64String;
  };
};

export type VaultStats = {
  totalDeposits: UFix64String;
  totalPremiums: UFix64String;
  totalRefunds: UFix64String;
  balance: UFix64String;
};

export type ProtectionLimits = {
  isPaused: boolean;
  maxRefundBps: number;
  maxPremiumBps: number;
};

export type QuoteResponse = {
  expectedOut: UFix64String;
  minOut: UFix64String;
  premium: UFix64String;
  refundCap: UFix64String;
  riskScore: number;
  riskLabel: "low" | "medium" | "high";
  route: string;
};
