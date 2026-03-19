// Cadence script placeholder for get_vault_stats
// get_vault_stats.cdc
// Read vault stats (reserves, payouts, fees collected).

import ProtectionVault from 0xd23d4404df96f641
import FlowShieldTypes from 0xd23d4404df96f641

access(all) fun main(tokenId: String): FlowShieldTypes.VaultStats {
    return ProtectionVault.getStats(tokenId: tokenId)
}
