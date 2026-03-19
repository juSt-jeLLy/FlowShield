// scripts.ts
// Read-only Cadence scripts for FlowShield.

import { flowShieldAddress } from "./config";

export const GET_POLICY_CADENCE = `// get_policy.cdc
import GuardPolicy from ${flowShieldAddress}
import FlowShieldTypes from ${flowShieldAddress}

access(all) fun main(address: Address): FlowShieldTypes.PolicySnapshot? {
    let cap = getAccount(address)
        .capabilities.get<&{GuardPolicy.PolicyPublic}>(GuardPolicy.PublicPath)
    let policy = cap.borrow()
    if policy == nil {
        return nil
    }
    return FlowShieldTypes.PolicySnapshot(
        config: policy!.getConfig(),
        usage: policy!.getUsage()
    )
}
`;

export const GET_VAULT_STATS_CADENCE = `// get_vault_stats.cdc
import ProtectionVault from ${flowShieldAddress}
import FlowShieldTypes from ${flowShieldAddress}

access(all) fun main(tokenId: String): FlowShieldTypes.VaultStats {
    return ProtectionVault.getStats(tokenId: tokenId)
}
`;

export const GET_PROTECTION_LIMITS_CADENCE = `// get_protection_limits.cdc
import FlowShieldAdmin from ${flowShieldAddress}

access(all) fun main(): FlowShieldAdmin.Config {
    return FlowShieldAdmin.getConfig()
}
`;

export function buildGetPolicyArgs(address: string) {
  return [address] as const;
}

export function buildGetVaultStatsArgs(tokenId: string) {
  return [tokenId] as const;
}
