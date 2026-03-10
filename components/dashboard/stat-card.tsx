interface StatCardProps {
  label: string;
  value: string;
  sub: string;
  icon: string;
}

export default function StatCard({ label, value, sub, icon }: StatCardProps) {
  return (
    <div className="flex-1 min-w-[160px] bg-[#151D2B] rounded-xl p-5 border border-[#1E293B] relative overflow-hidden">
      <div className="flex items-center justify-between mb-2">
        <span className="text-xs text-slate-500 font-medium">{label}</span>
        <span className="text-xl">{icon}</span>
      </div>
      <div className="text-2xl font-extrabold text-slate-100 tracking-tight">{value}</div>
      <div className="text-xs text-slate-500 mt-1">{sub}</div>
    </div>
  );
}
