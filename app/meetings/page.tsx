const meetings = [
  { date: "24", month: "Şub", topic: "Pilot çalışma sonuçları değerlendirmesi", time: "14:00", type: "Video", status: "Planlandı" },
  { date: "03", month: "Mar", topic: "3. Bölüm taslak inceleme", time: "10:30", type: "Yüz yüze", status: "Planlandı" },
  { date: "17", month: "Şub", topic: "Kavramsal çerçeve tartışması", time: "15:00", type: "Video", status: "Tamamlandı" },
  { date: "10", month: "Şub", topic: "1. Bölüm final inceleme", time: "11:00", type: "Yüz yüze", status: "Tamamlandı" },
];

export default function MeetingsPage() {
  return (
    <div>
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-xl font-bold text-slate-100">Toplantılar</h1>
        <button className="px-4 py-2 bg-blue-500 text-white text-sm font-semibold rounded-lg hover:bg-blue-600 transition-colors">
          + Yeni Toplantı
        </button>
      </div>
      <div className="flex flex-col gap-3">
        {meetings.map((m, i) => (
          <div
            key={i}
            className={`flex items-center gap-4 p-4 rounded-xl bg-[#151D2B] border ${
              m.status === "Planlandı" ? "border-blue-500/30" : "border-[#1E293B]"
            }`}
          >
            <div
              className={`w-14 h-14 rounded-xl flex flex-col items-center justify-center shrink-0 ${
                m.status === "Planlandı" ? "bg-blue-500/10" : "bg-[#111827]"
              }`}
            >
              <span className={`text-lg font-extrabold ${m.status === "Planlandı" ? "text-blue-400" : "text-slate-500"}`}>
                {m.date}
              </span>
              <span className="text-[10px] text-slate-500 font-semibold">{m.month}</span>
            </div>
            <div className="flex-1">
              <div className="text-sm font-semibold text-slate-200">{m.topic}</div>
              <div className="text-xs text-slate-500 mt-1 flex gap-3">
                <span>🕐 {m.time}</span>
                <span>{m.type === "Video" ? "📹" : "🏢"} {m.type}</span>
              </div>
            </div>
            <span
              className={`text-[10px] font-semibold px-2.5 py-1 rounded ${
                m.status === "Planlandı"
                  ? "bg-blue-500/10 text-blue-400"
                  : "bg-emerald-500/10 text-emerald-400"
              }`}
            >
              {m.status}
            </span>
          </div>
        ))}
      </div>
    </div>
  );
}
