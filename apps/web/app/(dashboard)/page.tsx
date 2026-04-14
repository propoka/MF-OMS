import { redirect } from 'next/navigation';

export default function DashboardHome() {
  // Hiện tại chưa xây dựng báo cáo tổng quan, chuyển hướng thẳng vào Khách hàng
  redirect('/customers');
}
