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
