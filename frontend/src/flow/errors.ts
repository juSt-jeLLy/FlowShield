const KNOWN_ERRORS: Record<string, string> = {
  "FlowShield is paused":
    "SlipShield is currently paused by the admin. Try again later.",
  "Bps must be <= 10_000": "Basis points must be <= 10,000.",
  "Amount must be > 0": "Amount must be greater than zero.",
  "Missing GuardPolicy in account storage":
    "No policy found. Save a SlipShield policy first.",
  "Missing or invalid receiver capability":
    "Missing receiver capability. Ensure the output vault is setup.",
  "No protection pool available for token":
    "The refund vault has no pool for this token yet.",
};

export function normalizeFlowError(error: unknown): string {
  if (!error) return "Unknown error";
  const message =
    typeof error === "string"
      ? error
      : (error as { message?: string }).message ?? String(error);

  for (const [needle, friendly] of Object.entries(KNOWN_ERRORS)) {
    if (message.includes(needle)) return friendly;
  }

  return message;
}
