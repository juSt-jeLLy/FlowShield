// FlowShieldErrors.cdc
// Shared error messages for FlowShield.

access(all) contract FlowShieldErrors {
    access(all) let ErrPaused: String
    access(all) let ErrInvalidBps: String
    access(all) let ErrInvalidAmount: String
    access(all) let ErrMissingPolicy: String
    access(all) let ErrInvalidReceiver: String
    access(all) let ErrMissingPool: String

    init() {
        self.ErrPaused = "FlowShield is paused"
        self.ErrInvalidBps = "Bps must be <= 10_000"
        self.ErrInvalidAmount = "Amount must be > 0"
        self.ErrMissingPolicy = "Missing GuardPolicy in account storage"
        self.ErrInvalidReceiver = "Missing or invalid receiver capability"
        self.ErrMissingPool = "No protection pool available for token"
    }
}
