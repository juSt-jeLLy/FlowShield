import "FlowToken"
import "FungibleToken"
import "PriceOracle"

// fund_oracle_fee_vault.cdc
// Deposit FLOW tokens into the oracle fee vault used by BandOracle queries.

transaction(amount: UFix64) {
    prepare(signer: auth(Storage, FungibleToken.Withdraw) &Account) {
        let vaultRef = signer.storage.borrow<auth(FungibleToken.Withdraw) &FlowToken.Vault>(from: /storage/flowTokenVault)
            ?? panic("Missing FlowToken vault")
        let payment <- vaultRef.withdraw(amount: amount) as! @FlowToken.Vault
        PriceOracle.depositFees(from: <- payment)
    }
}
