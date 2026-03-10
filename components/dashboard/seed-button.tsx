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
