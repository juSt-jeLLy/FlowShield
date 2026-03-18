import { SlipShieldCard } from "@/components/flowshield/SlipShieldCard";
import { ProtectionStatus } from "@/components/flowshield/ProtectionStatus";

export default function FlowShieldPage() {
  return (
    <div className="space-y-8">
      <SlipShieldCard />
      <ProtectionStatus />
    </div>
  );
}
