#!/bin/bash
# ThesisTrack Dashboard Setup Script
# VS Code terminal'inde çalıştır: bash setup-dashboard.sh

echo "🚀 ThesisTrack Dashboard kuruluyor..."

# Klasör yapısını belirle
if [ -d "src/app" ]; then
  APP_DIR="src/app"
  COMP_DIR="src/components"
  LIB_DIR="src/lib"
elif [ -d "app" ]; then
  APP_DIR="app"
  COMP_DIR="components"
  LIB_DIR="lib"
else
  echo "❌ app klasörü bulunamadı!"
  exit 1
fi

echo "📁 Klasör yapısı: $APP_DIR"

# Klasörleri oluştur
mkdir -p $COMP_DIR/dashboard
mkdir -p $LIB_DIR
mkdir -p $APP_DIR/kanban
mkdir -p $APP_DIR/meetings
mkdir -p $APP_DIR/messages

echo "📁 Klasörler oluşturuldu"

# ─── globals.css ────────────────────────────────────────────
cat > $APP_DIR/globals.css << 'CSSEND'
@import "tailwindcss";

:root {
  --bg: #0A0E17;
  --surface: #111827;
  --card: #151D2B;
  --border: #1E293B;
  --accent: #3B82F6;
  --text: #F1F5F9;
  --text-sec: #94A3B8;
  --text-dim: #64748B;
}

body {
  background: var(--bg);
  color: var(--text);
}

* {
  scrollbar-width: thin;
  scrollbar-color: #1E293B transparent;
}
CSSEND
echo "✅ globals.css"

# ─── lib/utils.ts ──────────────────────────────────────────
cat > $LIB_DIR/utils.ts << 'UTILSEND'
export function cn(...classes: (string | undefined | false)[]) {
  return classes.filter(Boolean).join(" ");
}

export function formatDate(date: string) {
  return new Date(date).toLocaleDateString("tr-TR", {
    day: "numeric",
    month: "long",
    year: "numeric",
  });
}
UTILSEND
echo "✅ lib/utils.ts"

# ─── lib/db.ts ─────────────────────────────────────────────
cat > $LIB_DIR/db.ts << 'DBEND'
import { PrismaClient } from "@prisma/client";

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined;
};

export const db = globalForPrisma.prisma ?? new PrismaClient();

if (process.env.NODE_ENV !== "production") globalForPrisma.prisma = db;
DBEND
echo "✅ lib/db.ts"

# ─── components/dashboard/sidebar.tsx ──────────────────────
cat > $COMP_DIR/dashboard/sidebar.tsx << 'SIDEBAREND'
"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

const navItems = [
  { label: "Dashboard", href: "/", icon: "◫" },
  { label: "Kanban", href: "/kanban", icon: "▦" },
  { label: "Toplantılar", href: "/meetings", icon: "◷" },
  { label: "Mesajlar", href: "/messages", icon: "✉" },
];

export default function Sidebar() {
  const pathname = usePathname();

  return (
    <aside className="w-[68px] h-screen bg-[#111827] border-r border-[#1E293B] flex flex-col items-center py-4 gap-1 fixed left-0 top-0">
      <Link
        href="/"
        className="w-10 h-10 rounded-xl bg-gradient-to-br from-blue-500 to-violet-500 flex items-center justify-center text-white font-extrabold text-lg mb-6 hover:scale-105 transition-transform"
      >
        T
      </Link>

      <nav className="flex flex-col items-center gap-1 flex-1">
        {navItems.map((item) => {
          const isActive = pathname === item.href;
          return (
            <Link
              key={item.href}
              href={item.href}
              className={`relative w-10 h-10 rounded-lg flex items-center justify-center transition-all text-lg group ${
                isActive
                  ? "bg-blue-500/15 text-blue-400"
                  : "text-slate-500 hover:text-slate-300 hover:bg-slate-800"
              }`}
            >
              {item.icon}
              <span className="absolute left-full ml-3 px-2 py-1 rounded-md bg-slate-800 text-slate-200 text-xs font-medium whitespace-nowrap opacity-0 pointer-events-none group-hover:opacity-100 transition-opacity z-50 border border-slate-700">
                {item.label}
              </span>
            </Link>
          );
        })}
      </nav>

      <div className="w-8 h-8 rounded-full bg-emerald-600 flex items-center justify-center text-white text-xs font-bold">
        E
      </div>
    </aside>
  );
}
SIDEBAREND
echo "✅ components/dashboard/sidebar.tsx"

