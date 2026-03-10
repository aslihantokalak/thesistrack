#!/bin/bash
# ThesisTrack Database Integration Script
# VS Code terminal'inde çalıştır: bash setup-db.sh

echo "🔗 ThesisTrack veritabanı entegrasyonu kuruluyor..."

# Klasör yapısını belirle
if [ -d "src/app" ]; then
  APP_DIR="src/app"
  LIB_DIR="src/lib"
else
  APP_DIR="app"
  LIB_DIR="lib"
fi

# API klasörlerini oluştur
mkdir -p $APP_DIR/api/tasks
mkdir -p $APP_DIR/api/meetings
mkdir -p $APP_DIR/api/messages
mkdir -p $APP_DIR/api/seed
mkdir -p $APP_DIR/api/milestones

echo "📁 API klasörleri oluşturuldu"

# ─── lib/db.ts (güncelle) ─────────────────────────────────
cat > $LIB_DIR/db.ts << 'DBEND'
import { PrismaClient } from "@prisma/client";

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined;
};

export const db = globalForPrisma.prisma ?? new PrismaClient();

if (process.env.NODE_ENV !== "production") globalForPrisma.prisma = db;
DBEND
echo "✅ lib/db.ts"

# ─── API: Seed (test verisi oluştur) ──────────────────────
cat > $APP_DIR/api/seed/route.ts << 'SEEDEND'
import { db } from "@/lib/db";
import { NextResponse } from "next/server";

