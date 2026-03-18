import { FlowHeader } from "@/components/flow-header";
import { FlowContent } from "@/components/flow-content";

export default function Home() {
  return (
    <div className="min-h-screen bg-[radial-gradient(circle_at_top,_#f5f7ff_0%,_#fef6e4_45%,_#ffffff_100%)] relative overflow-hidden">
      <div className="absolute inset-0 pointer-events-none">
        <div className="absolute top-[-120px] right-[-120px] h-80 w-80 rounded-full bg-emerald-300/40 blur-3xl" />
        <div className="absolute bottom-[-160px] left-[-160px] h-96 w-96 rounded-full bg-orange-200/60 blur-3xl" />
        <div className="absolute top-[20%] left-[10%] h-56 w-56 rounded-full bg-cyan-200/50 blur-2xl" />
        <div className="absolute bottom-[20%] right-[15%] h-72 w-72 rounded-full bg-blue-200/50 blur-3xl" />
      </div>

      <div className="relative z-10">
        <FlowHeader />
        <FlowContent />
      </div>
    </div>
  );
}
