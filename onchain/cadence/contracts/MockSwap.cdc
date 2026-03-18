// MockSwap.cdc
// Test-only swapper to simulate deterministic slippage outputs.

import "DeFiActions"
import "FungibleToken"
import "FlowToken"

access(all) contract MockSwap {
    access(all) struct BasicQuote: DeFiActions.Quote {
        access(all) let inType: Type
        access(all) let outType: Type
        access(all) let inAmount: UFix64
        access(all) let outAmount: UFix64

        init(inType: Type, outType: Type, inAmount: UFix64, outAmount: UFix64) {
            self.inType = inType
            self.outType = outType
            self.inAmount = inAmount
            self.outAmount = outAmount
        }
    }

    access(all) struct Swapper: DeFiActions.Swapper {
        access(all) let outAmount: UFix64
        access(contract) var uniqueID: DeFiActions.UniqueIdentifier?

        init(outAmount: UFix64, uniqueID: DeFiActions.UniqueIdentifier?) {
            self.outAmount = outAmount
            self.uniqueID = uniqueID
        }

        access(all) view fun inType(): Type {
            return Type<@FlowToken.Vault>()
        }

        access(all) view fun outType(): Type {
            return Type<@FlowToken.Vault>()
        }

        access(all) fun getComponentInfo(): DeFiActions.ComponentInfo {
            return DeFiActions.ComponentInfo(
                type: self.getType(),
                id: self.id(),
                innerComponents: []
            )
        }

        access(contract) view fun copyID(): DeFiActions.UniqueIdentifier? {
            return self.uniqueID
        }

        access(contract) fun setID(_ id: DeFiActions.UniqueIdentifier?) {
            self.uniqueID = id
        }

        access(all) fun quoteIn(forDesired: UFix64, reverse: Bool): {DeFiActions.Quote} {
            let inType = reverse ? self.outType() : self.inType()
            let outType = reverse ? self.inType() : self.outType()
            return BasicQuote(
                inType: inType,
                outType: outType,
                inAmount: forDesired,
                outAmount: forDesired
            )
        }

        access(all) fun quoteOut(forProvided: UFix64, reverse: Bool): {DeFiActions.Quote} {
            let inType = reverse ? self.outType() : self.inType()
            let outType = reverse ? self.inType() : self.outType()
            return BasicQuote(
                inType: inType,
                outType: outType,
                inAmount: forProvided,
                outAmount: forProvided
            )
        }

        access(all) fun swap(quote: {DeFiActions.Quote}?, inVault: @{FungibleToken.Vault}): @{FungibleToken.Vault} {
            let flowVault <- inVault as! @FlowToken.Vault
            let amount = self.outAmount
            if amount <= 0.0 {
                destroy flowVault
                return <-FlowToken.createEmptyVault(vaultType: Type<@FlowToken.Vault>())
            }
            let out <- flowVault.withdraw(amount: amount)
            destroy flowVault
            return <-out
        }

        access(all) fun swapBack(quote: {DeFiActions.Quote}?, residual: @{FungibleToken.Vault}): @{FungibleToken.Vault} {
            let flowVault <- residual as! @FlowToken.Vault
            return <-flowVault
        }
    }
}
