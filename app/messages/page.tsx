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
