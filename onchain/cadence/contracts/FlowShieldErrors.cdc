// FlowShieldErrors.cdc
// Shared error messages for FlowShield.

access(all) contract FlowShieldErrors {
    access(all) let ErrPaused: String = "FlowShield is paused"
    access(all) let ErrInvalidBps: String = "Bps must be <= 10_000"
    access(all) let ErrInvalidAmount: String = "Amount must be > 0"
    access(all) let ErrMissingPolicy: String = "Missing GuardPolicy in account storage"
    access(all) let ErrInvalidReceiver: String = "Missing or invalid receiver capability"
    access(all) let ErrMissingPool: String = "No protection pool available for token"
}
