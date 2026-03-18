// get_protection_limits.cdc
// Read current coverage limits and caps.

import "FlowShieldAdmin"

access(all) fun main(): FlowShieldAdmin.Config {
    return FlowShieldAdmin.getConfig()
}
