// settle_mock_swap.cdc
// Helper transaction for tests: simulate a swap output and run ActionRouter settlement.

import "ActionRouter"
import "GuardPolicy"
import "FungibleToken"
import "FlowToken"

transaction(expectedOut: UFix64, actualOut: UFix64) {
    prepare(acct: auth(BorrowValue, Capabilities) &Account) {
        let policyRef = acct.storage.borrow<&GuardPolicy.Policy>(from: GuardPolicy.StoragePath)
            ?? panic("Missing GuardPolicy. Run set_policy.cdc first.")

        let receiverCap = acct.capabilities.get<&{FungibleToken.Receiver}>(/public/flowTokenReceiver)
        let vaultRef = acct.storage.borrow<auth(FungibleToken.Withdraw) &FlowToken.Vault>(from: /storage/flowTokenVault)
            ?? panic("Missing FlowToken vault")

        let output <- vaultRef.withdraw(amount: actualOut)
        ActionRouter.settleSwap(
            output: <-output,
            expectedOut: expectedOut,
            policy: policyRef,
            userReceiver: receiverCap
        )
    }
}