export async function POST() {
  try {
    // Önce mevcut verileri temizle
    await db.message.deleteMany();
    await db.meeting.deleteMany();
    await db.task.deleteMany();
    await db.milestone.deleteMany();
    await db.thesis.deleteMany();
    await db.user.deleteMany();

    // Kullanıcılar
    const student = await db.user.create({
      data: {
        clerkId: "student_1",
        email: "ahmet@thesistrack.app",
        firstName: "Ahmet",
        lastName: "Kaya",
        role: "STUDENT",
      },
    });

    const advisor = await db.user.create({
      data: {
        clerkId: "advisor_1",
        email: "elif@thesistrack.app",
        firstName: "Elif",
        lastName: "Yılmaz",
        role: "ADVISOR",
      },
    });

    // Tez
    const thesis = await db.thesis.create({
      data: {
        title: "Yapay Zekâ Destekli Öğretim Yöntemlerinin Akademik Başarıya Etkisi",
        description: "Bu çalışma, YZ destekli öğretim yöntemlerinin üniversite öğrencilerinin akademik başarısı üzerindeki etkisini incelemektedir.",
        status: "IN_PROGRESS",
        studentId: "student_1",
        advisorId: "advisor_1",
      },
    });

    // Milestones
    const milestoneData = [
      { name: "Konu Belirleme", status: "COMPLETED", orderNum: 1 },
      { name: "Literatür Taraması", status: "COMPLETED", orderNum: 2 },
      { name: "Araştırma Önerisi", status: "COMPLETED", orderNum: 3 },
      { name: "Veri Toplama", status: "ACTIVE", orderNum: 4 },
      { name: "Analiz & Bulgular", status: "UPCOMING", orderNum: 5 },
      { name: "Taslak Yazımı", status: "UPCOMING", orderNum: 6 },
      { name: "Revizyon & Düzenleme", status: "UPCOMING", orderNum: 7 },
      { name: "Savunma", status: "UPCOMING", orderNum: 8 },
    ];

    for (const m of milestoneData) {
      await db.milestone.create({
        data: { ...m, thesisId: thesis.id },
      });
    }

    // Tasks
    const taskData = [
      { title: "Anket sorularını revize et", status: "BACKLOG", priority: "MEDIUM", assigneeId: "student_1" },
      { title: "İstatistik yöntem karşılaştırması", status: "BACKLOG", priority: "LOW", assigneeId: "student_1" },
      { title: "Katılımcı grubunu belirle", status: "TODO", priority: "HIGH", assigneeId: "student_1" },
      { title: "Etik kurul başvurusu", status: "TODO", priority: "HIGH", assigneeId: "advisor_1" },
      { title: "Pilot çalışma yürütülüyor", status: "IN_PROGRESS", priority: "HIGH", assigneeId: "student_1" },
      { title: "3. Bölüm taslağı yazımı", status: "IN_PROGRESS", priority: "MEDIUM", assigneeId: "student_1" },
      { title: "2. Bölüm - Kavramsal Çerçeve", status: "IN_REVIEW", priority: "MEDIUM", assigneeId: "advisor_1" },
      { title: "1. Bölüm - Giriş onaylandı", status: "DONE", priority: "LOW", assigneeId: "advisor_1" },
      { title: "Kaynak listesi güncellendi", status: "DONE", priority: "LOW", assigneeId: "student_1" },
    ];

    for (const t of taskData) {
      await db.task.create({
        data: {
          title: t.title,
          status: t.status,
          priority: t.priority,
          thesisId: thesis.id,
          assigneeId: t.assigneeId,
          creatorId: "student_1",
          orderNum: 0,
        },
      });
    }

    // Meetings
    const meetingData = [
      { topic: "Pilot çalışma sonuçları değerlendirmesi", date: new Date("2026-03-24T14:00:00"), type: "VIDEO", status: "SCHEDULED" },
      { topic: "3. Bölüm taslak inceleme", date: new Date("2026-04-03T10:30:00"), type: "IN_PERSON", status: "SCHEDULED" },
      { topic: "Kavramsal çerçeve tartışması", date: new Date("2026-02-17T15:00:00"), type: "VIDEO", status: "COMPLETED", notes: "Revizyon noktaları belirlendi" },
      { topic: "1. Bölüm final inceleme", date: new Date("2026-02-10T11:00:00"), type: "IN_PERSON", status: "COMPLETED", notes: "Onaylandı, küçük düzeltmeler" },
    ];

    for (const m of meetingData) {
      await db.meeting.create({
        data: { ...m, thesisId: thesis.id },
      });
    }

    // Messages
    const messageData = [
      { content: "2. Bölüm'deki kavramsal çerçeveye baktım. Bazı noktaları konuşmamız gerekiyor, Pazartesi toplantımızda ele alalım.", senderId: "advisor_1", read: false },
      { content: "Hocam, pilot çalışmanın ilk sonuçlarını yükledim. Katılımcı geri dönüşleri olumlu görünüyor.", senderId: "student_1", read: true },
      { content: "Etik kurul başvuru formunu kontrol ettim, onay için hazır. Yarın imzalayıp göndereceğim.", senderId: "advisor_1", read: true },
    ];

    for (const m of messageData) {
      await db.message.create({
        data: { ...m, thesisId: thesis.id },
      });
    }

    return NextResponse.json({ success: true, message: "Test verileri oluşturuldu!" });
  } catch (error) {
    console.error("Seed error:", error);
    return NextResponse.json({ success: false, error: String(error) }, { status: 500 });
  }
}
SEEDEND
echo "✅ api/seed/route.ts"

# ─── API: Tasks ────────────────────────────────────────────
cat > $APP_DIR/api/tasks/route.ts << 'TASKEND'
import { db } from "@/lib/db";
import { NextResponse } from "next/server";

export async function GET() {
  try {
    const tasks = await db.task.findMany({
      include: { assignee: true },
      orderBy: { createdAt: "desc" },
    });
    return NextResponse.json(tasks);
  } catch (error) {
    return NextResponse.json({ error: String(error) }, { status: 500 });
  }
}

export async function POST(req: Request) {
  try {
    const body = await req.json();
    const task = await db.task.create({
      data: {
        title: body.title,
        description: body.description || null,
        status: body.status || "BACKLOG",
        priority: body.priority || "MEDIUM",
        thesisId: body.thesisId,
        assigneeId: body.assigneeId || null,
        creatorId: body.creatorId,
        orderNum: 0,
      },
    });
    return NextResponse.json(task);
  } catch (error) {
    return NextResponse.json({ error: String(error) }, { status: 500 });
  }
}
TASKEND
echo "✅ api/tasks/route.ts"

# ─── API: Meetings ─────────────────────────────────────────
cat > $APP_DIR/api/meetings/route.ts << 'MEETAPIEND'
import { db } from "@/lib/db";
import { NextResponse } from "next/server";

