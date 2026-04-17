'use client';

import { useState, useEffect } from 'react';
import OrderCreateSheet from './OrderCreateSheet';
import { Button } from '@/components/ui/button';
import { Plus } from 'lucide-react';
import { useRouter } from 'next/navigation';

export default function GlobalOrderFab() {
  const [isOpen, setIsOpen] = useState(false);
  const [initialCustomerId, setInitialCustomerId] = useState<string | undefined>();
  const router = useRouter();

  useEffect(() => {
    const handleOpen = (e: any) => {
      if (e.detail?.customerId) {
        setInitialCustomerId(e.detail.customerId);
      } else {
        setInitialCustomerId(undefined);
      }
      setIsOpen(true);
    };
    window.addEventListener('open-global-order-fab', handleOpen);
    return () => window.removeEventListener('open-global-order-fab', handleOpen);
  }, []);

  return (
    <>
      <div className="fixed bottom-8 right-8 z-40">
        <Button
          onClick={() => setIsOpen(true)}
          className="h-[52px] px-6 rounded-full flex items-center justify-center gap-2.5 bg-zinc-900 hover:bg-zinc-800 dark:bg-white dark:hover:bg-zinc-200 dark:text-zinc-900 text-zinc-50 border border-zinc-700 shadow-[0_12px_36px_rgb(0,0,0,0.15)] hover:shadow-[0_16px_40px_rgb(0,0,0,0.2)] transition-all duration-300 ease-out hover:-translate-y-1"
        >
          <Plus size={20} className="stroke-[2.5] opacity-90" />
          <span className="font-semibold tracking-[0.02em] text-[14px] whitespace-nowrap">
            Lên Đơn Mới
          </span>
        </Button>
      </div>

      <OrderCreateSheet 
        isOpen={isOpen}
        initialCustomerId={initialCustomerId}
        onClose={() => {
          setIsOpen(false);
          setInitialCustomerId(undefined);
        }}
        onSuccess={() => {
          setIsOpen(false);
          router.refresh(); // Refresh current page to reflect new orders if needed
          window.dispatchEvent(new Event('order-created')); // to notify client lists across the app (like orders/page.tsx)
        }}
      />
    </>
  );
}
