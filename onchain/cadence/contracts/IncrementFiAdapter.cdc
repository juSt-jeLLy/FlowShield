// IncrementFiAdapter.cdc
// Adapter that wires IncrementFi swaps into the SlipShield protection flow.

import "DeFiActions"
import "FungibleToken"
import "IncrementFiSwapConnectors"
import "ActionRouter"
import "GuardPolicy"

access(all) contract IncrementFiAdapter {
    access(all) fun executeProtectedSwap(
        input: @{FungibleToken.Vault},
        expectedOut: UFix64,
        minOut: UFix64,
        inVaultType: Type,
        outVaultType: Type,
        policy: &GuardPolicy.Policy,
        userReceiver: Capability<&{FungibleToken.Receiver}>
    ) {
        pre {
            expectedOut >= 0.0: "expectedOut must be >= 0"
            minOut >= 0.0: "minOut must be >= 0"
        }

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

        ActionRouter.executeProtectedSwap(
            swapper: swapper,
            quote: nil,
            input: <-input,
            expectedOut: expectedOut,
            minOut: minOut,
            policy: policy,
            userReceiver: userReceiver
        )
    }
}
