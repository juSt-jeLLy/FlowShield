// Transaction to swap tokens using IncrementFi's DeFi Actions connector.
// This demonstrates using IncrementFi's Swapper connector to execute a token swap.
//
// Arguments:
//   - amountIn: The amount of input tokens to swap
//   - inVaultType: The vault type for the input token (e.g., Type<@FlowToken.Vault>())
//   - outVaultType: The vault type for the output token (e.g., Type<@stFlowToken.Vault>())
//
// This transaction is used by the fork test to demonstrate real DeFi protocol integration.

import "DeFiActions"
import "FungibleToken"
import "FlowToken"
import "IncrementFiSwapConnectors"

transaction(amountIn: UFix64, inVaultType: Type, outVaultType: Type) {
    prepare(acct: auth(BorrowValue) &Account) {
        let opID = DeFiActions.createUniqueIdentifier()
        
        // Construct swap path from vault types
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
        let flowVaultRef = acct.storage.borrow<auth(FungibleToken.Withdraw) &FlowToken.Vault>(from: /storage/flowTokenVault)
            ?? panic("Holder missing FlowToken vault")
        let payment <- flowVaultRef.withdraw(amount: amountIn)
        let out <- swapper.swap(quote: nil, inVault: <-payment)
        assert(out.balance > 0.0, message: "Expected positive output")
        destroy out
    }
}

