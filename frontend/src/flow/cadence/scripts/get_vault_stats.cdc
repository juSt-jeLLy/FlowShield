// Cadence script placeholder for get_vault_stats
// get_vault_stats.cdc
// Read vault stats (reserves, payouts, fees collected).

import "ProtectionVault"
import "FlowShieldTypes"

access(all) fun main(tokenId: String): FlowShieldTypes.VaultStats {
    return ProtectionVault.getStats(tokenId: tokenId)
}
