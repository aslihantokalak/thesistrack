import StatCard from "@/components/dashboard/stat-card";
import MilestoneList from "@/components/dashboard/milestone-list";
import ActivityFeed from "@/components/dashboard/activity-feed";

export default function DashboardPage() {
  return (
    <div className="max-w-6xl mx-auto">
      {/* Header */}
      <div className="mb-6">
        <div className="flex items-center gap-3 mb-1">
          <h1 className="text-xl font-bold text-slate-100">ThesisTrack</h1>
          <span className="text-[10px] font-bold px-2 py-0.5 rounded bg-blue-500/10 text-blue-400">
            Beta
          </span>
        </div>
        <p className="text-sm text-slate-500">
          Yapay Zekâ Destekli Öğretim Yöntemlerinin Akademik Başarıya Etkisi
        </p>
      </div>

      {/* Stat Cards */}
      <div className="flex gap-4 flex-wrap mb-6">
        <StatCard label="İlerleme" value="38%" sub="3/8 milestone" icon="📊" />
        <StatCard label="Aktif Görevler" value="7" sub="2 tamamlandı" icon="📋" />
        <StatCard label="Sonraki Toplantı" value="24 Şub" sub="Pazartesi, 14:00" icon="📅" />
        <StatCard label="Son İletişim" value="2 saat" sub="önce mesaj alındı" icon="💬" />
      </div>

      {/* Main Content */}
      <div className="flex gap-4 flex-wrap">
        <div className="flex-[2] min-w-[400px]">
          <MilestoneList />
        </div>
        <div className="flex-1 min-w-[280px]">
          <ActivityFeed />
        </div>
      </div>
    </div>
  );
}
