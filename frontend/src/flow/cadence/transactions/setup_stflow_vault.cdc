// setup_stflow_vault.cdc
// Initializes a stFLOW vault + receiver capability for the signer.

import FungibleToken from 0x9a0766d93b6608b7
import stFlowToken from 0xe45c64ecfe31e465

transaction {
    prepare(acct: auth(BorrowValue, SaveValue, Capabilities) &Account) {
        if acct.storage.borrow<&stFlowToken.Vault>(from: stFlowToken.VaultStoragePath) == nil {
            acct.storage.save(<-stFlowToken.createEmptyVault(), to: stFlowToken.VaultStoragePath)
        }

        let receiver = acct.capabilities.get<&{FungibleToken.Receiver}>(stFlowToken.VaultReceiverPublicPath)
        if !receiver.check() {
            let issuedCap = acct.capabilities.storage.issue<&{FungibleToken.Receiver}>(stFlowToken.VaultStoragePath)
            acct.capabilities.publish(issuedCap, at: stFlowToken.VaultReceiverPublicPath)
        }
    }
}
