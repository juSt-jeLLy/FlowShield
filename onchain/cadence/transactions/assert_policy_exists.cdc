// assert_policy_exists.cdc
// Helper transaction for tests: ensures a GuardPolicy resource exists in storage.

import "GuardPolicy"

transaction {
    prepare(acct: auth(BorrowValue) &Account) {
        let _policy = acct.storage.borrow<&GuardPolicy.Policy>(from: GuardPolicy.StoragePath)
            ?? panic("Missing policy after setup")
    }
}
