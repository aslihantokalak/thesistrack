import { db } from "@/lib/db";

const statusConfig: Record<string, { title: string; color: string }> = {
  BACKLOG: { title: "Backlog", color: "bg-slate-500" },
  TODO: { title: "Yapılacak", color: "bg-blue-500" },
  IN_PROGRESS: { title: "Devam Ediyor", color: "bg-amber-500" },
  IN_REVIEW: { title: "İnceleme Bekliyor", color: "bg-violet-500" },
  DONE: { title: "Tamamlandı", color: "bg-emerald-500" },
};

const priorityConfig: Record<string, { label: string; style: string }> = {
  HIGH: { label: "Yüksek", style: "bg-red-500/10 text-red-400" },
  URGENT: { label: "Acil", style: "bg-red-500/15 text-red-500" },
  MEDIUM: { label: "Orta", style: "bg-amber-500/10 text-amber-400" },
  LOW: { label: "Düşük", style: "bg-emerald-500/10 text-emerald-400" },
};

export default async function KanbanPage() {
  let tasks: any[] = [];
  try {
    tasks = await db.task.findMany({
      include: { assignee: true },
      orderBy: { createdAt: "asc" },
    });
  } catch {}

  const columns = Object.entries(statusConfig).map(([status, config]) => ({
    ...config,
    status,
    tasks: tasks.filter((t) => t.status === status),
  }));

  return (
    <div>
      <h1 className="text-xl font-bold text-slate-100 mb-6">Kanban Board</h1>
      {tasks.length === 0 ? (
        <p className="text-slate-500">Henüz görev yok. Dashboard'dan test verilerini yükleyin.</p>
      ) : (
        <div className="flex gap-4 overflow-x-auto pb-4">
          {columns.map((col) => (
            <div key={col.status} className="min-w-[230px] flex-1">
              <div className="flex items-center gap-2 mb-3 px-3 py-2 bg-[#151D2B] rounded-lg border border-[#1E293B]">
                <div className={`w-2 h-2 rounded-full ${col.color}`} />
                <span className="text-sm font-bold text-slate-200">{col.title}</span>
                <span className="ml-auto text-[11px] font-bold text-slate-500 bg-[#111827] px-2 py-0.5 rounded">
                  {col.tasks.length}
                </span>
              </div>
              <div className="flex flex-col gap-2">
                {col.tasks.map((task: any) => {
                  const prio = priorityConfig[task.priority] || priorityConfig.MEDIUM;
                  return (
                    <div
                      key={task.id}
                      className="p-3 bg-[#151D2B] rounded-lg border border-[#1E293B] hover:border-blue-500/50 transition-colors cursor-pointer"
                    >
                      <div className="text-sm font-medium text-slate-200 mb-2">{task.title}</div>
                      <div className="flex items-center justify-between">
                        <span className={`text-[10px] font-semibold px-2 py-0.5 rounded ${prio.style}`}>
                          {prio.label}
                        </span>
                        {task.assignee && (
                          <div className="w-6 h-6 rounded-full bg-violet-600 flex items-center justify-center text-white text-[10px] font-bold">
                            {task.assignee.firstName[0]}
                          </div>
                        )}
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
