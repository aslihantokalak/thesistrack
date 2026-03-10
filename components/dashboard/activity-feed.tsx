const activities = [
  { icon: "📄", action: "Dosya yüklendi", detail: "pilot_sonuclari_v2.xlsx", time: "2 saat önce" },
  { icon: "✅", action: "Görev tamamlandı", detail: "Kaynak listesi güncellendi", time: "5 saat önce" },
  { icon: "💬", action: "Yorum eklendi", detail: "2. Bölüm taslağına 3 yorum", time: "Dün" },
  { icon: "📅", action: "Toplantı tamamlandı", detail: "Kavramsal çerçeve tartışması", time: "17 Şub" },
  { icon: "🎯", action: "Milestone geçildi", detail: "Araştırma Önerisi onaylandı", time: "20 Ara" },
];

export default function ActivityFeed() {
  return (
    <div className="bg-[#151D2B] rounded-xl p-5 border border-[#1E293B]">
      <h3 className="text-sm font-bold text-slate-100 mb-4">Aktivite Akışı</h3>
      <div className="flex flex-col gap-3">
        {activities.map((a, i) => (
          <div key={i} className="flex gap-3 items-start">
            <span className="text-base shrink-0 mt-0.5">{a.icon}</span>
            <div className="flex-1 min-w-0">
              <div className="text-xs font-semibold text-slate-200">{a.action}</div>
              <div className="text-[11px] text-slate-500 truncate">{a.detail}</div>
            </div>
            <span className="text-[10px] text-slate-500 whitespace-nowrap">{a.time}</span>
          </div>
        ))}
      </div>
    </div>
  );
}
