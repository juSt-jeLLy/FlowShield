// protected_swap.cdc
// Execute swap via IncrementFi adapter and settle with ActionRouter.

import FungibleToken from 0x9a0766d93b6608b7
import GuardPolicy from 0xd23d4404df96f641
import IncrementFiAdapter from 0xd23d4404df96f641

transaction(
    amountIn: UFix64,
    expectedOut: UFix64,
    minOut: UFix64,
    inVaultType: Type,
    outVaultType: Type,
    inVaultPath: StoragePath,
    outReceiverPath: PublicPath
) {
    prepare(acct: auth(BorrowValue, Capabilities) &Account) {
        let provider = acct.storage.borrow<auth(FungibleToken.Withdraw) &{FungibleToken.Provider}>(from: inVaultPath)
            ?? panic("Missing input vault at provided storage path")

        let payment <- provider.withdraw(amount: amountIn)

        let policyRef = acct.storage.borrow<&GuardPolicy.Policy>(from: GuardPolicy.StoragePath)
            ?? panic("Missing GuardPolicy. Run setup_user.cdc first.")

        let receiverCap = acct.capabilities.get<&{FungibleToken.Receiver}>(outReceiverPath)
        IncrementFiAdapter.executeProtectedSwap(
            input: <-payment,
            expectedOut: expectedOut,
            minOut: minOut,
            inVaultType: inVaultType,
            outVaultType: outVaultType,
            policy: policyRef,
            userReceiver: receiverCap
        )
    }
}
