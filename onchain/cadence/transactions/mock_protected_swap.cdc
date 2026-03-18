// mock_protected_swap.cdc
// Test helper: execute a protected swap using MockSwap.Swapper.

import "ActionRouter"
import "MockSwap"
import "GuardPolicy"
import "FungibleToken"
import "FlowToken"

transaction(expectedOut: UFix64, actualOut: UFix64, minOut: UFix64) {
    prepare(acct: auth(BorrowValue, Capabilities) &Account) {
        let policyRef = acct.storage.borrow<&GuardPolicy.Policy>(from: GuardPolicy.StoragePath)
            ?? panic("Missing GuardPolicy. Run setup_user.cdc first.")

        let receiverCap = acct.capabilities.get<&{FungibleToken.Receiver}>(/public/flowTokenReceiver)
        if !receiverCap.check() {
            panic("Missing flowTokenReceiver capability")
        }

        let vaultRef = acct.storage.borrow<auth(FungibleToken.Withdraw) &FlowToken.Vault>(from: /storage/flowTokenVault)
            ?? panic("Missing FlowToken vault")

        let input <- vaultRef.withdraw(amount: expectedOut)
        let swapper = MockSwap.Swapper(outAmount: actualOut, uniqueID: nil)

        ActionRouter.executeProtectedSwap(
            swapper: swapper,
            quote: nil,
            input: <-input,
            expectedOut: expectedOut,
            minOut: minOut,
            policy: policyRef,
            userReceiver: receiverCap
        )
    }
}
