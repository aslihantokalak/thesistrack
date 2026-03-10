import { db } from "@/lib/db";

export default async function MeetingsPage() {
  let meetings: any[] = [];
  try {
    meetings = await db.meeting.findMany({ orderBy: { date: "desc" } });
  } catch {}

  return (
    <div>
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-xl font-bold text-slate-100">Toplantılar</h1>
      </div>
      {meetings.length === 0 ? (
        <p className="text-slate-500">Henüz toplantı yok. Dashboard'dan test verilerini yükleyin.</p>
      ) : (
        <div className="flex flex-col gap-3">
          {meetings.map((m: any) => {
            const d = new Date(m.date);
            const months = ["Oca","Şub","Mar","Nis","May","Haz","Tem","Ağu","Eyl","Eki","Kas","Ara"];
            return (
              <div
                key={m.id}
                className={`flex items-center gap-4 p-4 rounded-xl bg-[#151D2B] border ${
                  m.status === "SCHEDULED" ? "border-blue-500/30" : "border-[#1E293B]"
                }`}
              >
                <div
                  className={`w-14 h-14 rounded-xl flex flex-col items-center justify-center shrink-0 ${
                    m.status === "SCHEDULED" ? "bg-blue-500/10" : "bg-[#111827]"
                  }`}
                >
                  <span className={`text-lg font-extrabold ${m.status === "SCHEDULED" ? "text-blue-400" : "text-slate-500"}`}>
                    {d.getDate()}
                  </span>
                  <span className="text-[10px] text-slate-500 font-semibold">{months[d.getMonth()]}</span>
                </div>
                <div className="flex-1">
                  <div className="text-sm font-semibold text-slate-200">{m.topic}</div>
                  <div className="text-xs text-slate-500 mt-1 flex gap-3">
                    <span>🕐 {d.toLocaleTimeString("tr-TR", { hour: "2-digit", minute: "2-digit" })}</span>
                    <span>{m.type === "VIDEO" ? "📹 Video" : "🏢 Yüz yüze"}</span>
                  </div>
                  {m.notes && <div className="text-[11px] text-slate-400 mt-1 italic">Not: {m.notes}</div>}
                </div>
                <span
                  className={`text-[10px] font-semibold px-2.5 py-1 rounded ${
                    m.status === "SCHEDULED"
                      ? "bg-blue-500/10 text-blue-400"
                      : "bg-emerald-500/10 text-emerald-400"
                  }`}
                >
                  {m.status === "SCHEDULED" ? "Planlandı" : "Tamamlandı"}
                </span>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}
