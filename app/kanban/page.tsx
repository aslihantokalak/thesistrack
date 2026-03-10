const columns = [
  {
    title: "Backlog",
    color: "bg-slate-500",
    tasks: [
      { title: "Anket sorularını revize et", priority: "Orta" },
      { title: "İstatistik yöntem karşılaştırması", priority: "Düşük" },
    ],
  },
  {
    title: "Yapılacak",
    color: "bg-blue-500",
    tasks: [
      { title: "Katılımcı grubunu belirle", priority: "Yüksek" },
      { title: "Etik kurul başvurusu", priority: "Yüksek" },
    ],
  },
  {
    title: "Devam Ediyor",
    color: "bg-amber-500",
    tasks: [
      { title: "Pilot çalışma yürütülüyor", priority: "Yüksek" },
      { title: "3. Bölüm taslağı yazımı", priority: "Orta" },
    ],
  },
  {
    title: "İnceleme Bekliyor",
    color: "bg-violet-500",
    tasks: [{ title: "2. Bölüm - Kavramsal Çerçeve", priority: "Orta" }],
  },
  {
    title: "Tamamlandı",
    color: "bg-emerald-500",
    tasks: [
      { title: "1. Bölüm - Giriş onaylandı", priority: "Düşük" },
      { title: "Kaynak listesi güncellendi", priority: "Düşük" },
    ],
  },
];

export default function KanbanPage() {
  return (
    <div>
      <h1 className="text-xl font-bold text-slate-100 mb-6">Kanban Board</h1>
      <div className="flex gap-4 overflow-x-auto pb-4">
        {columns.map((col) => (
          <div key={col.title} className="min-w-[230px] flex-1">
            <div className="flex items-center gap-2 mb-3 px-3 py-2 bg-[#151D2B] rounded-lg border border-[#1E293B]">
              <div className={`w-2 h-2 rounded-full ${col.color}`} />
              <span className="text-sm font-bold text-slate-200">{col.title}</span>
              <span className="ml-auto text-[11px] font-bold text-slate-500 bg-[#111827] px-2 py-0.5 rounded">
                {col.tasks.length}
              </span>
            </div>
            <div className="flex flex-col gap-2">
              {col.tasks.map((task, i) => (
                <div
                  key={i}
                  className="p-3 bg-[#151D2B] rounded-lg border border-[#1E293B] hover:border-blue-500/50 transition-colors cursor-pointer"
                >
                  <div className="text-sm font-medium text-slate-200 mb-2">{task.title}</div>
                  <span
                    className={`text-[10px] font-semibold px-2 py-0.5 rounded ${
                      task.priority === "Yüksek"
                        ? "bg-red-500/10 text-red-400"
                        : task.priority === "Orta"
                        ? "bg-amber-500/10 text-amber-400"
                        : "bg-emerald-500/10 text-emerald-400"
                    }`}
                  >
                    {task.priority}
                  </span>
                </div>
              ))}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
