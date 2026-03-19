"use client";

import { FlowProvider } from "@onflow/react-sdk";
import * as fcl from "@onflow/fcl";
import { ReactNode } from "react";
import flowJSON from "../../flow.json";
import { flowConfig } from "@/flow/config";

interface FlowProviderWrapperProps {
  children: ReactNode;
}

export function FlowProviderWrapper({ children }: FlowProviderWrapperProps) {
  if (typeof window !== "undefined") {
    fcl
      .config()
      .put("accessNode.api", flowConfig.accessNodeUrl)
      .put("discovery.wallet", flowConfig.discoveryWallet)
      .put("discovery.authn.endpoint", flowConfig.discoveryAuthnEndpoint)
      .put("flow.network", flowConfig.flowNetwork);
  }

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
