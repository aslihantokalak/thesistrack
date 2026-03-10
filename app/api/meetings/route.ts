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
