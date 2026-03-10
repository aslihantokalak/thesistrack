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
