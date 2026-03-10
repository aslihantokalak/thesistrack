import { db } from "@/lib/db";
import StatCard from "@/components/dashboard/stat-card";
import MilestoneList from "@/components/dashboard/milestone-list";
import ActivityFeed from "@/components/dashboard/activity-feed";
import SeedButton from "@/components/dashboard/seed-button";

async function getDashboardData() {
  try {
    const milestones = await db.milestone.findMany({ orderBy: { orderNum: "asc" } });
    const tasks = await db.task.findMany();
    const meetings = await db.meeting.findMany({ orderBy: { date: "desc" }, take: 1 });
    const messages = await db.message.findMany({ orderBy: { createdAt: "desc" }, take: 1 });
    const thesis = await db.thesis.findFirst();

    const doneMilestones = milestones.filter((m) => m.status === "COMPLETED").length;
    const doneTasks = tasks.filter((t) => t.status === "DONE").length;
    const activeTasks = tasks.length - doneTasks;

    return { milestones, tasks, meetings, messages, thesis, doneMilestones, doneTasks, activeTasks };
  } catch {
    return null;
  }
}

export default async function DashboardPage() {
  const data = await getDashboardData();

  if (!data || !data.thesis) {
    return (
      <div className="max-w-2xl mx-auto mt-20 text-center">
        <h1 className="text-2xl font-bold text-slate-100 mb-4">ThesisTrack</h1>
        <p className="text-slate-400 mb-6">
          Veritabanında henüz veri yok. Test verilerini yüklemek için aşağıdaki butona bas.
        </p>
        <SeedButton />
      </div>
    );
  }

  const nextMeeting = data.meetings[0];
  const lastMessage = data.messages[0];
  const pct = data.milestones.length > 0
    ? Math.round((data.doneMilestones / data.milestones.length) * 100)
    : 0;

  return (
    <div className="max-w-6xl mx-auto">
      <div className="mb-6">
        <div className="flex items-center gap-3 mb-1">
          <h1 className="text-xl font-bold text-slate-100">ThesisTrack</h1>
          <span className="text-[10px] font-bold px-2 py-0.5 rounded bg-blue-500/10 text-blue-400">
            Beta
          </span>
        </div>
        <p className="text-sm text-slate-500">{data.thesis.title}</p>
      </div>

      <div className="flex gap-4 flex-wrap mb-6">
        <StatCard
          label="İlerleme"
          value={pct + "%"}
          sub={data.doneMilestones + "/" + data.milestones.length + " milestone"}
          icon="📊"
        />
        <StatCard
          label="Aktif Görevler"
          value={String(data.activeTasks)}
          sub={data.doneTasks + " tamamlandı"}
          icon="📋"
        />
        <StatCard
          label="Sonraki Toplantı"
          value={nextMeeting ? new Date(nextMeeting.date).toLocaleDateString("tr-TR", { day: "numeric", month: "short" }) : "-"}
          sub={nextMeeting ? new Date(nextMeeting.date).toLocaleTimeString("tr-TR", { hour: "2-digit", minute: "2-digit" }) : "Planlanmamış"}
          icon="📅"
        />
        <StatCard
          label="Mesajlar"
          value={lastMessage ? "Yeni" : "-"}
          sub={lastMessage ? (lastMessage.read ? "Okundu" : "Okunmamış") : "Mesaj yok"}
          icon="💬"
        />
      </div>

      <div className="flex gap-4 flex-wrap">
        <div className="flex-[2] min-w-[400px]">
          <MilestoneList milestones={data.milestones} />
        </div>
        <div className="flex-1 min-w-[280px]">
          <ActivityFeed />
        </div>
      </div>
    </div>
  );
}
