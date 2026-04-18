export default function Template({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex flex-col flex-1 h-full w-full">
      {children}
    </div>
  );
}
