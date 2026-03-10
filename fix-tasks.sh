#!/bin/bash
# Tasks API'yı düzelt
# Kullanım: bash fix-tasks.sh

if [ -d "src/app" ]; then
  API_DIR="src/app/api/tasks"
elif [ -d "app" ]; then
  API_DIR="app/api/tasks"
else
  echo "❌ app klasörü bulunamadı!"
  exit 1
fi

mkdir -p $API_DIR

cat > $API_DIR/route.ts << 'FIXEND'
import { db } from "@/lib/db";
import { NextResponse } from "next/server";

export async function GET() {
  try {
    const tasks = await db.task.findMany({
      orderBy: { createdAt: "desc" },
    });
    return NextResponse.json(tasks);
  } catch (error) {
    console.error("Tasks error:", error);
    return NextResponse.json({ error: String(error) }, { status: 500 });
  }
}
FIXEND

echo "✅ Tasks API düzeltildi!"
echo "👉 Tarayıcıda localhost:3000/api/tasks kontrol et"
