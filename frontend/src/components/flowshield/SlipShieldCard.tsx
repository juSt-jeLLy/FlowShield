"use client";

import { useMemo, useState } from "react";
import { useFlowCurrentUser, useFlowMutate } from "@onflow/react-sdk";
import {
  buildProtectedSwapArgs,
  buildSetPolicyArgs,
  PROTECTED_SWAP_CADENCE,
  SET_POLICY_CADENCE,
} from "@/flow/transactions";
import { flowShieldServiceUrl } from "@/flow/config";
import { DEFAULT_TOKEN_IN, DEFAULT_TOKEN_OUT, TOKENS } from "@/flow/tokens";
import { normalizeFlowError } from "@/flow/errors";
import type { QuoteResponse } from "@/flow/types";

const toUFix64 = (value: string | number) => {
  const numeric = Number(value);
  if (!Number.isFinite(numeric)) return "0.0";
  return numeric.toFixed(8);
};

export function SlipShieldCard() {
  const { user } = useFlowCurrentUser();
  const [enabled, setEnabled] = useState(true);
  const [maxSlippageBps, setMaxSlippageBps] = useState(50);
  const [premiumBps, setPremiumBps] = useState(30);
  const [maxRefundPerSwap, setMaxRefundPerSwap] = useState("5.0");
  const [maxRefundPerEpoch, setMaxRefundPerEpoch] = useState("50.0");
  const [epochSeconds, setEpochSeconds] = useState("86400.0");

  const [amountIn, setAmountIn] = useState("1.0");
  const [tokenIn, setTokenIn] = useState(DEFAULT_TOKEN_IN.symbol);
  const [tokenOut, setTokenOut] = useState(DEFAULT_TOKEN_OUT.symbol);

  const [quote, setQuote] = useState<QuoteResponse | null>(null);
  const [quoteError, setQuoteError] = useState<string | null>(null);
  const [quoteLoading, setQuoteLoading] = useState(false);

  const { mutate: savePolicy, isPending: savingPolicy, error: policyError } =
    useFlowMutate();
  const { mutate: executeSwap, isPending: swapping, error: swapError } =
    useFlowMutate();

  const tokenInMeta = useMemo(
    () => TOKENS.find((token) => token.symbol === tokenIn) ?? DEFAULT_TOKEN_IN,
    [tokenIn]
  );
  const tokenOutMeta = useMemo(
    () => TOKENS.find((token) => token.symbol === tokenOut) ?? DEFAULT_TOKEN_OUT,
    [tokenOut]
  );

  const canSwap = Boolean(quote && user?.addr);

  const handleQuote = async () => {
    setQuoteLoading(true);
    setQuoteError(null);
    try {
      const response = await fetch(`${flowShieldServiceUrl}/quote`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          amountIn: Number(amountIn),
          slippageBps: maxSlippageBps,
          premiumBps,
          maxRefundPerSwap: Number(maxRefundPerSwap),
        }),
      });
      if (!response.ok) {
        throw new Error("Quote service unavailable");
      }
      const data = (await response.json()) as QuoteResponse;
      setQuote(data);
    } catch (error) {
      setQuoteError(normalizeFlowError(error));
    } finally {
      setQuoteLoading(false);
    }
  };

  const handleSavePolicy = () => {
    savePolicy({
      cadence: SET_POLICY_CADENCE,
      args: (arg, t) => [
        arg(enabled, t.Bool),
        arg(maxSlippageBps, t.UInt64),
        arg(toUFix64(maxRefundPerSwap), t.UFix64),
        arg(toUFix64(maxRefundPerEpoch), t.UFix64),
        arg(toUFix64(epochSeconds), t.UFix64),
        arg(premiumBps, t.UInt64),
      ],
    });
  };

  const handleProtectedSwap = () => {
    if (!quote) return;
    executeSwap({
      cadence: PROTECTED_SWAP_CADENCE,
      args: (arg, t) => [
        arg(toUFix64(amountIn), t.UFix64),
        arg(quote.expectedOut, t.UFix64),
        arg(quote.minOut, t.UFix64),
        arg(tokenInMeta.typeId, t.Type),
        arg(tokenOutMeta.typeId, t.Type),
        arg(tokenInMeta.storagePath, t.Path),
        arg(tokenOutMeta.receiverPath, t.Path),
      ],
    });
  };

  return (
    <section className="rounded-3xl border border-black/10 bg-white/80 backdrop-blur-lg p-6 sm:p-8 shadow-[0_20px_60px_-30px_rgba(15,23,42,0.35)]">
      <div className="flex flex-col gap-2">
        <span className="text-xs uppercase tracking-[0.3em] text-black/50">
          SlipShield
        </span>
        <h2 className="text-2xl sm:text-3xl font-semibold text-black">
          Configure protection + execute a protected swap
        </h2>
        <p className="text-sm text-black/60">
          Save a policy, request a quote, then swap through the IncrementFi
          adapter with automatic slippage refunds.
        </p>
      </div>

      <div className="mt-6 grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="space-y-4">
          <div className="flex items-center justify-between">
            <h3 className="text-lg font-semibold text-black">Policy</h3>
            <label className="flex items-center gap-2 text-sm text-black/60">
              <input
                type="checkbox"
                className="h-4 w-4"
                checked={enabled}
                onChange={(event) => setEnabled(event.target.checked)}
              />
              Enabled
            </label>
          </div>

          <div className="grid grid-cols-2 gap-3 text-sm">
            <label className="flex flex-col gap-2">
              Max slippage (bps)
              <input
                type="number"
                min={0}
                max={10_000}
                value={maxSlippageBps}
                onChange={(event) => setMaxSlippageBps(Number(event.target.value))}
                className="rounded-xl border border-black/10 bg-white px-3 py-2"
              />
            </label>
            <label className="flex flex-col gap-2">
              Premium (bps)
              <input
                type="number"
                min={0}
                max={10_000}
                value={premiumBps}
                onChange={(event) => setPremiumBps(Number(event.target.value))}
                className="rounded-xl border border-black/10 bg-white px-3 py-2"
              />
            </label>
            <label className="flex flex-col gap-2">
              Max refund per swap
              <input
                type="number"
                min={0}
                value={maxRefundPerSwap}
                onChange={(event) => setMaxRefundPerSwap(event.target.value)}
                className="rounded-xl border border-black/10 bg-white px-3 py-2"
              />
            </label>
            <label className="flex flex-col gap-2">
              Max refund per epoch
              <input
                type="number"
                min={0}
                value={maxRefundPerEpoch}
                onChange={(event) => setMaxRefundPerEpoch(event.target.value)}
                className="rounded-xl border border-black/10 bg-white px-3 py-2"
              />
            </label>
            <label className="flex flex-col gap-2 col-span-2">
              Epoch seconds
              <input
                type="number"
                min={3600}
                value={epochSeconds}
                onChange={(event) => setEpochSeconds(event.target.value)}
                className="rounded-xl border border-black/10 bg-white px-3 py-2"
              />
            </label>
          </div>

          <button
            onClick={handleSavePolicy}
            disabled={savingPolicy || !user?.addr}
            className="w-full rounded-xl bg-black text-white py-3 text-sm font-semibold hover:bg-black/90 disabled:opacity-60"
          >
            {savingPolicy ? "Saving policy..." : "Save Policy"}
          </button>
          {policyError && (
            <p className="text-xs text-red-500">
              {normalizeFlowError(policyError)}
            </p>
          )}
        </div>

        <div className="space-y-4">
          <div className="flex items-center justify-between">
            <h3 className="text-lg font-semibold text-black">Protected Swap</h3>
            <span className="text-xs text-black/50">DEX: IncrementFi</span>
          </div>

          <div className="grid grid-cols-2 gap-3 text-sm">
            <label className="flex flex-col gap-2 col-span-2">
              Amount in
              <input
                type="number"
                min={0}
                value={amountIn}
                onChange={(event) => setAmountIn(event.target.value)}
                className="rounded-xl border border-black/10 bg-white px-3 py-2"
              />
            </label>
            <label className="flex flex-col gap-2">
              Token in
              <select
                value={tokenIn}
                onChange={(event) => setTokenIn(event.target.value)}
                className="rounded-xl border border-black/10 bg-white px-3 py-2"
              >
                {TOKENS.map((token) => (
                  <option key={token.symbol} value={token.symbol}>
                    {token.symbol}
                  </option>
                ))}
              </select>
            </label>
            <label className="flex flex-col gap-2">
              Token out
              <select
                value={tokenOut}
                onChange={(event) => setTokenOut(event.target.value)}
                className="rounded-xl border border-black/10 bg-white px-3 py-2"
              >
                {TOKENS.map((token) => (
                  <option key={token.symbol} value={token.symbol}>
                    {token.symbol}
                  </option>
                ))}
              </select>
            </label>
          </div>

          <button
            onClick={handleQuote}
            disabled={quoteLoading}
            className="w-full rounded-xl border border-black/10 py-3 text-sm font-semibold hover:bg-black/5"
          >
            {quoteLoading ? "Fetching quote..." : "Get Quote"}
          </button>

          {quote && (
            <div className="rounded-2xl border border-black/10 bg-black/5 p-4 text-sm space-y-2">
              <div className="flex items-center justify-between">
                <span>Expected out</span>
                <span className="font-semibold">{quote.expectedOut}</span>
              </div>
              <div className="flex items-center justify-between">
                <span>Min out</span>
                <span className="font-semibold">{quote.minOut}</span>
              </div>
              <div className="flex items-center justify-between">
                <span>Premium</span>
                <span className="font-semibold">{quote.premium}</span>
              </div>
              <div className="flex items-center justify-between">
                <span>Refund cap</span>
                <span className="font-semibold">{quote.refundCap}</span>
              </div>
              <div className="flex items-center justify-between">
                <span>Risk score</span>
                <span className="font-semibold">
                  {quote.riskScore} ({quote.riskLabel})
                </span>
              </div>
              <div className="text-xs text-black/50">
                Route: {quote.route}
              </div>
            </div>
          )}

          {quoteError && (
            <p className="text-xs text-red-500">{quoteError}</p>
          )}

          <button
            onClick={handleProtectedSwap}
            disabled={!canSwap || swapping}
            className="w-full rounded-xl bg-emerald-500 text-white py-3 text-sm font-semibold hover:bg-emerald-600 disabled:opacity-60"
          >
            {swapping ? "Executing swap..." : "Execute Protected Swap"}
          </button>
          {swapError && (
            <p className="text-xs text-red-500">
              {normalizeFlowError(swapError)}
            </p>
          )}
        </div>
      </div>
    </section>
  );
}
