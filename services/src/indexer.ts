import * as fcl from "@onflow/fcl";
import * as t from "@onflow/types";
import { config } from "./config";
import { Storage } from "./storage";
import { Metrics } from "./metrics";
import {
  SlipShieldProtectedSwapEvent,
  SlipShieldPremiumPaidEvent,
  SlipShieldRefundPaidEvent,
  TreasuryWithdrawnEvent,
  VaultDepositEvent,
} from "./types";

const EVENT_TYPES = {
  protectedSwap: `A.${config.contractAddress}.ActionRouter.SlipShieldProtectedSwap`,
  premiumPaid: `A.${config.contractAddress}.ActionRouter.SlipShieldPremiumPaid`,
  refundPaid: `A.${config.contractAddress}.ActionRouter.SlipShieldRefundPaid`,
  vaultDeposit: `A.${config.contractAddress}.ProtectionVault.VaultDeposit`,
  treasuryWithdrawn: `A.${config.contractAddress}.ProtectionVault.TreasuryWithdrawn`,
};

const buildVaultStatsScript = (address: string) => `// get_vault_stats.cdc
import ProtectionVault from ${address}
import FlowShieldTypes from ${address}

access(all) fun main(tokenId: String): FlowShieldTypes.VaultStats {
  return ProtectionVault.getStats(tokenId: tokenId)
}
`;

const decodeBlocks = (blocks: any[]) =>
  blocks.flatMap((block) => {
    const events = block.events ?? block.event ?? [];
    return events.map((event: any) => ({
      blockHeight: Number(block.blockHeight ?? block.block_height ?? 0),
      blockTimestamp:
        block.blockTimestamp ?? block.block_timestamp ?? new Date().toISOString(),
      transactionId: event.transactionId ?? event.transaction_id ?? "",
      payload: event.payload ?? event.data ?? event,
    }));
  });

async function fetchEvents(eventType: string, startHeight: number, endHeight: number) {
  const response = await fcl.send([
    fcl.getEventsAtBlockHeightRange(eventType, startHeight, endHeight),
  ]);
  const decoded = (await fcl.decode(response)) as any[];
  if (!Array.isArray(decoded)) return [];
  return decodeBlocks(decoded);
}

async function fetchVaultStats(tokenId: string) {
  const response = await fcl.query({
    cadence: buildVaultStatsScript(config.contractAddressHex),
    args: (arg: any) => [arg(tokenId, t.String)],
  });
  return response as {
    totalDeposits: string;
    totalPremiums: string;
    totalRefunds: string;
    balance: string;
  };
}

export async function startIndexer(storage: Storage, metrics: Metrics) {
  fcl
    .config()
    .put("accessNode.api", config.accessNode)
    .put("flow.network", config.flowNetwork)
    .put("contracts.FlowShieldTypes", config.contractAddressHex)
    .put("contracts.ProtectionVault", config.contractAddressHex)
    .put("contracts.FlowShieldAdmin", config.contractAddressHex)
    .put("contracts.GuardPolicy", config.contractAddressHex)
    .put("contracts.ActionRouter", config.contractAddressHex);

  const poll = async () => {
    try {
      const blockResponse = await fcl.send([fcl.getBlock(true)]);
      const latestBlock = await fcl.decode(blockResponse);
      const latestHeight = Number(latestBlock.height ?? 0);
      const lastHeight = storage.getLastHeight();

      const startHeight = lastHeight > 0 ? lastHeight + 1 : latestHeight;
      if (startHeight > latestHeight) {
        return;
      }

      let current = startHeight;
      while (current <= latestHeight) {
        const endHeight = Math.min(
          latestHeight,
          current + config.indexerBatchSize - 1
        );

        const [swapEvents, premiumEvents, refundEvents, depositEvents, treasuryEvents] =
          await Promise.all([
            fetchEvents(EVENT_TYPES.protectedSwap, current, endHeight),
            fetchEvents(EVENT_TYPES.premiumPaid, current, endHeight),
            fetchEvents(EVENT_TYPES.refundPaid, current, endHeight),
            fetchEvents(EVENT_TYPES.vaultDeposit, current, endHeight),
            fetchEvents(EVENT_TYPES.treasuryWithdrawn, current, endHeight),
          ]);

        const swaps: SlipShieldProtectedSwapEvent[] = swapEvents.map((event) => ({
          tokenId: event.payload.tokenId,
          expectedOut: event.payload.expectedOut,
          actualOut: event.payload.actualOut,
          minOut: event.payload.minOut,
          premium: event.payload.premium,
          refundRequested: event.payload.refundRequested,
          refundPaid: event.payload.refundPaid,
          blockHeight: event.blockHeight,
          txId: event.transactionId,
          timestamp: event.blockTimestamp,
        }));

        const premiums: SlipShieldPremiumPaidEvent[] = premiumEvents.map((event) => ({
          tokenId: event.payload.tokenId,
          amount: event.payload.amount,
          blockHeight: event.blockHeight,
          txId: event.transactionId,
          timestamp: event.blockTimestamp,
        }));

        const refunds: SlipShieldRefundPaidEvent[] = refundEvents.map((event) => ({
          tokenId: event.payload.tokenId,
          amount: event.payload.amount,
          blockHeight: event.blockHeight,
          txId: event.transactionId,
          timestamp: event.blockTimestamp,
        }));

        const deposits: VaultDepositEvent[] = depositEvents.map((event) => ({
          tokenId: event.payload.tokenId,
          amount: event.payload.amount,
          kind: event.payload.kind,
          blockHeight: event.blockHeight,
          txId: event.transactionId,
          timestamp: event.blockTimestamp,
        }));

        const treasury: TreasuryWithdrawnEvent[] = treasuryEvents.map((event) => ({
          tokenId: event.payload.tokenId,
          amount: event.payload.amount,
          blockHeight: event.blockHeight,
          txId: event.transactionId,
          timestamp: event.blockTimestamp,
        }));

        if (swaps.length) {
          storage.addSwaps(swaps);
          metrics.increment("SlipShieldProtectedSwap", swaps.length);
        }
        if (premiums.length) {
          storage.addPremiums(premiums);
          metrics.increment("SlipShieldPremiumPaid", premiums.length);
        }
        if (refunds.length) {
          storage.addRefunds(refunds);
          metrics.increment("SlipShieldRefundPaid", refunds.length);
        }
        if (deposits.length) {
          storage.addDeposits(deposits);
          metrics.increment("VaultDeposit", deposits.length);
        }
        if (treasury.length) {
          storage.addTreasury(treasury);
          metrics.increment("TreasuryWithdrawn", treasury.length);
        }

        storage.setLastHeight(endHeight);
        current = endHeight + 1;
      }

      const vaultStats = await fetchVaultStats(config.tokenId);
      storage.setVaultStats(config.tokenId, vaultStats);
    } catch (error) {
      console.error("[indexer] poll failed", error);
    }
  };

  await poll();
  setInterval(poll, config.indexerPollIntervalMs);
}
