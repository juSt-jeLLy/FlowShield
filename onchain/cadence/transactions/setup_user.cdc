// setup_user.cdc
// Create user storage + capabilities for GuardPolicy.

import "GuardPolicy"

transaction {
    prepare(acct: auth(BorrowValue, SaveValue, Capabilities) &Account) {
        if acct.storage.borrow<&GuardPolicy.Policy>(from: GuardPolicy.StoragePath) == nil {
            let defaultConfig = GuardPolicy.createDefaultConfig()
            acct.storage.save(<-GuardPolicy.createPolicy(config: defaultConfig), to: GuardPolicy.StoragePath)
        }

        let publicCap = acct.capabilities.get<&{GuardPolicy.PolicyPublic}>(GuardPolicy.PublicPath)
        if !publicCap.check() {
            let issuedCap = acct.capabilities.storage.issue<&{GuardPolicy.PolicyPublic}>(GuardPolicy.StoragePath)
            acct.capabilities.publish(issuedCap, at: GuardPolicy.PublicPath)
        }
    }
}
