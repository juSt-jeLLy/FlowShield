// setup_vault.cdc
// Seed the ProtectionVault with an initial underwriter deposit.

import "FungibleToken"
import "ProtectionVault"

transaction(seedAmount: UFix64, fromVaultPath: StoragePath) {
    prepare(acct: auth(BorrowValue) &Account) {
        pre {
            seedAmount > 0.0: "seedAmount must be > 0"
        }
        let provider = acct.storage.borrow<auth(FungibleToken.Withdraw) &{FungibleToken.Provider}>(from: fromVaultPath)
            ?? panic("Missing vault at provided storage path")
        let payment <- provider.withdraw(amount: seedAmount)
        ProtectionVault.depositUnderwriter(vault: <-payment)
    }
}
