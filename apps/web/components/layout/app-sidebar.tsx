'use client';

import {
  Sidebar,
  SidebarContent,
  SidebarFooter,
  SidebarGroup,
  SidebarGroupLabel,
  SidebarHeader,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
  SidebarRail
} from '@/components/ui/sidebar';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
  DropdownMenuGroup
} from '@/components/ui/dropdown-menu';
import { useAuth } from '@/lib/auth-context';
import { usePathname } from 'next/navigation';
import { Icons } from '@/components/icons';
import Link from 'next/link';
import Image from 'next/image';
import * as React from 'react';

// Navigation mapped to Tabler Icons and Grouped
const navigationGroups = [
  {
    label: 'TỔNG QUAN',
    items: [
      { name: 'Tổng quan', href: '/dashboard', icon: Icons.dashboard },
      { name: 'Báo cáo', href: '/reports', icon: Icons.kanban },
    ]
  },
  {
    label: 'KINH DOANH',
    items: [
      { name: 'Đơn hàng', href: '/orders', icon: Icons.billing },
      { name: 'Khách hàng', href: '/customers', icon: Icons.user },
      { name: 'Nhóm khách', href: '/customer-groups', icon: Icons.teams },
    ]
  },
  {
    label: 'KHO & SẢN PHẨM',
    items: [
      { name: 'Sản phẩm', href: '/products', icon: Icons.product },
      { name: 'Danh mục', href: '/products/categories', icon: Icons.kanban },
    ]
  },
  {
    label: 'HỆ THỐNG',
    items: [
      { name: 'Cài đặt hệ thống', href: '/settings', icon: Icons.settings },
    ]
  }
];

export default function AppSidebar() {
  const pathname = usePathname();
  const { user, logout } = useAuth();

  return (
    <Sidebar collapsible='icon' className='border-r-0 border-transparent shadow-[1px_0_10px_rgba(0,0,0,0.03)]'>
      <SidebarHeader className='group-data-[collapsible=icon]:pt-4 h-16 flex justify-center py-2'>
        <div className="flex items-center justify-center w-full px-2">
          <Image 
            src="/Logo-Moutain-Farmers.png" 
            alt="Mountain Farmers Logo" 
            width={0}
            height={0}
            sizes="100px"
            style={{ width: '100px', height: 'auto' }}
            className="object-contain group-data-[collapsible=icon]:hidden"
            priority
            unoptimized
          />
          <div className="hidden group-data-[collapsible=icon]:flex w-8 h-8 rounded-lg bg-sidebar-primary text-sidebar-primary-foreground flex-shrink-0 items-center justify-center font-bold">
            MF
          </div>
        </div>
      </SidebarHeader>

      <SidebarContent className='overflow-x-hidden pt-4 custom-scrollbar'>
        {navigationGroups.map((group, index) => (
          <SidebarGroup key={index} className='py-0 mb-4'>
            <SidebarGroupLabel className="group-data-[collapsible=icon]:hidden mt-0 text-[10px] uppercase font-semibold text-muted-foreground/60 tracking-wider">
              {group.label}
            </SidebarGroupLabel>
            <SidebarMenu className="gap-1.5 mt-1">
              {group.items.map((item) => {
                const Icon = item.icon;
                const isActive = pathname.startsWith(item.href);
                return (
                  <SidebarMenuItem key={item.name}>
                    <SidebarMenuButton
                      tooltip={item.name}
                      isActive={isActive}
                      className={`h-9 px-3 transition-all rounded-lg ${isActive ? 'bg-primary/10 text-primary font-semibold' : 'text-zinc-600 hover:bg-zinc-100 hover:text-zinc-900 font-medium'}`}
                      render={
                        <Link href={item.href} className="flex items-center w-full">
                          <Icon className={isActive ? "text-primary mr-2" : "text-zinc-500 mr-2"} />
                          <span>{item.name}</span>
                          {isActive && <div className="ml-auto w-1.5 h-1.5 rounded-full bg-primary" />}
                        </Link>
                      }
                    />
                  </SidebarMenuItem>
                );
              })}
            </SidebarMenu>
          </SidebarGroup>
        ))}
      </SidebarContent>

      <div className="px-4 py-2 opacity-30">
        <hr className="border-sidebar-border" />
      </div>

      <SidebarFooter>
        <SidebarMenu>
          <SidebarMenuItem>
            <DropdownMenu>
              <DropdownMenuTrigger
                render={
                  <SidebarMenuButton
                    size='lg'
                    className='data-[state=open]:bg-sidebar-accent data-[state=open]:text-sidebar-accent-foreground group'
                  >
                    <div className="w-8 h-8 rounded-full overflow-hidden flex-shrink-0 bg-primary/5 flex items-center justify-center">
                      <Image src="/avatar.svg" alt="Avatar" width={32} height={32} unoptimized />
                    </div>
                    <div className="flex flex-col items-start text-sm group-data-[collapsible=icon]:hidden">
                      <span className="font-semibold leading-none text-sidebar-foreground">{user?.fullName}</span>
                      <span className="text-xs text-muted-foreground mt-1 truncate max-w-[120px]">{user?.role === 'ADMIN' ? 'Admin' : 'Staff'}</span>
                    </div>
                    <Icons.chevronsUpDown className="ml-auto size-4 group-data-[collapsible=icon]:hidden text-sidebar-foreground/50" />
                  </SidebarMenuButton>
                }
              />
              <DropdownMenuContent
                className='w-(--radix-dropdown-menu-trigger-width) min-w-56 rounded-lg'
                side='bottom'
                align='end'
                sideOffset={4}
              >
                <div className='px-2 py-1.5 font-normal flex items-center gap-2'>
                    <div className="w-8 h-8 rounded-full overflow-hidden flex-shrink-0 bg-primary/5 flex items-center justify-center">
                      <Image src="/avatar.svg" alt="Avatar" width={32} height={32} unoptimized />
                    </div>
                    <div className="flex flex-col items-start text-sm">
                      <span className="font-semibold leading-none text-sidebar-foreground">{user?.fullName}</span>
                      <span className="text-xs text-muted-foreground mt-1 truncate max-w-[120px]">{user?.role === 'ADMIN' ? 'Admin' : 'Staff'}</span>
                    </div>
                </div>
                <DropdownMenuSeparator />
                <DropdownMenuGroup>
                  <DropdownMenuItem>
                    <Icons.account className='mr-2 h-4 w-4' />
                    Hồ sơ cá nhân
                  </DropdownMenuItem>
                </DropdownMenuGroup>
                <DropdownMenuSeparator />
                <DropdownMenuItem onClick={logout} className="text-destructive focus:bg-destructive/10 focus:text-destructive">
                  <Icons.logout className='mr-2 h-4 w-4' />
                  Đăng xuất
                </DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
          </SidebarMenuItem>
        </SidebarMenu>
      </SidebarFooter>
      <SidebarRail />
    </Sidebar>
  );
}
