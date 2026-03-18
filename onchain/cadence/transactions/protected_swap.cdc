// protected_swap.cdc
// Execute swap via IncrementFi connector and settle with ActionRouter.

import "DeFiActions"
import "FungibleToken"
import "IncrementFiSwapConnectors"
import "GuardPolicy"
import "ActionRouter"

transaction(
    amountIn: UFix64,
    expectedOut: UFix64,
    inVaultType: Type,
    outVaultType: Type,
    inVaultPath: StoragePath,
    outReceiverPath: PublicPath
) {
    prepare(acct: auth(BorrowValue, Capabilities) &Account) {
        let opID = DeFiActions.createUniqueIdentifier()

        let inTypeId = inVaultType.identifier
        let outTypeId = outVaultType.identifier
        let swapPath = [
            inTypeId.slice(from: 0, upTo: inTypeId.length - 6),
            outTypeId.slice(from: 0, upTo: outTypeId.length - 6)
        ]

        let swapper = IncrementFiSwapConnectors.Swapper(
            path: swapPath,
            inVault: inVaultType,
            outVault: outVaultType,
            uniqueID: opID
        )

        let provider = acct.storage.borrow<auth(FungibleToken.Withdraw) &{FungibleToken.Provider}>(from: inVaultPath)
            ?? panic("Missing input vault at provided storage path")

        let payment <- provider.withdraw(amount: amountIn)
        let out <- swapper.swap(quote: nil, inVault: <-payment)

        let policyRef = acct.storage.borrow<&GuardPolicy.Policy>(from: GuardPolicy.StoragePath)
            ?? panic("Missing GuardPolicy. Run setup_user.cdc first.")

        let receiverCap = acct.capabilities.get<&{FungibleToken.Receiver}>(outReceiverPath)
        ActionRouter.settleSwap(
            output: <-out,
            expectedOut: expectedOut,
            policy: policyRef,
            userReceiver: receiverCap
        )
    }
}
