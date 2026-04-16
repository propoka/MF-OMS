'use client';

import { useState } from 'react';
import OrderCreateSheet from './OrderCreateSheet';
import { Button } from '@/components/ui/button';
import { Plus } from 'lucide-react';
import { useRouter } from 'next/navigation';

export default function GlobalOrderFab() {
  const [isOpen, setIsOpen] = useState(false);
  const router = useRouter();

  return (
    <>
      <div className="fixed bottom-6 right-6 lg:bottom-8 lg:right-8 z-40 group">
        <Button
          onClick={() => setIsOpen(true)}
          className="relative h-14 w-14 group-hover:w-[170px] rounded-full transition-all duration-[400ms] ease-[cubic-bezier(0.23,1,0.32,1)] p-0 flex items-center justify-start bg-gradient-to-tr from-primary to-primary/80 text-primary-foreground border border-white/10 overflow-hidden shadow-none"
          title="Tạo đơn hàng mới"
        >
          <div className="flex shrink-0 h-14 w-14 items-center justify-center">
            <Plus size={26} className="group-hover:rotate-90 transition-transform duration-500 ease-in-out" />
          </div>
          <span className="shrink-0 whitespace-nowrap font-bold tracking-tight opacity-0 group-hover:opacity-100 group-hover:-translate-x-1 transition-all duration-500 ease-out text-[15px] pr-5">
            Lên Đơn Mới
          </span>
        </Button>
      </div>

      <OrderCreateSheet 
        isOpen={isOpen}
        onClose={() => setIsOpen(false)}
        onSuccess={() => {
          setIsOpen(false);
          router.refresh(); // Refresh current page to reflect new orders if needed
          window.dispatchEvent(new Event('order-created')); // to notify client lists across the app (like orders/page.tsx)
        }}
      />
    </>
  );
}
