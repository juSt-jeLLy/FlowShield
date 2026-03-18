import {
  SlipShieldProtectedSwapEvent,
  SlipShieldPremiumPaidEvent,
  SlipShieldRefundPaidEvent,
  TreasuryWithdrawnEvent,
  VaultDepositEvent,
  VaultStats,
} from "./types";

const MAX_EVENTS = 200;

export class Storage {
  private lastHeight = 0;
  private swaps: SlipShieldProtectedSwapEvent[] = [];
  private premiums: SlipShieldPremiumPaidEvent[] = [];
  private refunds: SlipShieldRefundPaidEvent[] = [];
  private deposits: VaultDepositEvent[] = [];
  private treasury: TreasuryWithdrawnEvent[] = [];
  private vaultStats: Record<string, VaultStats> = {};

  getLastHeight() {
    return this.lastHeight;
  }

  setLastHeight(height: number) {
    this.lastHeight = height;
  }

  setVaultStats(tokenId: string, stats: VaultStats) {
    this.vaultStats[tokenId] = stats;
  }

  getVaultStats(tokenId: string) {
    return this.vaultStats[tokenId];
  }

  addSwaps(events: SlipShieldProtectedSwapEvent[]) {
    this.swaps = [...events, ...this.swaps].slice(0, MAX_EVENTS);
  }

  addPremiums(events: SlipShieldPremiumPaidEvent[]) {
    this.premiums = [...events, ...this.premiums].slice(0, MAX_EVENTS);
  }

  addRefunds(events: SlipShieldRefundPaidEvent[]) {
    this.refunds = [...events, ...this.refunds].slice(0, MAX_EVENTS);
  }

  addDeposits(events: VaultDepositEvent[]) {
    this.deposits = [...events, ...this.deposits].slice(0, MAX_EVENTS);
  }

  addTreasury(events: TreasuryWithdrawnEvent[]) {
    this.treasury = [...events, ...this.treasury].slice(0, MAX_EVENTS);
  }

  getRecentEvents() {
    return {
      swaps: this.swaps,
      premiums: this.premiums,
      refunds: this.refunds,
      deposits: this.deposits,
      treasury: this.treasury,
    };
  }
}
