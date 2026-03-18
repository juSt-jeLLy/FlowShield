"use client";

import { useEffect, useState } from "react";
import { useFlowCurrentUser, useFlowMutate, useFlowQuery } from "@onflow/react-sdk";
import {
  FUND_VAULT_CADENCE,
  PROFIT_DRIP_CADENCE,
  buildFundVaultArgs,
  buildProfitDripArgs,
} from "@/flow/transactions";
import {
  GET_POLICY_CADENCE,
  GET_VAULT_STATS_CADENCE,
  GET_PROTECTION_LIMITS_CADENCE,
} from "@/flow/scripts";
import { flowShieldServiceUrl } from "@/flow/config";
import { DEFAULT_TOKEN_IN } from "@/flow/tokens";
import { normalizeFlowError } from "@/flow/errors";
import type { PolicySnapshot, VaultStats } from "@/flow/types";

type EventsResponse = {
  refunds: Array<{ amount: string; txId: string; timestamp: string }>;
  premiums: Array<{ amount: string; txId: string; timestamp: string }>;
  swaps: Array<{ refundPaid: string; txId: string; timestamp: string }>;
};

type DripPlan = {
  enabled: boolean;
  dripBps: number;
  minAmount: number;
  recommendedAmount: string;
  tokenId: string;
};

const formatAmount = (value?: string) =>
  value ? Number(value).toFixed(4) : "--";

