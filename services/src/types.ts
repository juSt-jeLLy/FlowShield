export type VaultStats = {
  totalDeposits: string;
  totalPremiums: string;
  totalRefunds: string;
  balance: string;
};

export type SlipShieldProtectedSwapEvent = {
  tokenId: string;
  expectedOut: string;
  actualOut: string;
  minOut: string;
  premium: string;
  refundRequested: string;
  refundPaid: string;
  blockHeight: number;
  txId: string;
  timestamp: string;
};

export type SlipShieldPremiumPaidEvent = {
  tokenId: string;
  amount: string;
  blockHeight: number;
  txId: string;
  timestamp: string;
};

export type SlipShieldRefundPaidEvent = {
  tokenId: string;
  amount: string;
  blockHeight: number;
  txId: string;
  timestamp: string;
};

export type VaultDepositEvent = {
  tokenId: string;
  amount: string;
  kind: string;
  blockHeight: number;
  txId: string;
  timestamp: string;
};

export type TreasuryWithdrawnEvent = {
  tokenId: string;
  amount: string;
  blockHeight: number;
  txId: string;
  timestamp: string;
};

export type QuoteRequest = {
  amountIn: number;
  slippageBps: number;
  premiumBps: number;
};

export type QuoteResponse = {
  expectedOut: string;
  minOut: string;
  premium: string;
  refundCap: string;
  riskScore: number;
  riskLabel: "low" | "medium" | "high";
  route: string;
};

export type MetricsSnapshot = {
  startedAt: string;
  uptimeSeconds: number;
  lastIndexedHeight: number;
  eventCounts: Record<string, number>;
};
