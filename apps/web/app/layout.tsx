import type { Metadata } from 'next';
import { Be_Vietnam_Pro } from 'next/font/google';
import './globals.css';
import { AuthProvider } from '@/lib/auth-context';
import { cn } from "@/lib/utils";
import { Toaster } from 'sonner';

const beVietnamPro = Be_Vietnam_Pro({
  weight: ['300', '400', '500', '600', '700'],
  subsets: ['vietnamese', 'latin'],
  variable: '--font-sans',
  display: 'swap',
});

export const metadata: Metadata = {
  title: 'MF OMS — Quản lý Đơn hàng',
  description: 'Hệ thống Quản lý Đơn hàng & Chăm sóc Khách hàng — Công ty TNHH Mountain Farmers',
  icons: {
    icon: '/favicon.ico',
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="vi" className={cn("h-full", beVietnamPro.variable, "font-sans")}>
      <body className="min-h-full">
        <AuthProvider>{children}</AuthProvider>
        <Toaster theme="light" position="top-right" richColors toastOptions={{
          style: {
            background: 'rgba(245, 240, 235, 0.8)',
            backdropFilter: 'blur(16px)',
            border: '1px solid rgba(220, 210, 200, 0.5)',
            color: 'oklch(0.2 0.02 50)'
          }
        }} />
      </body>
    </html>
  );
}
