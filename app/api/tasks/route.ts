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
