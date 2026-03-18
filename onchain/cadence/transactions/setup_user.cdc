// setup_user.cdc
// Create user storage + capabilities for GuardPolicy.

import "GuardPolicy"

transaction {
    prepare(acct: auth(BorrowValue, SaveValue, LinkValue) &Account) {
        if acct.storage.borrow<&GuardPolicy.Policy>(from: GuardPolicy.StoragePath) == nil {
            let defaultConfig = GuardPolicy.createDefaultConfig()
            acct.storage.save(<-GuardPolicy.createPolicy(config: defaultConfig), to: GuardPolicy.StoragePath)
        }

        if !acct.getCapability<&{GuardPolicy.PolicyPublic}>(GuardPolicy.PublicPath).check() {
            acct.link<&{GuardPolicy.PolicyPublic}>(GuardPolicy.PublicPath, target: GuardPolicy.StoragePath)
        }
    }
}
