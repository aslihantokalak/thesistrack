#!/bin/bash
# Seed dosyasını düzelt
# Kullanım: bash fix-seed.sh

if [ -d "src/app" ]; then
  API_DIR="src/app/api/seed"
elif [ -d "app" ]; then
  API_DIR="app/api/seed"
else
  echo "❌ app klasörü bulunamadı!"
  exit 1
fi

mkdir -p $API_DIR

cat > $API_DIR/route.ts << 'SEEDFIX'
import { db } from "@/lib/db";
import { NextResponse } from "next/server";

export async function POST() {
  try {
    await db.message.deleteMany();
    await db.meeting.deleteMany();
    await db.task.deleteMany();
    await db.milestone.deleteMany();
    await db.thesis.deleteMany();
    await db.user.deleteMany();

    await db.user.create({
      data: {
        clerkId: "student_1",
        email: "ahmet@thesistrack.app",
        firstName: "Ahmet",
        lastName: "Kaya",
        role: "STUDENT",
      },
    });

    await db.user.create({
      data: {
        clerkId: "advisor_1",
        email: "elif@thesistrack.app",
        firstName: "Elif",
        lastName: "Yılmaz",
        role: "ADVISOR",
      },
    });

    const thesis = await db.thesis.create({
      data: {
        title: "Yapay Zeka Destekli Ogretim Yontemlerinin Akademik Basariya Etkisi",
        description: "YZ destekli ogretim yontemlerinin akademik basariya etkisi",
        status: "IN_PROGRESS",
        studentId: "student_1",
        advisorId: "advisor_1",
      },
    });

    const milestones = [
      { name: "Konu Belirleme", status: "COMPLETED", orderNum: 1 },
      { name: "Literatur Taramasi", status: "COMPLETED", orderNum: 2 },
      { name: "Arastirma Onerisi", status: "COMPLETED", orderNum: 3 },
      { name: "Veri Toplama", status: "ACTIVE", orderNum: 4 },
      { name: "Analiz ve Bulgular", status: "UPCOMING", orderNum: 5 },
      { name: "Taslak Yazimi", status: "UPCOMING", orderNum: 6 },
      { name: "Revizyon", status: "UPCOMING", orderNum: 7 },
      { name: "Savunma", status: "UPCOMING", orderNum: 8 },
    ];
    for (const m of milestones) {
      await db.milestone.create({ data: { ...m, thesisId: thesis.id } });
    }

    const tasks = [
      { title: "Anket sorularini revize et", status: "BACKLOG", priority: "MEDIUM", assigneeId: "student_1" },
      { title: "Istatistik yontem karsilastirmasi", status: "BACKLOG", priority: "LOW", assigneeId: "student_1" },
      { title: "Katilimci grubunu belirle", status: "TODO", priority: "HIGH", assigneeId: "student_1" },
      { title: "Etik kurul basvurusu", status: "TODO", priority: "HIGH", assigneeId: "advisor_1" },
      { title: "Pilot calisma yurutluyor", status: "IN_PROGRESS", priority: "HIGH", assigneeId: "student_1" },
      { title: "3. Bolum taslagi yazimi", status: "IN_PROGRESS", priority: "MEDIUM", assigneeId: "student_1" },
      { title: "2. Bolum - Kavramsal Cerceve", status: "IN_REVIEW", priority: "MEDIUM", assigneeId: "advisor_1" },
      { title: "1. Bolum - Giris onaylandi", status: "DONE", priority: "LOW", assigneeId: "advisor_1" },
      { title: "Kaynak listesi guncellendi", status: "DONE", priority: "LOW", assigneeId: "student_1" },
    ];
    for (const t of tasks) {
      await db.task.create({
        data: {
          title: t.title,
          status: t.status,
          priority: t.priority,
          thesisId: thesis.id,
          assigneeId: t.assigneeId,
          orderNum: 0,
        },
      });
    }

    const meetings = [
      { topic: "Pilot calisma sonuclari", date: new Date("2026-03-24T14:00:00"), type: "VIDEO", status: "SCHEDULED" },
      { topic: "3. Bolum taslak inceleme", date: new Date("2026-04-03T10:30:00"), type: "IN_PERSON", status: "SCHEDULED" },
      { topic: "Kavramsal cerceve tartismasi", date: new Date("2026-02-17T15:00:00"), type: "VIDEO", status: "COMPLETED", notes: "Revizyon noktalari belirlendi" },
      { topic: "1. Bolum final inceleme", date: new Date("2026-02-10T11:00:00"), type: "IN_PERSON", status: "COMPLETED", notes: "Onaylandi" },
    ];
    for (const m of meetings) {
      await db.meeting.create({ data: { ...m, thesisId: thesis.id } });
    }

    const messages = [
      { content: "2. Bolum kavramsal cerceveye baktim. Pazartesi konusalim.", senderId: "advisor_1", read: false },
      { content: "Pilot calisma sonuclarini yukledim. Geri donusler olumlu.", senderId: "student_1", read: true },
      { content: "Etik kurul basvuru formunu kontrol ettim, onay icin hazir.", senderId: "advisor_1", read: true },
    ];
    for (const m of messages) {
      await db.message.create({ data: { ...m, thesisId: thesis.id } });
    }

    return NextResponse.json({ success: true, message: "Test verileri yuklendi!" });
  } catch (error) {
    console.error("Seed error:", error);
    return NextResponse.json({ success: false, error: String(error) }, { status: 500 });
  }
}
SEEDFIX

echo "✅ Seed dosyası düzeltildi!"
echo "👉 Tarayıcıda localhost:3000 aç ve butona bas"
