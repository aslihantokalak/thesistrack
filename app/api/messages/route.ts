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
