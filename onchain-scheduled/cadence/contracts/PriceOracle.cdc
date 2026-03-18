import "BandOracle"
import "FlowToken"

// PriceOracle.cdc
// BandOracle adapter for price checks (FLOW/USDC default).
// Uses BandOracle.getReferenceData(baseSymbol, quoteSymbol, payment)

access(all) contract PriceOracle {
    access(all) let DefaultBaseSymbol: String
    access(all) let DefaultQuoteSymbol: String

    access(all) event OracleFeeDeposited(amount: UFix64, balance: UFix64)
    access(all) event OracleQuote(base: String, quote: String, rate: UFix64, baseTimestamp: UInt64, quoteTimestamp: UInt64)

    access(contract) var feeVault: @FlowToken.Vault

    access(all) struct PriceQuote {
        access(all) let rate: UFix64
        access(all) let baseTimestamp: UInt64
        access(all) let quoteTimestamp: UInt64

        init(rate: UFix64, baseTimestamp: UInt64, quoteTimestamp: UInt64) {
            self.rate = rate
            self.baseTimestamp = baseTimestamp
            self.quoteTimestamp = quoteTimestamp
        }
    }

    init() {
        self.DefaultBaseSymbol = "FLOW"
        self.DefaultQuoteSymbol = "USDC"
        self.feeVault <- FlowToken.createEmptyVault(vaultType: Type<@FlowToken.Vault>())
    }

    access(all) fun depositFees(from: @FlowToken.Vault) {
        let amount = from.balance
        self.feeVault.deposit(from: <-from)
        emit OracleFeeDeposited(amount: amount, balance: self.feeVault.balance)
    }

    access(all) view fun getFeeBalance(): UFix64 {
        return self.feeVault.balance
    }

    access(all) fun getBandReferenceData(baseSymbol: String, quoteSymbol: String): BandOracle.ReferenceData {
        pre {
            self.feeVault.balance >= BandOracle.getFee(): "Insufficient oracle fee balance"
        }
        let fee = BandOracle.getFee()
        let payment <- self.feeVault.withdraw(amount: fee)
        let ref = BandOracle.getReferenceData(baseSymbol: baseSymbol, quoteSymbol: quoteSymbol, payment: <- payment)
        emit OracleQuote(base: baseSymbol, quote: quoteSymbol, rate: ref.fixedPointRate, baseTimestamp: ref.baseTimestamp, quoteTimestamp: ref.quoteTimestamp)
        return ref
    }

    access(all) fun getPriceQuote(baseSymbol: String, quoteSymbol: String): PriceQuote {
        let ref = self.getBandReferenceData(baseSymbol: baseSymbol, quoteSymbol: quoteSymbol)
        return PriceQuote(rate: ref.fixedPointRate, baseTimestamp: ref.baseTimestamp, quoteTimestamp: ref.quoteTimestamp)
    }

    access(all) fun getDefaultPriceQuote(): PriceQuote {
        return self.getPriceQuote(baseSymbol: self.DefaultBaseSymbol, quoteSymbol: self.DefaultQuoteSymbol)
    }
}