export async function GET() {
  try {
    const meetings = await db.meeting.findMany({
      orderBy: { date: "desc" },
    });
    return NextResponse.json(meetings);
  } catch (error) {
    return NextResponse.json({ error: String(error) }, { status: 500 });
  }
}
MEETAPIEND
echo "✅ api/meetings/route.ts"

# ─── API: Messages ─────────────────────────────────────────
cat > $APP_DIR/api/messages/route.ts << 'MSGAPIEND'
import { db } from "@/lib/db";
import { NextResponse } from "next/server";

export async function GET() {
  try {
    const messages = await db.message.findMany({
      include: { sender: true },
      orderBy: { createdAt: "desc" },
    });
    return NextResponse.json(messages);
  } catch (error) {
    return NextResponse.json({ error: String(error) }, { status: 500 });
  }
}
MSGAPIEND
echo "✅ api/messages/route.ts"

# ─── API: Milestones ──────────────────────────────────────
cat > $APP_DIR/api/milestones/route.ts << 'MILESAPIEND'
import { db } from "@/lib/db";
import { NextResponse } from "next/server";

export async function GET() {
  try {
    const milestones = await db.milestone.findMany({
      orderBy: { orderNum: "asc" },
    });
    return NextResponse.json(milestones);
  } catch (error) {
    return NextResponse.json({ error: String(error) }, { status: 500 });
  }
}
MILESAPIEND
echo "✅ api/milestones/route.ts"

# ─── Dashboard page (veritabanından çeken) ─────────────────
cat > $APP_DIR/page.tsx << 'PAGEEND'
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
PAGEEND
echo "✅ page.tsx (veritabanı bağlantılı)"

# ─── Seed Button (client component) ───────────────────────
cat > src/components/dashboard/seed-button.tsx << 'SEEDBTNEND'
"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";

export default function SeedButton() {
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState("");
  const router = useRouter();

  async function handleSeed() {
    setLoading(true);
    setMessage("");
    try {
      const res = await fetch("/api/seed", { method: "POST" });
      const data = await res.json();
      if (data.success) {
        setMessage("Veriler yüklendi! Sayfa yenileniyor...");
        setTimeout(() => router.refresh(), 1500);
      } else {
        setMessage("Hata: " + (data.error || "Bilinmeyen hata"));
      }
    } catch (err) {
      setMessage("Bağlantı hatası: " + String(err));
    }
    setLoading(false);
  }

  return (
    <div>
      <button
        onClick={handleSeed}
        disabled={loading}
        className="px-6 py-3 bg-blue-500 text-white font-semibold rounded-lg hover:bg-blue-600 transition-colors disabled:opacity-50"
      >
        {loading ? "Yükleniyor..." : "🚀 Test Verilerini Yükle"}
      </button>
      {message && (
        <p className={`mt-4 text-sm ${message.includes("Hata") ? "text-red-400" : "text-emerald-400"}`}>
          {message}
        </p>
      )}
    </div>
  );
}
SEEDBTNEND
echo "✅ components/dashboard/seed-button.tsx"

# ─── Milestone List (veritabanından) ──────────────────────
cat > src/components/dashboard/milestone-list.tsx << 'MILESTONEEND'
interface Milestone {
  id: string;
  name: string;
  status: string;
  orderNum: number;
}

