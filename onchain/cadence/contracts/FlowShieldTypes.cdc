// FlowShieldTypes.cdc
// Shared structs, constants, and helper types used across FlowShield contracts.

access(all) contract FlowShieldTypes {
    access(all) let MaxBps: UInt64
    access(all) let DefaultEpochSeconds: UFix64

    init() {
        self.MaxBps = 10_000
        self.DefaultEpochSeconds = 86_400.0
    }

    access(all) struct PolicyConfig {
        access(all) let enabled: Bool
        access(all) let maxSlippageBps: UInt64
        access(all) let maxRefundPerSwap: UFix64
        access(all) let maxRefundPerEpoch: UFix64
        access(all) let epochSeconds: UFix64
        access(all) let premiumBps: UInt64

        init(
            enabled: Bool,
            maxSlippageBps: UInt64,
            maxRefundPerSwap: UFix64,
            maxRefundPerEpoch: UFix64,
            epochSeconds: UFix64,
            premiumBps: UInt64
        ) {
            pre {
                maxSlippageBps <= FlowShieldTypes.MaxBps:
                    "maxSlippageBps must be <= 10_000"
                premiumBps <= FlowShieldTypes.MaxBps:
                    "premiumBps must be <= 10_000"
                epochSeconds > 0.0:
                    "epochSeconds must be > 0"
            }
            self.enabled = enabled
            self.maxSlippageBps = maxSlippageBps
            self.maxRefundPerSwap = maxRefundPerSwap
            self.maxRefundPerEpoch = maxRefundPerEpoch
            self.epochSeconds = epochSeconds
            self.premiumBps = premiumBps
        }
    }

    access(all) struct PolicyUsage {
        access(all) let epochStart: UFix64
        access(all) let usedThisEpoch: UFix64

        init(epochStart: UFix64, usedThisEpoch: UFix64) {
            self.epochStart = epochStart
            self.usedThisEpoch = usedThisEpoch
        }
    }

    access(all) struct PolicySnapshot {
        access(all) let config: PolicyConfig
        access(all) let usage: PolicyUsage

        init(config: PolicyConfig, usage: PolicyUsage) {
            self.config = config
            self.usage = usage
        }
    }

    access(all) struct VaultStats {
        access(all) let totalDeposits: UFix64
        access(all) let totalPremiums: UFix64
        access(all) let totalRefunds: UFix64
        access(all) let balance: UFix64

        init(
            totalDeposits: UFix64,
            totalPremiums: UFix64,
            totalRefunds: UFix64,
            balance: UFix64
        ) {
            self.totalDeposits = totalDeposits
            self.totalPremiums = totalPremiums
            self.totalRefunds = totalRefunds
            self.balance = balance
        }
    }

    access(all) struct ProtectionQuote {
        access(all) let expectedOut: UFix64
        access(all) let actualOut: UFix64
        access(all) let minOut: UFix64
        access(all) let premium: UFix64
        access(all) let refundRequested: UFix64
        access(all) let refundPaid: UFix64

        init(
            expectedOut: UFix64,
            actualOut: UFix64,
            minOut: UFix64,
            premium: UFix64,
            refundRequested: UFix64,
            refundPaid: UFix64
        ) {
            self.expectedOut = expectedOut
            self.actualOut = actualOut
            self.minOut = minOut
            self.premium = premium
            self.refundRequested = refundRequested
            self.refundPaid = refundPaid
        }
    }
}
