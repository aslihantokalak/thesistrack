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
