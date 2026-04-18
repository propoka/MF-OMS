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
      <div className="fixed bottom-8 right-8 z-40 print:hidden">
        <button
          onClick={() => setIsOpen(true)}
          className="group flex h-[54px] rounded-full items-center bg-zinc-900 text-zinc-50 border border-white/10 shadow-[0_8px_30px_rgb(0,0,0,0.15)] hover:shadow-[0_16px_40px_rgb(0,0,0,0.25)] hover:bg-[#1a1a1a] transition-all duration-500 hover:-translate-y-1.5 overflow-hidden relative"
        >
          <div className="absolute inset-0 rounded-full border border-white/5 group-hover:border-white/20 transition-colors pointer-events-none" />
          
          <div className="flex w-[54px] min-w-[54px] h-full shrink-0 items-center justify-center">
            <Plus size={22} className="stroke-[2.5] group-hover:rotate-90 transition-transform duration-500 ease-out" />
          </div>

          <div className="grid grid-cols-[0fr] group-hover:grid-cols-[1fr] transition-[grid-template-columns] duration-500 ease-[cubic-bezier(0.4,0,0.2,1)]">
            <div className="overflow-hidden flex items-center h-full">
               <span className="font-semibold tracking-wide text-[14px] pr-6 whitespace-nowrap opacity-0 group-hover:opacity-100 transition-opacity duration-500 delay-100 block transform translate-x-2 group-hover:translate-x-0">
                Lên Đơn Mới
               </span>
            </div>
          </div>
        </button>
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
