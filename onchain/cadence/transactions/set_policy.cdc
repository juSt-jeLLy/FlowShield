// set_policy.cdc
// Create or update GuardPolicy for a user.

import "GuardPolicy"
import "FlowShieldTypes"

transaction(
    enabled: Bool,
    maxSlippageBps: UInt64,
    maxRefundPerSwap: UFix64,
    maxRefundPerEpoch: UFix64,
    epochSeconds: UFix64,
    premiumBps: UInt64
) {
    prepare(acct: auth(BorrowValue, SaveValue) &Account) {
        let config = FlowShieldTypes.PolicyConfig(
            enabled: enabled,
            maxSlippageBps: maxSlippageBps,
            maxRefundPerSwap: maxRefundPerSwap,
            maxRefundPerEpoch: maxRefundPerEpoch,
            epochSeconds: epochSeconds,
            premiumBps: premiumBps
        )

        let existing = acct.storage.borrow<&GuardPolicy.Policy>(from: GuardPolicy.StoragePath)
        if existing == nil {
            acct.storage.save(<-GuardPolicy.createPolicy(config: config), to: GuardPolicy.StoragePath)
        } else {
            existing!.updateConfig(config)
        }
    }
}
