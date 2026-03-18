import "PriceOracle"

// get_oracle_fee_balance.cdc
// Read the available FLOW balance reserved for oracle fees.

access(all) fun main(): UFix64 {
    return PriceOracle.getFeeBalance()
}