export function ProtectionStatus() {
  const { user } = useFlowCurrentUser();
  const [events, setEvents] = useState<EventsResponse | null>(null);
  const [dripPlan, setDripPlan] = useState<DripPlan | null>(null);

  const {
    data: policyData,
    refetch: refetchPolicy,
  } = useFlowQuery({
    cadence: GET_POLICY_CADENCE,
    args: (arg, t) => [arg(user?.addr ?? "", t.Address)],
    query: { enabled: Boolean(user?.addr) },
  });

  const { data: limitsData } = useFlowQuery({
    cadence: GET_PROTECTION_LIMITS_CADENCE,
    args: (arg, t) => [],
  });

  const { data: vaultData, refetch: refetchVault } = useFlowQuery({
    cadence: GET_VAULT_STATS_CADENCE,
    args: (arg, t) => [arg(DEFAULT_TOKEN_IN.typeId, t.String)],
  });

  const {
    mutate: fundVault,
    isPending: fundingVault,
    error: fundError,
  } = useFlowMutate();
  const {
    mutate: profitDrip,
    isPending: dripping,
    error: dripError,
  } = useFlowMutate();

  const [fundAmount, setFundAmount] = useState("10.0");
  const [fundPath, setFundPath] = useState(DEFAULT_TOKEN_IN.storagePath);
  const [dripAmount, setDripAmount] = useState("1.0");
  const [dripReceiverPath, setDripReceiverPath] = useState(
    DEFAULT_TOKEN_IN.receiverPath
  );

  useEffect(() => {
    const load = async () => {
      try {
        const response = await fetch(`${flowShieldServiceUrl}/events?limit=5`);
        if (response.ok) {
          setEvents(await response.json());
        }
        const drip = await fetch(`${flowShieldServiceUrl}/drip-plan`);
        if (drip.ok) {
          setDripPlan(await drip.json());
        }
      } catch {
        // ignore network errors
      }
    };

    load();
    const interval = setInterval(() => {
      refetchPolicy();
      refetchVault();
      load();
    }, 15000);
    return () => clearInterval(interval);
  }, [refetchPolicy, refetchVault]);

  const policy = policyData as PolicySnapshot | null;
  const vaultStats = vaultData as VaultStats | null;
  const limits = limitsData as { isPaused: boolean } | null;

  const handleFundVault = () => {
    fundVault({
      cadence: FUND_VAULT_CADENCE,
      args: (arg, t) => [
        arg(fundAmount, t.UFix64),
        arg(fundPath, t.Path),
      ],
    });
  };

  const handleProfitDrip = () => {
    profitDrip({
      cadence: PROFIT_DRIP_CADENCE,
      args: (arg, t) => [
        arg(DEFAULT_TOKEN_IN.typeId, t.String),
        arg(dripAmount, t.UFix64),
        arg(dripReceiverPath, t.Path),
      ],
    });
  };

  return (
    <section className="rounded-3xl border border-black/10 bg-white/70 p-6 sm:p-8">
      <div className="flex flex-col gap-2">
        <span className="text-xs uppercase tracking-[0.3em] text-black/50">
          Protection Status
        </span>
        <h3 className="text-2xl font-semibold text-black">
          Vault, policy, and recent activity
        </h3>
        <p className="text-sm text-black/60">
          Track coverage usage, pool liquidity, and refund events in real time.
        </p>
      </div>

      <div className="mt-6 grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="rounded-2xl border border-black/10 bg-white p-4 space-y-2">
          <h4 className="text-sm font-semibold text-black/70">Policy</h4>
          <div className="text-sm text-black/60">
            {policy ? (
              <>
                <div>Enabled: {policy.config.enabled ? "Yes" : "No"}</div>
                <div>Max slippage: {policy.config.maxSlippageBps} bps</div>
                <div>Premium: {policy.config.premiumBps} bps</div>
                <div>
                  Used this epoch: {formatAmount(policy.usage.usedThisEpoch)}
                </div>
              </>
            ) : (
              <div>No policy saved yet.</div>
            )}
          </div>
          {limits && (
            <div className="text-xs text-black/40">
              Global pause: {limits.isPaused ? "On" : "Off"}
            </div>
          )}
        </div>

        <div className="rounded-2xl border border-black/10 bg-white p-4 space-y-2">
          <h4 className="text-sm font-semibold text-black/70">Vault</h4>
          <div className="text-sm text-black/60">
            {vaultStats ? (
              <>
                <div>Balance: {formatAmount(vaultStats.balance)}</div>
                <div>Total deposits: {formatAmount(vaultStats.totalDeposits)}</div>
                <div>Total premiums: {formatAmount(vaultStats.totalPremiums)}</div>
                <div>Total refunds: {formatAmount(vaultStats.totalRefunds)}</div>
              </>
            ) : (
              <div>Loading vault stats…</div>
            )}
          </div>
          {dripPlan && (
            <div className="text-xs text-black/40">
              Recommended drip: {dripPlan.recommendedAmount} FLOW
            </div>
          )}
        </div>

        <div className="rounded-2xl border border-black/10 bg-white p-4 space-y-2">
          <h4 className="text-sm font-semibold text-black/70">Recent refunds</h4>
          <div className="space-y-2 text-sm text-black/60">
            {events?.refunds?.length ? (
              events.refunds.map((refund) => (
                <div key={refund.txId} className="flex justify-between">
                  <span>{formatAmount(refund.amount)} FLOW</span>
                  <span className="text-xs text-black/40">
                    {new Date(refund.timestamp).toLocaleTimeString()}
                  </span>
                </div>
              ))
            ) : (
              <div>No refunds yet.</div>
            )}
          </div>
        </div>
      </div>

      <div className="mt-6 grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="rounded-2xl border border-black/10 bg-white p-4 space-y-3">
          <h4 className="text-sm font-semibold text-black/70">Fund Vault</h4>
          <div className="grid grid-cols-2 gap-3 text-sm">
            <label className="flex flex-col gap-2">
              Amount
              <input
                type="number"
                min={0}
                value={fundAmount}
                onChange={(event) => setFundAmount(event.target.value)}
                className="rounded-xl border border-black/10 bg-white px-3 py-2"
              />
            </label>
            <label className="flex flex-col gap-2">
              Vault path
              <input
                type="text"
                value={fundPath}
                onChange={(event) => setFundPath(event.target.value)}
                className="rounded-xl border border-black/10 bg-white px-3 py-2"
              />
            </label>
          </div>
          <button
            onClick={handleFundVault}
            disabled={fundingVault || !user?.addr}
            className="w-full rounded-xl bg-black text-white py-2 text-sm font-semibold disabled:opacity-60"
          >
            {fundingVault ? "Funding..." : "Fund Vault"}
          </button>
          {fundError && (
            <p className="text-xs text-red-500">
              {normalizeFlowError(fundError)}
            </p>
          )}
        </div>

        <div className="rounded-2xl border border-black/10 bg-white p-4 space-y-3">
          <h4 className="text-sm font-semibold text-black/70">Profit Drip</h4>
          <div className="grid grid-cols-2 gap-3 text-sm">
            <label className="flex flex-col gap-2">
              Amount
              <input
                type="number"
                min={0}
                value={dripAmount}
                onChange={(event) => setDripAmount(event.target.value)}
                className="rounded-xl border border-black/10 bg-white px-3 py-2"
              />
            </label>
            <label className="flex flex-col gap-2">
              Receiver path
              <input
                type="text"
                value={dripReceiverPath}
                onChange={(event) => setDripReceiverPath(event.target.value)}
                className="rounded-xl border border-black/10 bg-white px-3 py-2"
              />
            </label>
          </div>
          <button
            onClick={handleProfitDrip}
            disabled={dripping || !user?.addr}
            className="w-full rounded-xl bg-emerald-500 text-white py-2 text-sm font-semibold disabled:opacity-60"
          >
            {dripping ? "Dripping..." : "Execute Profit Drip"}
          </button>
          {dripError && (
            <p className="text-xs text-red-500">
              {normalizeFlowError(dripError)}
            </p>
          )}
        </div>
      </div>
    </section>
  );
}