export default function MilestoneList({ milestones }: { milestones: Milestone[] }) {
  const done = milestones.filter((m) => m.status === "COMPLETED").length;
  const pct = milestones.length > 0 ? Math.round((done / milestones.length) * 100) : 0;

  return (
    <div className="bg-[#151D2B] rounded-xl p-5 border border-[#1E293B]">
      <h3 className="text-sm font-bold text-slate-100 mb-4">Tez Yol Haritası</h3>
      <div className="flex flex-col gap-3">
        {milestones.map((m, i) => (
          <div key={m.id} className="flex items-center gap-3">
            <div
              className={`w-7 h-7 rounded-full flex items-center justify-center text-xs font-bold text-white shrink-0 ${
                m.status === "COMPLETED"
                  ? "bg-emerald-500"
                  : m.status === "ACTIVE"
                  ? "bg-blue-500 shadow-lg shadow-blue-500/30"
                  : "bg-slate-700"
              }`}
            >
              {m.status === "COMPLETED" ? "✓" : i + 1}
            </div>
            <span
              className={`text-sm font-medium flex-1 ${
                m.status === "UPCOMING" ? "text-slate-500" : "text-slate-200"
              }`}
            >
              {m.name}
            </span>
            <span
              className={`text-[10px] font-semibold px-2 py-0.5 rounded ${
                m.status === "COMPLETED"
                  ? "bg-emerald-500/10 text-emerald-400"
                  : m.status === "ACTIVE"
                  ? "bg-blue-500/10 text-blue-400"
                  : "bg-slate-700/50 text-slate-500"
              }`}
            >
              {m.status === "COMPLETED" ? "Tamamlandı" : m.status === "ACTIVE" ? "Aktif" : "Bekliyor"}
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
            style={{ width: pct + "%" }}
          />
        </div>
      </div>
    </div>
  );
}
MILESTONEEND
echo "✅ components/dashboard/milestone-list.tsx (veritabanı bağlantılı)"

# ─── Kanban (veritabanından) ──────────────────────────────
cat > $APP_DIR/kanban/page.tsx << 'KANBANEND'
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
KANBANEND
echo "✅ kanban/page.tsx (veritabanı bağlantılı)"

# ─── Meetings (veritabanından) ────────────────────────────
cat > $APP_DIR/meetings/page.tsx << 'MEETDBEND'
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
MEETDBEND
echo "✅ meetings/page.tsx (veritabanı bağlantılı)"

# ─── Messages (veritabanından) ────────────────────────────
cat > $APP_DIR/messages/page.tsx << 'MSGDBEND'
import { db } from "@/lib/db";

export default async function MessagesPage() {
  let messages: any[] = [];
  try {
    messages = await db.message.findMany({
      include: { sender: true },
      orderBy: { createdAt: "desc" },
    });
  } catch {}

  return (
    <div>
      <h1 className="text-xl font-bold text-slate-100 mb-6">Mesajlar</h1>
      {messages.length === 0 ? (
        <p className="text-slate-500">Henüz mesaj yok. Dashboard'dan test verilerini yükleyin.</p>
      ) : (
        <div className="flex flex-col gap-3">
          {messages.map((msg: any) => (
            <div
              key={msg.id}
              className={`p-4 rounded-xl border ${
                !msg.read ? "bg-blue-500/5 border-blue-500/30" : "bg-[#151D2B] border-[#1E293B]"
              }`}
            >
              <div className="flex items-center gap-3 mb-2">
                <div className="w-8 h-8 rounded-full bg-violet-600 flex items-center justify-center text-white text-xs font-bold shrink-0">
                  {msg.sender.firstName[0]}{msg.sender.lastName[0]}
                </div>
                <span className="text-sm font-semibold text-slate-200">
                  {msg.sender.firstName} {msg.sender.lastName}
                </span>
                {!msg.read && <span className="w-2 h-2 rounded-full bg-blue-400" />}
                <span className="text-[10px] text-slate-500 ml-auto">
                  {new Date(msg.createdAt).toLocaleDateString("tr-TR")}
                </span>
              </div>
              <p className="text-sm text-slate-400 leading-relaxed">{msg.content}</p>
            </div>
          ))}
        </div>
      )}
      <div className="flex gap-3 mt-4">
        <input
          type="text"
          placeholder="Mesaj yazın..."
          className="flex-1 px-4 py-3 rounded-lg border border-[#1E293B] bg-[#151D2B] text-slate-200 text-sm outline-none focus:border-blue-500 transition-colors"
        />
        <button className="px-6 py-3 bg-blue-500 text-white text-sm font-semibold rounded-lg hover:bg-blue-600 transition-colors">
          Gönder
        </button>
      </div>
    </div>
  );
}
MSGDBEND
echo "✅ messages/page.tsx (veritabanı bağlantılı)"

echo ""
echo "🎉 Veritabanı entegrasyonu tamamlandı!"
echo ""
echo "👉 Şimdi sırasıyla çalıştır:"
echo "   1. npx prisma generate"
echo "   2. npm run dev"
echo "   3. Tarayıcıda localhost:3000 aç"
echo "   4. 'Test Verilerini Yükle' butonuna bas"
echo "   5. Dashboard veritabanından veri çekecek!"
