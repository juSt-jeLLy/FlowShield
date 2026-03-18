// profit_drip.cdc
// Scheduled or manual premium sweep from ProtectionVault treasury.

import "FungibleToken"
import "ProtectionVault"

transaction(tokenId: String, amount: UFix64, receiverPath: PublicPath) {
    prepare(acct: auth(BorrowValue, SaveValue, Capabilities) &Account) {
        pre {
            amount > 0.0: "amount must be > 0"
        }

        let receiver = acct.capabilities.get<&{FungibleToken.Receiver}>(receiverPath)
        if !receiver.check() {
            panic("Missing or invalid receiver capability")
        }

        if acct.storage.borrow<&ProtectionVault.Admin>(from: ProtectionVault.AdminStoragePath) == nil {
            acct.storage.save(<-ProtectionVault.createAdmin(), to: ProtectionVault.AdminStoragePath)
        }

        let adminRef = acct.storage.borrow<&ProtectionVault.Admin>(from: ProtectionVault.AdminStoragePath)
            ?? panic("Missing ProtectionVault admin resource")

        let payout <- adminRef.withdrawTreasury(tokenId: tokenId, amount: amount)
        if let vault <- payout {
            receiver.borrow()!.deposit(from: <-vault)
        }
    }
}
