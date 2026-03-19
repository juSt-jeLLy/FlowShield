// Cadence script placeholder for get_protection_limits
// get_protection_limits.cdc
// Read current coverage limits and caps.

import FlowShieldAdmin from 0xd23d4404df96f641

access(all) fun main(): FlowShieldAdmin.Config {
    return FlowShieldAdmin.getConfig()
}
