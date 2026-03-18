// protected_swap.cdc
// Execute swap via IncrementFi connector and settle with ActionRouter.

import "DeFiActions"
import "FungibleToken"
import "IncrementFiSwapConnectors"
import "SwapConfig"
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
    prepare(acct: auth(BorrowValue) &Account) {
        let opID = DeFiActions.createUniqueIdentifier()

        let swapPath = [
            SwapConfig.SliceTokenTypeIdentifierFromVaultType(vaultTypeIdentifier: inVaultType.identifier),
            SwapConfig.SliceTokenTypeIdentifierFromVaultType(vaultTypeIdentifier: outVaultType.identifier)
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

        let receiverCap = acct.getCapability<&{FungibleToken.Receiver}>(outReceiverPath)
        ActionRouter.settleSwap(
            output: <-out,
            expectedOut: expectedOut,
            policy: policyRef,
            userReceiver: receiverCap
        )
    }
}
