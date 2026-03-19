// transactions.ts
// Minimal helpers for FlowShield transactions.

import type {
  FundVaultInput,
  PolicyConfigInput,
  ProtectedSwapInput,
  ProfitDripInput,
} from "./types";

export const SET_POLICY_CADENCE = `// set_policy.cdc
import "GuardPolicy"
import "FlowShieldTypes"

transaction(
    enabled: Bool,
    maxSlippageBps: UInt64,
    maxRefundPerSwap: UFix64,
    maxRefundPerEpoch: UFix64,
    epochSeconds: UFix64,
    premiumBps: UInt64
) {
    prepare(acct: auth(BorrowValue, SaveValue) &Account) {
        let config = FlowShieldTypes.PolicyConfig(
            enabled: enabled,
            maxSlippageBps: maxSlippageBps,
            maxRefundPerSwap: maxRefundPerSwap,
            maxRefundPerEpoch: maxRefundPerEpoch,
            epochSeconds: epochSeconds,
            premiumBps: premiumBps
        )

        let existing = acct.storage.borrow<&GuardPolicy.Policy>(from: GuardPolicy.StoragePath)
        if existing == nil {
            acct.storage.save(<-GuardPolicy.createPolicy(config: config), to: GuardPolicy.StoragePath)
        } else {
            existing!.updateConfig(config)
        }
    }
}
`;

export const FUND_VAULT_CADENCE = `// fund_vault.cdc
import "FungibleToken"
import "ProtectionVault"

transaction(amount: UFix64, fromVaultPath: StoragePath) {
    prepare(acct: auth(BorrowValue) &Account) {
        let provider = acct.storage.borrow<auth(FungibleToken.Withdraw) &{FungibleToken.Provider}>(from: fromVaultPath)
            ?? panic("Missing vault at provided storage path")
        let payment <- provider.withdraw(amount: amount)
        ProtectionVault.depositUnderwriter(vault: <-payment)
    }
}
`;

export const PROTECTED_SWAP_CADENCE = `// protected_swap.cdc
import "FungibleToken"
import "GuardPolicy"
import "IncrementFiAdapter"

transaction(
    amountIn: UFix64,
    expectedOut: UFix64,
    minOut: UFix64,
    inVaultType: Type,
    outVaultType: Type,
    inVaultPath: StoragePath,
    outReceiverPath: PublicPath
) {
    prepare(acct: auth(BorrowValue, Capabilities) &Account) {
        let provider = acct.storage.borrow<auth(FungibleToken.Withdraw) &{FungibleToken.Provider}>(from: inVaultPath)
            ?? panic("Missing input vault at provided storage path")

        let payment <- provider.withdraw(amount: amountIn)

        let policyRef = acct.storage.borrow<&GuardPolicy.Policy>(from: GuardPolicy.StoragePath)
            ?? panic("Missing GuardPolicy. Run setup_user.cdc first.")

        let receiverCap = acct.capabilities.get<&{FungibleToken.Receiver}>(outReceiverPath)
        IncrementFiAdapter.executeProtectedSwap(
            input: <-payment,
            expectedOut: expectedOut,
            minOut: minOut,
            inVaultType: inVaultType,
            outVaultType: outVaultType,
            policy: policyRef,
            userReceiver: receiverCap
        )
    }
}
`;

export const SETUP_STFLOW_VAULT_CADENCE = `// setup_stflow_vault.cdc
import "FungibleToken"
import "stFlowToken"

transaction {
    prepare(acct: auth(BorrowValue, SaveValue, Capabilities) &Account) {
        if acct.storage.borrow<&stFlowToken.Vault>(from: stFlowToken.VaultStoragePath) == nil {
            acct.storage.save(<-stFlowToken.createEmptyVault(), to: stFlowToken.VaultStoragePath)
        }

        let receiver = acct.capabilities.get<&{FungibleToken.Receiver}>(stFlowToken.VaultReceiverPublicPath)
        if !receiver.check() {
            let issuedCap = acct.capabilities.storage.issue<&{FungibleToken.Receiver}>(stFlowToken.VaultStoragePath)
            acct.capabilities.publish(issuedCap, at: stFlowToken.VaultReceiverPublicPath)
        }
    }
}
`;

export const PROFIT_DRIP_CADENCE = `// profit_drip.cdc
import "FungibleToken"
import "ProtectionVault"

transaction(tokenId: String, amount: UFix64, receiverPath: PublicPath) {
    prepare(acct: auth(BorrowValue, SaveValue, Capabilities) &Account) {
        pre {
            amount > 0.0: "amount must be > 0"
        }

        let receiver = acct.capabilities.get<&{FungibleToken.Receiver}>(receiverPath)
        if !receiver.check() {
            panic("Missing or invalid receiver capability")
        }

        if acct.storage.borrow<&ProtectionVault.Admin>(from: ProtectionVault.AdminStoragePath) == nil {
            acct.storage.save(<-ProtectionVault.createAdmin(), to: ProtectionVault.AdminStoragePath)
        }

        let adminRef = acct.storage.borrow<&ProtectionVault.Admin>(from: ProtectionVault.AdminStoragePath)
            ?? panic("Missing ProtectionVault admin resource")

        let payout <- adminRef.withdrawTreasury(tokenId: tokenId, amount: amount)
        if let vault <- payout {
            receiver.borrow()!.deposit(from: <-vault)
        }
    }
}
`;

export function buildSetPolicyArgs(config: PolicyConfigInput) {
  return [
    config.enabled,
    config.maxSlippageBps,
    config.maxRefundPerSwap,
    config.maxRefundPerEpoch,
    config.epochSeconds,
    config.premiumBps,
  ] as const;
}

export function buildFundVaultArgs(input: FundVaultInput) {
  return [input.amount, input.fromVaultPath] as const;
}

export function buildProtectedSwapArgs(input: ProtectedSwapInput) {
  return [
    input.amountIn,
    input.expectedOut,
    input.minOut,
    input.inVaultType,
    input.outVaultType,
    input.inVaultPath,
    input.outReceiverPath,
  ] as const;
}

export function buildSetupStFlowVaultArgs() {
  return [] as const;
}

export function buildProfitDripArgs(input: ProfitDripInput) {
  return [input.tokenId, input.amount, input.receiverPath] as const;
}
