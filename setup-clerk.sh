#!/bin/bash
# ThesisTrack Clerk Authentication Setup
# Kullanım: bash setup-clerk.sh

echo "🔐 Clerk authentication kuruluyor..."

# Klasör yapısını belirle
if [ -d "src/app" ]; then
  APP_DIR="src/app"
  ROOT_DIR="src"
else
  APP_DIR="app"
  ROOT_DIR="."
fi

# Klasörleri oluştur
mkdir -p $APP_DIR/sign-in/[[...sign-in]]
mkdir -p $APP_DIR/sign-up/[[...sign-up]]

echo "📁 Auth klasörleri oluşturuldu"

# ─── middleware.ts (proje kökünde) ─────────────────────────
cat > middleware.ts << 'MIDEND'
import { clerkMiddleware, createRouteMatcher } from "@clerk/nextjs/server";

const isPublicRoute = createRouteMatcher([
  "/sign-in(.*)",
  "/sign-up(.*)",
  "/api/webhooks(.*)",
]);

export default clerkMiddleware(async (auth, request) => {
  if (!isPublicRoute(request)) {
    await auth.protect();
  }
});

export const config = {
  matcher: ["/((?!.*\\..*|_next).*)", "/", "/(api|trpc)(.*)"],
};
MIDEND
echo "✅ middleware.ts"

# ─── layout.tsx (ClerkProvider ekle) ──────────────────────
cat > $APP_DIR/layout.tsx << 'LAYOUTEND'
import type { Metadata } from "next";
import { ClerkProvider } from "@clerk/nextjs";
import "./globals.css";
import Sidebar from "@/components/dashboard/sidebar";

export const metadata: Metadata = {
  title: "ThesisTrack",
  description: "Tez Danışmanlık Takip Platformu",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <ClerkProvider>
      <html lang="tr">
        <body>
          <div className="flex min-h-screen bg-[#0A0E17]">
            <Sidebar />
            <main className="flex-1 ml-[68px] p-6 overflow-y-auto">
              {children}
            </main>
          </div>
        </body>
      </html>
    </ClerkProvider>
  );
}
LAYOUTEND
echo "✅ layout.tsx (ClerkProvider eklendi)"

# ─── Sign In page ─────────────────────────────────────────
cat > $APP_DIR/sign-in/[[...sign-in]]/page.tsx << 'SIGNINEND'
import { SignIn } from "@clerk/nextjs";

export default function SignInPage() {
  return (
    <div className="flex items-center justify-center min-h-screen bg-[#0A0E17] -ml-[68px]">
      <div className="text-center">
        <div className="flex items-center justify-center gap-3 mb-8">
          <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-blue-500 to-violet-500 flex items-center justify-center text-white font-extrabold text-lg">
            T
          </div>
          <h1 className="text-2xl font-bold text-slate-100">ThesisTrack</h1>
        </div>
        <SignIn
          appearance={{
            elements: {
              rootBox: "mx-auto",
              card: "bg-[#151D2B] border border-[#1E293B]",
            },
          }}
        />
      </div>
    </div>
  );
}
SIGNINEND
echo "✅ sign-in page"

# ─── Sign Up page ─────────────────────────────────────────
cat > $APP_DIR/sign-up/[[...sign-up]]/page.tsx << 'SIGNUPEND'
import { SignUp } from "@clerk/nextjs";

export default function SignUpPage() {
  return (
    <div className="flex items-center justify-center min-h-screen bg-[#0A0E17] -ml-[68px]">
      <div className="text-center">
        <div className="flex items-center justify-center gap-3 mb-8">
          <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-blue-500 to-violet-500 flex items-center justify-center text-white font-extrabold text-lg">
            T
          </div>
          <h1 className="text-2xl font-bold text-slate-100">ThesisTrack</h1>
        </div>
        <SignUp
          appearance={{
            elements: {
              rootBox: "mx-auto",
              card: "bg-[#151D2B] border border-[#1E293B]",
            },
          }}
        />
      </div>
    </div>
  );
}
SIGNUPEND
echo "✅ sign-up page"

# ─── Sidebar güncelle (kullanıcı bilgisi + çıkış) ────────
cat > components/dashboard/sidebar.tsx << 'SIDEBAREND'
"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { UserButton } from "@clerk/nextjs";

const navItems = [
  { label: "Dashboard", href: "/", icon: "◫" },
  { label: "Kanban", href: "/kanban", icon: "▦" },
  { label: "Toplantılar", href: "/meetings", icon: "◷" },
  { label: "Mesajlar", href: "/messages", icon: "✉" },
];

export default function Sidebar() {
  const pathname = usePathname();

  if (pathname.startsWith("/sign-in") || pathname.startsWith("/sign-up")) {
    return null;
  }

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

      <UserButton
        afterSignOutUrl="/sign-in"
        appearance={{
          elements: {
            avatarBox: "w-8 h-8",
          },
        }}
      />
    </aside>
  );
}
SIDEBAREND
echo "✅ sidebar.tsx (Clerk UserButton eklendi)"

echo ""
echo "🎉 Clerk dosyaları oluşturuldu!"
echo ""
echo "⚠️  ŞİMDİ YAPMAN GEREKEN:"
echo "   1. .env dosyasına Clerk key'lerini ekle:"
echo '      NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY="pk_test_..."'
echo '      CLERK_SECRET_KEY="sk_test_..."'
echo '      NEXT_PUBLIC_CLERK_SIGN_IN_URL="/sign-in"'
echo '      NEXT_PUBLIC_CLERK_SIGN_UP_URL="/sign-up"'
echo ""
echo "   2. npm run dev"
echo "   3. localhost:3000 → Giriş ekranı göreceksin!"
