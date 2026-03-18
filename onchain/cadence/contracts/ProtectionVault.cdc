// ProtectionVault.cdc
// Pooled slippage-refund vault with simple premium and refund accounting.

import "FungibleToken"
import "FlowShieldTypes"

access(all) contract ProtectionVault {
    access(all) event VaultDeposit(tokenId: String, amount: UFix64, kind: String)
    access(all) event RefundPaid(tokenId: String, amount: UFix64)
    access(all) event TreasuryWithdrawn(tokenId: String, amount: UFix64)

    access(all) let AdminStoragePath: StoragePath

    // Resource dictionary of token vaults (one per token type)
    access(account) var vaults: @{String: {FungibleToken.Vault}}

    // Non-resource accounting maps to avoid borrowing resource references
    access(all) var balances: {String: UFix64}
    access(all) var totalDeposits: {String: UFix64}
    access(all) var totalPremiums: {String: UFix64}
    access(all) var totalRefunds: {String: UFix64}

    // Admin resource for treasury withdrawals.
    access(all) resource interface AdminPublic {
        access(all) fun withdrawTreasury(tokenId: String, amount: UFix64): @{FungibleToken.Vault}?
    }

    access(all) resource Admin: AdminPublic {
        access(all) fun withdrawTreasury(tokenId: String, amount: UFix64): @{FungibleToken.Vault}? {
            return <-ProtectionVault.withdrawTreasury(tokenId: tokenId, amount: amount)
        }
    }

    // NOTE: For MVP we allow admin creation so the deployer can bootstrap a
    // treasury admin in their own storage. Production should gate this via
    // entitlements or a dedicated admin capability.
    access(all) fun createAdmin(): @Admin {
        return <-create Admin()
    }

    init() {
        self.AdminStoragePath = /storage/FlowShieldVaultAdmin
        self.vaults <- {}
        self.balances = {}
        self.totalDeposits = {}
        self.totalPremiums = {}
        self.totalRefunds = {}

        self.account.storage.save(<-create Admin(), to: self.AdminStoragePath)
    }

    access(all) fun depositUnderwriter(vault: @{FungibleToken.Vault}) {
        self.depositInternal(vault: <-vault, kind: "underwriter")
    }

    access(all) fun depositPremium(vault: @{FungibleToken.Vault}) {
        self.depositInternal(vault: <-vault, kind: "premium")
    }

    access(all) fun getBalance(tokenId: String): UFix64 {
        return self.balances[tokenId] ?? 0.0
    }

    access(all) fun getStats(tokenId: String): FlowShieldTypes.VaultStats {
        return FlowShieldTypes.VaultStats(
            totalDeposits: self.totalDeposits[tokenId] ?? 0.0,
            totalPremiums: self.totalPremiums[tokenId] ?? 0.0,
            totalRefunds: self.totalRefunds[tokenId] ?? 0.0,
            balance: self.balances[tokenId] ?? 0.0
        )
    }

    access(all) fun hasPool(tokenId: String): Bool {
        return self.vaults.containsKey(tokenId)
    }

    access(account) fun withdrawRefund(tokenId: String, amount: UFix64): @{FungibleToken.Vault}? {
        if amount <= 0.0 {
            return nil
        }
        let current = self.balances[tokenId] ?? 0.0
        if current <= 0.0 {
            return nil
        }
        let payoutAmount = amount <= current ? amount : current
        let pool <- self.vaults.remove(key: tokenId) ?? panic("Missing pool for token")
        let payout <- pool.withdraw(amount: payoutAmount)
        self.vaults[tokenId] <-! pool

        self.balances[tokenId] = current - payoutAmount
        self.totalRefunds[tokenId] = (self.totalRefunds[tokenId] ?? 0.0) + payoutAmount
        emit RefundPaid(tokenId: tokenId, amount: payoutAmount)
        return <-payout
    }

    access(account) fun withdrawTreasury(tokenId: String, amount: UFix64): @{FungibleToken.Vault}? {
        if amount <= 0.0 {
            return nil
        }
        let current = self.balances[tokenId] ?? 0.0
        if current <= 0.0 {
            return nil
        }
        let payoutAmount = amount <= current ? amount : current
        let pool <- self.vaults.remove(key: tokenId) ?? panic("Missing pool for token")
        let payout <- pool.withdraw(amount: payoutAmount)
        self.vaults[tokenId] <-! pool

        self.balances[tokenId] = current - payoutAmount
        emit TreasuryWithdrawn(tokenId: tokenId, amount: payoutAmount)
        return <-payout
    }

    access(self) fun depositInternal(vault: @{FungibleToken.Vault}, kind: String) {
        let amount = vault.balance
        if amount <= 0.0 {
            destroy vault
            return
        }

        let tokenId = vault.getType().identifier
        if !self.vaults.containsKey(tokenId) {
            self.vaults[tokenId] <-! vault
        } else {
            let existing <- self.vaults.remove(key: tokenId)
                ?? panic("Missing pool for token")
            existing.deposit(from: <-vault)
            self.vaults[tokenId] <-! existing
        }

        self.balances[tokenId] = (self.balances[tokenId] ?? 0.0) + amount

        if kind == "premium" {
            self.totalPremiums[tokenId] = (self.totalPremiums[tokenId] ?? 0.0) + amount
        } else {
            self.totalDeposits[tokenId] = (self.totalDeposits[tokenId] ?? 0.0) + amount
        }

        emit VaultDeposit(tokenId: tokenId, amount: amount, kind: kind)
    }
}
