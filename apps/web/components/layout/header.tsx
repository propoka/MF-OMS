'use client';

import { usePathname } from 'next/navigation';
import { SidebarTrigger } from '../ui/sidebar';
import { Separator } from '../ui/separator';
import { Button } from '@/components/ui/button';
import { GreetingWidget } from './GreetingWidget';

const navigation = [
  { name: 'Tổng quan', href: '/dashboard' },
  { name: 'Khách hàng', href: '/customers' },
  { name: 'Nhóm khách', href: '/customer-groups' },
  { name: 'Sản phẩm', href: '/products' },
  { name: 'Đơn hàng', href: '/orders' },
  { name: 'Cài đặt', href: '/settings' },
];

export default function Header() {
  const pathname = usePathname();
  
  const currentNav = navigation.find(n => pathname.startsWith(n.href))?.name || 'Chi tiết';

  return (
    <header className='bg-[#faf9f8]/60 backdrop-blur-md sticky top-0 z-20 flex h-16 shrink-0 items-center justify-between gap-2 border-b-0'>
      <div className='flex items-center gap-2 px-4'>
        <SidebarTrigger className='-ml-1' />
        <Separator orientation='vertical' className='mr-2 h-4' />
        <div className="text-sm font-medium text-muted-foreground hidden sm:flex">
          Mountain Farmers OMS <span className="mx-2">/</span> <span className="text-foreground">{currentNav}</span>
        </div>
      </div>

      <div className='flex items-center gap-2 pr-4 md:pr-6 lg:pr-8'>
        <div className='hidden md:flex'>
          <GreetingWidget />
        </div>
      </div>
    </header>
  );
}
