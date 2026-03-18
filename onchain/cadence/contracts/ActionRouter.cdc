// ActionRouter.cdc
// Executes protected swap settlement and triggers slippage refunds.

import "FungibleToken"
import "FlowShieldTypes"
import "FlowShieldErrors"
import "GuardPolicy"
import "ProtectionVault"
import "FlowShieldAdmin"

access(all) contract ActionRouter {
    access(all) event ProtectedSwapExecuted(
        tokenId: String,
        expectedOut: UFix64,
        actualOut: UFix64,
        minOut: UFix64,
        premium: UFix64,
        refundRequested: UFix64,
        refundPaid: UFix64
    )

    access(all) fun settleSwap(
        output: @FungibleToken.Vault,
        expectedOut: UFix64,
        policy: &GuardPolicy.Policy,
        userReceiver: Capability<&{FungibleToken.Receiver}>
    ) {
        pre {
            expectedOut >= 0.0: "expectedOut must be >= 0"
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
            emit ProtectedSwapExecuted(
                tokenId: tokenId,
                expectedOut: expectedOut,
                actualOut: actualOut,
                minOut: expectedOut,
                premium: 0.0,
                refundRequested: 0.0,
                refundPaid: 0.0
            )
            return
        }

        let minOut = Self.minOut(expectedOut: expectedOut, slippageBps: config.maxSlippageBps)
        let premium = Self.bpsMul(amount: actualOut, bps: config.premiumBps)

        var outputVault <- output
        if premium > 0.0 {
            let premiumVault <- outputVault.withdraw(amount: premium)
            ProtectionVault.depositPremium(vault: <-premiumVault)
        }

        let targetNet = minOut + premium
        var refundRequested: UFix64 = 0.0
        if actualOut < targetNet {
            refundRequested = targetNet - actualOut
        }

        let now = getCurrentBlock().timestamp
        let allowed = policy.allowedRefund(requested: refundRequested, now: now)
        var refundPaid: UFix64 = 0.0

        if allowed > 0.0 {
            let refundVault <- ProtectionVault.withdrawRefund(tokenId: tokenId, amount: allowed)
            if refundVault != nil {
                let payout <- refundVault!
                refundPaid = payout.balance
                if refundPaid > 0.0 {
                    policy.recordRefund(amount: refundPaid, now: now)
                    receiver.deposit(from: <-payout)
                } else {
                    destroy payout
                }
            }
        }

        receiver.deposit(from: <-outputVault)

        emit ProtectedSwapExecuted(
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
