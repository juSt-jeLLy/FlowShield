// FlowShieldAdmin.cdc
// Global configuration and pause switch for FlowShield.

import "FlowShieldTypes"

access(all) contract FlowShieldAdmin {
    access(all) struct Config {
        access(all) let isPaused: Bool
        access(all) let maxRefundBps: UInt64
        access(all) let maxPremiumBps: UInt64

        init(isPaused: Bool, maxRefundBps: UInt64, maxPremiumBps: UInt64) {
            self.isPaused = isPaused
            self.maxRefundBps = maxRefundBps
            self.maxPremiumBps = maxPremiumBps
        }
    }

    access(all) var isPaused: Bool
    access(all) var maxRefundBps: UInt64
    access(all) var maxPremiumBps: UInt64

    init() {
        self.isPaused = false
        self.maxRefundBps = FlowShieldTypes.MaxBps
        self.maxPremiumBps = FlowShieldTypes.MaxBps
    }

    access(all) fun getConfig(): Config {
        return Config(
            isPaused: self.isPaused,
            maxRefundBps: self.maxRefundBps,
            maxPremiumBps: self.maxPremiumBps
        )
    }

    // NOTE: Admin setters are account-restricted for now. A future Admin resource
    // can be added to gate these calls via entitlement or capability.
    access(account) fun setPaused(_ value: Bool) {
        self.isPaused = value
    }

    access(account) fun setMaxRefundBps(_ value: UInt64) {
        pre { value <= FlowShieldTypes.MaxBps: "maxRefundBps must be <= 10_000" }
        self.maxRefundBps = value
    }

    access(account) fun setMaxPremiumBps(_ value: UInt64) {
        pre { value <= FlowShieldTypes.MaxBps: "maxPremiumBps must be <= 10_000" }
        self.maxPremiumBps = value
    }
}
