// GuardPolicy.cdc
// Stores per-user policy configuration and refund usage tracking.

import "FlowShieldTypes"

access(all) contract GuardPolicy {
    access(all) let StoragePath: StoragePath
    access(all) let PublicPath: PublicPath

    access(all) event PolicyCreated()
    access(all) event PolicyUpdated()
    access(all) event PolicyReset(epochStart: UFix64)

    access(all) resource interface PolicyPublic {
        access(all) fun getConfig(): FlowShieldTypes.PolicyConfig
        access(all) fun getUsage(): FlowShieldTypes.PolicyUsage
    }

    access(all) resource Policy: PolicyPublic {
        access(all) var config: FlowShieldTypes.PolicyConfig
        access(all) var epochStart: UFix64
        access(all) var usedThisEpoch: UFix64

        init(config: FlowShieldTypes.PolicyConfig, now: UFix64) {
            self.config = config
            self.epochStart = now
            self.usedThisEpoch = 0.0
        }

        access(all) fun getConfig(): FlowShieldTypes.PolicyConfig {
            return self.config
        }

        access(all) fun getUsage(): FlowShieldTypes.PolicyUsage {
            return FlowShieldTypes.PolicyUsage(
                epochStart: self.epochStart,
                usedThisEpoch: self.usedThisEpoch
            )
        }

        access(all) fun updateConfig(_ config: FlowShieldTypes.PolicyConfig) {
            self.config = config
            emit PolicyUpdated()
        }

        access(all) fun refreshEpoch(now: UFix64) {
            if now >= self.epochStart + self.config.epochSeconds {
                self.epochStart = now
                self.usedThisEpoch = 0.0
                emit PolicyReset(epochStart: now)
            }
        }

        access(all) fun availableRefund(now: UFix64): UFix64 {
            self.refreshEpoch(now: now)
            if self.usedThisEpoch >= self.config.maxRefundPerEpoch {
                return 0.0
            }
            return self.config.maxRefundPerEpoch - self.usedThisEpoch
        }

        access(all) fun allowedRefund(requested: UFix64, now: UFix64): UFix64 {
            if requested <= 0.0 {
                return 0.0
            }
            let remaining = self.availableRefund(now: now)
            var allowed = requested
            if allowed > self.config.maxRefundPerSwap {
                allowed = self.config.maxRefundPerSwap
            }
            if allowed > remaining {
                allowed = remaining
            }
            if allowed < 0.0 {
                allowed = 0.0
            }
            return allowed
        }

        access(all) fun recordRefund(amount: UFix64, now: UFix64) {
            if amount <= 0.0 {
                return
            }
            self.refreshEpoch(now: now)
            self.usedThisEpoch = self.usedThisEpoch + amount
        }
    }

    init() {
        self.StoragePath = /storage/FlowShieldPolicy
        self.PublicPath = /public/FlowShieldPolicy
    }

    access(all) fun createDefaultConfig(): FlowShieldTypes.PolicyConfig {
        return FlowShieldTypes.PolicyConfig(
            enabled: false,
            maxSlippageBps: 50,
            maxRefundPerSwap: 5.0,
            maxRefundPerEpoch: 50.0,
            epochSeconds: FlowShieldTypes.DefaultEpochSeconds,
            premiumBps: 30
        )
    }

    access(all) fun createPolicy(config: FlowShieldTypes.PolicyConfig): @Policy {
        emit PolicyCreated()
        return <-create Policy(config: config, now: getCurrentBlock().timestamp)
    }
}
