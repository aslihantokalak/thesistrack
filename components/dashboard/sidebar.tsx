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
