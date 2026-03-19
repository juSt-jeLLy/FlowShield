// Cadence script placeholder for get_policy
// get_policy.cdc
// Read a user’s GuardPolicy (config + usage).

import GuardPolicy from 0xd23d4404df96f641
import FlowShieldTypes from 0xd23d4404df96f641

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
