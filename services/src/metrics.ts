import { MetricsSnapshot } from "./types";

export class Metrics {
  private startedAt = new Date();
  private eventCounts: Record<string, number> = {};

  increment(eventType: string, by = 1) {
    this.eventCounts[eventType] =
      (this.eventCounts[eventType] ?? 0) + by;
  }

  snapshot(lastIndexedHeight: number): MetricsSnapshot {
    const uptimeSeconds = Math.floor(
      (Date.now() - this.startedAt.getTime()) / 1000
    );
    return {
      startedAt: this.startedAt.toISOString(),
      uptimeSeconds,
      lastIndexedHeight,
      eventCounts: this.eventCounts,
    };
  }
}
