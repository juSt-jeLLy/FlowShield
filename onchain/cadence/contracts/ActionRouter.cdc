// ActionRouter.cdc
// Executes protected swap settlement and triggers slippage refunds.

import "FungibleToken"
import "FlowShieldTypes"
import "FlowShieldErrors"
import "GuardPolicy"
import "ProtectionVault"
import "FlowShieldAdmin"
import "DeFiActions"

access(all) contract ActionRouter {
    access(all) event SlipShieldProtectedSwap(
        tokenId: String,
        expectedOut: UFix64,
        actualOut: UFix64,
        minOut: UFix64,
        premium: UFix64,
        refundRequested: UFix64,
        refundPaid: UFix64
    )
    access(all) event SlipShieldPremiumPaid(tokenId: String, amount: UFix64)
    access(all) event SlipShieldRefundPaid(tokenId: String, amount: UFix64)

    access(all) fun settleSwap(
        output: @{FungibleToken.Vault},
        expectedOut: UFix64,
        policy: &GuardPolicy.Policy,
        userReceiver: Capability<&{FungibleToken.Receiver}>
    ) {
        let config = policy.getConfig()
        let minOut = ActionRouter.minOut(expectedOut: expectedOut, slippageBps: config.maxSlippageBps)
        ActionRouter.settleSwapWithMinOut(
            output: <-output,
            expectedOut: expectedOut,
            minOut: minOut,
            policy: policy,
            userReceiver: userReceiver
        )
    }

    access(all) fun executeProtectedSwap(
        swapper: {DeFiActions.Swapper},
        quote: {DeFiActions.Quote}?,
        input: @{FungibleToken.Vault},
        expectedOut: UFix64,
        minOut: UFix64,
        policy: &GuardPolicy.Policy,
        userReceiver: Capability<&{FungibleToken.Receiver}>
    ) {
        let config = policy.getConfig()
        var effectiveMinOut = minOut
        if config.enabled {
            let policyMinOut = ActionRouter.minOut(
                expectedOut: expectedOut,
                slippageBps: config.maxSlippageBps
            )
            if effectiveMinOut < policyMinOut {
                effectiveMinOut = policyMinOut
            }
        }

        let output <- swapper.swap(quote: quote, inVault: <-input)
        ActionRouter.settleSwapWithMinOut(
            output: <-output,
            expectedOut: expectedOut,
            minOut: effectiveMinOut,
            policy: policy,
            userReceiver: userReceiver
        )
    }

    access(all) fun settleSwapWithMinOut(
        output: @{FungibleToken.Vault},
        expectedOut: UFix64,
        minOut: UFix64,
        policy: &GuardPolicy.Policy,
        userReceiver: Capability<&{FungibleToken.Receiver}>
    ) {
        pre {
            expectedOut >= 0.0: "expectedOut must be >= 0"
            minOut >= 0.0: "minOut must be >= 0"
            userReceiver.check(): FlowShieldErrors.ErrInvalidReceiver
        }

        if FlowShieldAdmin.isPaused {
            panic(FlowShieldErrors.ErrPaused)
        }

        let receiver = userReceiver.borrow()
            ?? panic(FlowShieldErrors.ErrInvalidReceiver)

        let actualOut = output.balance
        let tokenId = output.getType().identifier
        let config = policy.getConfig()

        if !config.enabled {
            receiver.deposit(from: <-output)
            emit SlipShieldProtectedSwap(
                tokenId: tokenId,
                expectedOut: expectedOut,
                actualOut: actualOut,
                minOut: minOut,
                premium: 0.0,
                refundRequested: 0.0,
                refundPaid: 0.0
            )
            return
        }

        let premium = ActionRouter.bpsMul(amount: actualOut, bps: config.premiumBps)

        var outputVault <- output
        if premium > 0.0 {
            let premiumVault <- outputVault.withdraw(amount: premium)
            ProtectionVault.depositPremium(vault: <-premiumVault)
            emit SlipShieldPremiumPaid(tokenId: tokenId, amount: premium)
        }

        let targetNet = minOut + premium
        var refundRequested = 0.0
        if actualOut < targetNet {
            refundRequested = targetNet - actualOut
        }

        let now = getCurrentBlock().timestamp
        let allowed = policy.allowedRefund(requested: refundRequested, now: now)
        var refundPaid = 0.0

        if allowed > 0.0 {
            let refundVault <- ProtectionVault.withdrawRefund(tokenId: tokenId, amount: allowed)
            if let payout <- refundVault {
                refundPaid = payout.balance
                if refundPaid > 0.0 {
                    policy.recordRefund(amount: refundPaid, now: now)
                    receiver.deposit(from: <-payout)
                    emit SlipShieldRefundPaid(tokenId: tokenId, amount: refundPaid)
                } else {
                    destroy payout
                }
            }
        }

        receiver.deposit(from: <-outputVault)

        emit SlipShieldProtectedSwap(
            tokenId: tokenId,
            expectedOut: expectedOut,
            actualOut: actualOut,
            minOut: minOut,
            premium: premium,
            refundRequested: refundRequested,
            refundPaid: refundPaid
        )
    }

    access(all) fun minOut(expectedOut: UFix64, slippageBps: UInt64): UFix64 {
        pre {
            slippageBps <= FlowShieldTypes.MaxBps:
                FlowShieldErrors.ErrInvalidBps
        }
        let retainedBps = FlowShieldTypes.MaxBps - slippageBps
        return (expectedOut * UFix64(retainedBps)) / UFix64(FlowShieldTypes.MaxBps)
    }

    access(all) fun bpsMul(amount: UFix64, bps: UInt64): UFix64 {
        if bps == 0 || amount == 0.0 {
            return 0.0
        }
        return (amount * UFix64(bps)) / UFix64(FlowShieldTypes.MaxBps)
    }
}
