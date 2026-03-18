"use client";

import { SlipShieldCard } from "@/components/flowshield/SlipShieldCard";
import { ProtectionStatus } from "@/components/flowshield/ProtectionStatus";

export function FlowContent() {
  return (
    <main className="container mx-auto px-4 sm:px-6 lg:px-8 relative">
      <div className="py-10 sm:py-14 lg:py-20 space-y-12">
        <section className="grid grid-cols-1 lg:grid-cols-[1.3fr_1fr] gap-8 items-center">
          <div className="space-y-6 animate-fade-up">
            <div className="inline-flex items-center gap-2 rounded-full border border-black/10 bg-white/70 px-4 py-2 text-xs uppercase tracking-[0.3em] text-black/60">
              Live on Flow Testnet
            </div>
            <h1 className="text-4xl sm:text-5xl lg:text-6xl font-semibold text-black leading-tight">
              Protect every swap with a live SlipShield refund layer.
            </h1>
            <p className="text-base sm:text-lg text-black/60 max-w-xl">
              FlowShield wraps DEX swaps with on‑chain slippage insurance, pooled
              refunds, and off‑chain risk scoring to keep everyday traders safe.
            </p>
            <div className="flex flex-wrap gap-3 text-sm">
              {[
                "Premium‑funded refunds",
                "IncrementFi routing",
                "Real‑time risk score",
              ].map((label) => (
                <span
                  key={label}
                  className="rounded-full bg-black/5 px-4 py-2 text-black/70"
                >
                  {label}
                </span>
              ))}
            </div>
          </div>
          <div className="rounded-3xl border border-black/10 bg-white/80 p-6 shadow-[0_24px_60px_-40px_rgba(15,23,42,0.35)] animate-fade-up">
            <h3 className="text-lg font-semibold text-black">FlowShield stack</h3>
            <ul className="mt-4 space-y-3 text-sm text-black/60">
              <li>• ActionRouter settles swaps + refunds</li>
              <li>• ProtectionVault pools premiums + payouts</li>
              <li>• Risk service prices quotes + caps</li>
              <li>• Profit drip schedules treasury sweeps</li>
            </ul>
          </div>
        </section>

        <SlipShieldCard />
        <ProtectionStatus />
      </div>
    </main>
  );
}
