// fund_vault.cdc
// Deposit assets into ProtectionVault refund pool.

import FungibleToken from 0x9a0766d93b6608b7
import ProtectionVault from 0xd23d4404df96f641

transaction(amount: UFix64, fromVaultPath: StoragePath) {
    prepare(acct: auth(BorrowValue) &Account) {
        let provider = acct.storage.borrow<auth(FungibleToken.Withdraw) &{FungibleToken.Provider}>(from: fromVaultPath)
            ?? panic("Missing vault at provided storage path")
        let payment <- provider.withdraw(amount: amount)
        ProtectionVault.depositUnderwriter(vault: <-payment)
    }
}
