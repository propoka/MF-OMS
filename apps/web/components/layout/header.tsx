'use client';

import { usePathname } from 'next/navigation';
import { SidebarTrigger } from '../ui/sidebar';
import { Separator } from '../ui/separator';
import { Button } from '@/components/ui/button';
import { Icons } from '@/components/icons';

const navigation = [
  { name: 'Tổng quan', href: '/dashboard' },
  { name: 'Khách hàng', href: '/customers' },
  { name: 'Nhóm khách', href: '/customer-groups' },
  { name: 'Sản phẩm', href: '/products' },
  { name: 'Đơn hàng', href: '/orders' },
  { name: 'Cài đặt hệ thống', href: '/settings' },
];

export default function Header() {
  const pathname = usePathname();
  
  const currentNav = navigation.find(n => pathname.startsWith(n.href))?.name || 'Chi tiết';

  return (
    <header className='bg-background sticky top-0 z-20 flex h-16 shrink-0 items-center justify-between gap-2 border-b border-border'>
      <div className='flex items-center gap-2 px-4'>
        <SidebarTrigger className='-ml-1' />
        <Separator orientation='vertical' className='mr-2 h-4' />
        <div className="text-sm font-medium text-muted-foreground hidden sm:flex">
          Hệ thống <span className="mx-2">/</span> <span className="text-foreground">{currentNav}</span>
        </div>
      </div>

      <div className='flex items-center gap-2 px-4'>
        <div className='hidden md:flex'>
          <div className='w-full space-y-2'>
            <Button
              variant='outline'
              className='bg-background text-muted-foreground relative h-9 w-full justify-start rounded-[0.5rem] text-sm font-normal shadow-none sm:pr-12 md:w-40 lg:w-64 cursor-text'
            >
              <Icons.search className='mr-2 h-4 w-4' />
              Tìm kiếm...
              <kbd className='bg-muted pointer-events-none absolute top-[0.3rem] right-[0.3rem] hidden h-6 items-center gap-1 rounded border px-1.5 font-mono text-[10px] font-medium opacity-100 select-none sm:flex text-muted-foreground'>
                <span className='text-xs'>⌘</span>K
              </kbd>
            </Button>
          </div>
        </div>
      </div>
    </header>
  );
}
