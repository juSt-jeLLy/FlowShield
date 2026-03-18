import { config } from "./config";

export type RiskResult = {
  score: number;
  label: "low" | "medium" | "high";
  depthPenalty: number;
  slippagePenalty: number;
  volatilityPenalty: number;
};

export function computeRiskScore(amountIn: number, slippageBps: number): RiskResult {
  const depthPenalty = Math.min(
    60,
    (amountIn / config.liquidityDepth) * 60
  );
  const slippagePenalty = Math.min(25, (slippageBps / 100) * 2.5);
  const volatilityPenalty = Math.min(20, (config.volatilityBps / 100));

  const rawScore = 100 - (depthPenalty + slippagePenalty + volatilityPenalty);
  const score = Math.max(1, Math.min(100, Math.round(rawScore)));

  let label: "low" | "medium" | "high" = "low";
  if (score < 45) label = "high";
  else if (score < 70) label = "medium";

  return { score, label, depthPenalty, slippagePenalty, volatilityPenalty };
}
