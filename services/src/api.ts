import express, { Request, Response } from "express";
import cors from "cors";
import { Storage } from "./storage";
import { Metrics } from "./metrics";
import { computeRiskScore } from "./risk";
import { config } from "./config";

export function createApi(storage: Storage, metrics: Metrics) {
  const app = express();

  app.use(cors());
  app.use(express.json());

  app.get("/health", (_req: Request, res: Response) => {
    res.json({ ok: true });
  });

  app.get("/metrics", (_req: Request, res: Response) => {
    res.json(metrics.snapshot(storage.getLastHeight()));
  });

  app.get("/vault/:tokenId", (req: Request, res: Response) => {
    const tokenId = req.params.tokenId;
    const stats = storage.getVaultStats(tokenId);
    if (!stats) {
      res.status(404).json({ error: "Vault stats not available yet" });
      return;
    }
    res.json(stats);
  });

  app.get("/events", (req: Request, res: Response) => {
    const limit = Number(req.query.limit ?? 25);
    const events = storage.getRecentEvents();
    res.json({
      swaps: events.swaps.slice(0, limit),
      refunds: events.refunds.slice(0, limit),
      premiums: events.premiums.slice(0, limit),
      deposits: events.deposits.slice(0, limit),
      treasury: events.treasury.slice(0, limit),
    });
  });

  app.post("/quote", (req: Request, res: Response) => {
    const amountIn = Number(req.body.amountIn ?? 0);
    const slippageBps = Number(req.body.slippageBps ?? 0);
    const premiumBps = Number(req.body.premiumBps ?? 0);
    const maxRefundPerSwap = Number(req.body.maxRefundPerSwap ?? 0);

    if (!Number.isFinite(amountIn) || amountIn <= 0) {
      res.status(400).json({ error: "amountIn must be > 0" });
      return;
    }

    const expectedOut = amountIn * config.quotePrice;
    const minOut =
      expectedOut * (1 - Math.max(0, Math.min(slippageBps, 10_000)) / 10_000);
    const premium =
      expectedOut * (Math.max(0, Math.min(premiumBps, 10_000)) / 10_000);

    const risk = computeRiskScore(amountIn, slippageBps);

    res.json({
      expectedOut: expectedOut.toFixed(8),
      minOut: minOut.toFixed(8),
      premium: premium.toFixed(8),
      refundCap: Math.max(0, maxRefundPerSwap).toFixed(8),
      riskScore: risk.score,
      riskLabel: risk.label,
      route: "IncrementFi",
    });
  });

  app.get("/drip-plan", (_req: Request, res: Response) => {
    const stats = storage.getVaultStats(config.tokenId);
    if (!stats) {
      res.status(404).json({ error: "Vault stats not available yet" });
      return;
    }
    const totalPremiums = Number(stats.totalPremiums ?? 0);
    const balance = Number(stats.balance ?? 0);
    const target = (totalPremiums * config.dripBps) / 10_000;
    const amount = Math.max(
      0,
      Math.min(balance, target)
    );

    res.json({
      enabled: config.dripEnabled,
      dripBps: config.dripBps,
      minAmount: config.dripMinAmount,
      recommendedAmount: amount.toFixed(8),
      tokenId: config.tokenId,
    });
  });

  return app;
}
