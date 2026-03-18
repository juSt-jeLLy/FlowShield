"use client";

import { Connect, useFlowConfig } from "@onflow/react-sdk";

export function FlowHeader() {
  const { flowNetwork } = useFlowConfig();

  return (
    <header className="w-full">
      <div className="container mx-auto px-6 lg:px-8">
        <div className="flex h-16 items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="h-9 w-9 rounded-full bg-gradient-to-br from-emerald-400 via-cyan-400 to-blue-500" />
            <div className="flex flex-col">
              <span className="text-base font-semibold text-black">
                FlowShield
              </span>
              <span className="text-xs text-black/50">SlipShield Testnet</span>
            </div>
          </div>

          <div className="flex items-center gap-4">
            <div className="flex items-center gap-2 px-4 py-2 rounded-full bg-black/5">
              <div
                className="w-4 h-4 rounded-full"
                style={{
                  backgroundColor:
                    flowNetwork === "testnet"
                      ? "#00ef8b"
                      : flowNetwork === "mainnet"
                      ? "#3b82f6"
                      : "#a855f7",
                }}
              ></div>
              <span className="text-sm font-medium text-black capitalize">
                {flowNetwork}
              </span>
            </div>
            <Connect />
          </div>
        </div>
      </div>
    </header>
  );
}
