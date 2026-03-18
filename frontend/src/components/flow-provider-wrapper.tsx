"use client";

import { FlowProvider } from "@onflow/react-sdk";
import { ReactNode } from "react";
import flowJSON from "../../flow.json";
import { flowConfig } from "@/flow/config";

interface FlowProviderWrapperProps {
  children: ReactNode;
}

export function FlowProviderWrapper({ children }: FlowProviderWrapperProps) {
  return (
    <FlowProvider
      config={{
        accessNodeUrl: flowConfig.accessNodeUrl,
        discoveryWallet: flowConfig.discoveryWallet,
        discoveryAuthnEndpoint: flowConfig.discoveryAuthnEndpoint,
        flowNetwork: flowConfig.flowNetwork,
        appDetailTitle: flowConfig.appDetailTitle,
        appDetailUrl:
          typeof window !== "undefined" ? window.location.origin : "",
        appDetailIcon: flowConfig.appDetailIcon,
        appDetailDescription: flowConfig.appDetailDescription,
        computeLimit: 1000,
        walletconnectProjectId: "9b70cfa398b2355a5eb9b1cf99f4a981",
      }}
      flowJson={flowJSON}
    >
      {children}
    </FlowProvider>
  );
}
