const milestones = [
  { name: "Konu Belirleme", status: "done" },
  { name: "Literatür Taraması", status: "done" },
  { name: "Araştırma Önerisi", status: "done" },
  { name: "Veri Toplama", status: "active" },
  { name: "Analiz & Bulgular", status: "upcoming" },
  { name: "Taslak Yazımı", status: "upcoming" },
  { name: "Revizyon", status: "upcoming" },
  { name: "Savunma", status: "upcoming" },
];

export default function MilestoneList() {
  const done = milestones.filter((m) => m.status === "done").length;
  const pct = Math.round((done / milestones.length) * 100);

  return (
    <div className="bg-[#151D2B] rounded-xl p-5 border border-[#1E293B]">
      <h3 className="text-sm font-bold text-slate-100 mb-4">Tez Yol Haritası</h3>
      <div className="flex flex-col gap-3">
        {milestones.map((m, i) => (
          <div key={i} className="flex items-center gap-3">
            <div
              className={`w-7 h-7 rounded-full flex items-center justify-center text-xs font-bold text-white shrink-0 ${
                m.status === "done"
                  ? "bg-emerald-500"
                  : m.status === "active"
                  ? "bg-blue-500 shadow-lg shadow-blue-500/30"
                  : "bg-slate-700"
              }`}
            >
              {m.status === "done" ? "✓" : i + 1}
            </div>
            <span
              className={`text-sm font-medium flex-1 ${
                m.status === "upcoming" ? "text-slate-500" : "text-slate-200"
              }`}
            >
              {m.name}
            </span>
            <span
              className={`text-[10px] font-semibold px-2 py-0.5 rounded ${
                m.status === "done"
                  ? "bg-emerald-500/10 text-emerald-400"
                  : m.status === "active"
                  ? "bg-blue-500/10 text-blue-400"
                  : "bg-slate-700/50 text-slate-500"
              }`}
            >
              {m.status === "done" ? "Tamamlandı" : m.status === "active" ? "Aktif" : "Bekliyor"}
            </span>
          </div>
        ))}
      </div>
      <div className="mt-4">
        <div className="flex justify-between mb-1">
          <span className="text-[11px] text-slate-500">Genel İlerleme</span>
          <span className="text-[11px] text-blue-400 font-bold">{pct}%</span>
        </div>
        <div className="w-full h-2 bg-[#1E293B] rounded-full overflow-hidden">
          <div
            className="h-full bg-blue-500 rounded-full transition-all duration-700"
            style={{ width: `${pct}%` }}
          />
        </div>
      </div>
    </div>
  );
}
