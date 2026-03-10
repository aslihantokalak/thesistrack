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