# ─── components/dashboard/stat-card.tsx ────────────────────
cat > $COMP_DIR/dashboard/stat-card.tsx << 'STATEND'
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
STATEND
echo "✅ components/dashboard/stat-card.tsx"

# ─── components/dashboard/milestone-list.tsx ───────────────
cat > $COMP_DIR/dashboard/milestone-list.tsx << 'MILESTONEEND'
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
MILESTONEEND
echo "✅ components/dashboard/milestone-list.tsx"

# ─── components/dashboard/activity-feed.tsx ────────────────
cat > $COMP_DIR/dashboard/activity-feed.tsx << 'ACTIVITYEND'
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
ACTIVITYEND
echo "✅ components/dashboard/activity-feed.tsx"

# ─── layout.tsx ─────────────────────────────────────────────
cat > $APP_DIR/layout.tsx << 'LAYOUTEND'
import type { Metadata } from "next";
import "./globals.css";
import Sidebar from "@/components/dashboard/sidebar";

export const metadata: Metadata = {
  title: "ThesisTrack",
  description: "Tez Danışmanlık Takip Platformu",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="tr">
      <body>
        <div className="flex min-h-screen bg-[#0A0E17]">
          <Sidebar />
          <main className="flex-1 ml-[68px] p-6 overflow-y-auto">
            {children}
          </main>
        </div>
      </body>
    </html>
  );
}
LAYOUTEND
echo "✅ layout.tsx"

# ─── page.tsx (Ana Dashboard) ──────────────────────────────
cat > $APP_DIR/page.tsx << 'PAGEEND'
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
PAGEEND
echo "✅ page.tsx (Dashboard)"

# ─── Kanban page ───────────────────────────────────────────
cat > $APP_DIR/kanban/page.tsx << 'KANBANEND'
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
KANBANEND
echo "✅ kanban/page.tsx"

# ─── Meetings page ─────────────────────────────────────────
cat > $APP_DIR/meetings/page.tsx << 'MEETEND'
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
MEETEND
echo "✅ meetings/page.tsx"

# ─── Messages page ─────────────────────────────────────────
cat > $APP_DIR/messages/page.tsx << 'MSGEND'
const messages = [
  { from: "Prof. Dr. Elif Yılmaz", initials: "EY", time: "Bugün 09:45", text: "2. Bölüm'deki kavramsal çerçeveye baktım. Bazı noktaları konuşmamız gerekiyor.", unread: true },
  { from: "Ahmet Kaya", initials: "AK", time: "Dün 18:30", text: "Hocam, pilot çalışmanın ilk sonuçlarını yükledim. Katılımcı geri dönüşleri olumlu.", unread: false },
  { from: "Prof. Dr. Elif Yılmaz", initials: "EY", time: "19 Şub", text: "Etik kurul başvuru formunu kontrol ettim, onay için hazır.", unread: false },
];

export default function MessagesPage() {
  return (
    <div>
      <h1 className="text-xl font-bold text-slate-100 mb-6">Mesajlar</h1>
      <div className="flex flex-col gap-3">
        {messages.map((msg, i) => (
          <div
            key={i}
            className={`p-4 rounded-xl border ${
              msg.unread
                ? "bg-blue-500/5 border-blue-500/30"
                : "bg-[#151D2B] border-[#1E293B]"
            }`}
          >
            <div className="flex items-center gap-3 mb-2">
              <div className="w-8 h-8 rounded-full bg-violet-600 flex items-center justify-center text-white text-xs font-bold shrink-0">
                {msg.initials}
              </div>
              <span className="text-sm font-semibold text-slate-200">{msg.from}</span>
              {msg.unread && <span className="w-2 h-2 rounded-full bg-blue-400" />}
              <span className="text-[10px] text-slate-500 ml-auto">{msg.time}</span>
            </div>
            <p className="text-sm text-slate-400 leading-relaxed">{msg.text}</p>
          </div>
        ))}
      </div>
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
MSGEND
echo "✅ messages/page.tsx"

# ─── tsconfig paths ────────────────────────────────────────
# @ alias'ın çalıştığından emin ol
if ! grep -q '"@/*"' tsconfig.json 2>/dev/null; then
  echo "⚠️  tsconfig.json'da @ alias kontrol et"
fi

echo ""
echo "🎉 Tüm dosyalar oluşturuldu!"
echo "👉 Şimdi çalıştır: npm run dev"
echo "👉 Tarayıcıda aç: http://localhost:3000"
