'use client';

import { useState, useEffect } from 'react';
import { settingsApi, usersApi, CompanySettings, CancelReason, User } from '@/lib/api';
import { useAuth } from '@/lib/auth-context';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Loader2, Plus, Trash2, Save, Settings, FileText, ListChecks, Users as UsersIcon } from 'lucide-react';
import { Switch } from '@/components/ui/switch';
import { toast } from 'sonner';
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog";
import { AlertCircle } from 'lucide-react';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";

export default function SettingsPage() {
  const { getToken, user } = useAuth();
  
  // Tab state
  const [activeTab, setActiveTab] = useState<'general' | 'reasons' | 'users'>('general');

  // States
  const [company, setCompany] = useState<CompanySettings | null>(null);
  const [reasons, setReasons] = useState<CancelReason[]>([]);
  const [usersList, setUsersList] = useState<User[]>([]);
  
  const [isLoadingCompany, setIsLoadingCompany] = useState(true);
  const [isSavingCompany, setIsSavingCompany] = useState(false);
  
  const [isLoadingReasons, setIsLoadingReasons] = useState(true);

  // New Reason State
  const [newReasonLabel, setNewReasonLabel] = useState('');
  const [isAddingReason, setIsAddingReason] = useState(false);

  // New User State
  const [newUser, setNewUser] = useState<{ email: string; fullName: string; password: string; role: 'ADMIN' | 'STAFF' }>({ email: '', fullName: '', password: '', role: 'STAFF' });
  const [isAddingUser, setIsAddingUser] = useState(false);
  const [userToDelete, setUserToDelete] = useState<string | null>(null);
  const [isLoadingUsers, setIsLoadingUsers] = useState(false);

  useEffect(() => {
    fetchCompany();
    fetchReasons();
    if (user?.role === 'ADMIN') {
      fetchUsersList();
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [user?.role]);

  const fetchUsersList = async () => {
    try {
      setIsLoadingUsers(true);
      const res = await usersApi.getUsers(getToken()!);
      setUsersList(res);
    } catch(e) { console.error(e); } finally { setIsLoadingUsers(false); }
  };

  const fetchCompany = async () => {
    try {
      setIsLoadingCompany(true);
      const res = await settingsApi.getCompanySettings(getToken()!);
      setCompany(res);
    } catch(e) { console.error(e) } finally { setIsLoadingCompany(false) }
  };

  const fetchReasons = async () => {
    try {
      setIsLoadingReasons(true);
      const res = await settingsApi.getCancelReasons(getToken()!);
      setReasons(res);
    } catch(e) { console.error(e) } finally { setIsLoadingReasons(false) }
  };

  const [reasonToDelete, setReasonToDelete] = useState<string | null>(null);

  const confirmDeleteReason = async () => {
    if (!reasonToDelete) return;
    try {
      await settingsApi.deleteCancelReason(getToken()!, reasonToDelete);
      toast.success('Đã xóa lý do thành công.');
      fetchReasons();
    } catch (e: any) {
      toast.error(e.message || 'Không thể xóa do rào cản dữ liệu.');
    } finally {
      setReasonToDelete(null);
    }
  };

  const handleAddUser = async () => {
    if (!newUser.email || !newUser.fullName || !newUser.password) {
      toast.error('Vui lòng nhập đầy đủ thông tin nhân sự.');
      return;
    }
    try {
      setIsAddingUser(true);
      await usersApi.createUser(getToken()!, newUser);
      toast.success('Đã thêm nhân sự thành công.');
      setNewUser({ email: '', fullName: '', password: '', role: 'STAFF' });
      fetchUsersList();
    } catch (e: any) {
      toast.error(e.message || 'Lỗi thêm nhân sự.');
    } finally {
      setIsAddingUser(false);
    }
  };

  const confirmDeleteUser = async () => {
    if (!userToDelete) return;
    try {
      await usersApi.deleteUser(getToken()!, userToDelete);
      toast.success('Đã xóa nhân sự.');
      fetchUsersList();
    } catch (e: any) {
      toast.error(e.message || 'Lỗi xóa nhân sự.');
    } finally {
      setUserToDelete(null);
    }
  };

  const toggleUserRole = async (u: User) => {
    if (u.id === user?.id) {
      toast.error('Bạn không thể tự đổi quyền của chính mình.');
      return;
    }
    const newRole = u.role === 'ADMIN' ? 'STAFF' : 'ADMIN';
    try {
      await usersApi.updateUserRole(getToken()!, u.id, newRole);
      toast.success('Đã cập nhật quyền.');
      fetchUsersList();
    } catch (e: any) {
      toast.error(e.message || 'Lỗi cập nhật quyền.');
    }
  };

  const handleSaveCompany = async () => {
    if (!company) return;
    try {
      setIsSavingCompany(true);
      await settingsApi.updateCompanySettings(getToken()!, {
        name: company.name,
        address: company.address,
        phone: company.phone,
        email: company.email,
        taxCode: company.taxCode,
        bankInfo: company.bankInfo,
        invoiceFooter: company.invoiceFooter,
      });
      toast.success('Cập nhật cấu hình thành công!');
    } catch (e: any) {
      toast.error(e.message || 'Hệ thống gián đoạn khi lưu.');
    } finally {
      setIsSavingCompany(false);
    }
  };

  const handleAddReason = async () => {
    if (!newReasonLabel.trim()) return;
    try {
      setIsAddingReason(true);
      await settingsApi.createCancelReason(getToken()!, {
        label: newReasonLabel,
        sortOrder: reasons.length,
        isActive: true,
      });
      setNewReasonLabel('');
      toast.success('Đã thêm lý do mới.');
      fetchReasons();
    } catch (e: any) {
      toast.error(e.message || 'Lỗi thêm lý do mới.');
    } finally {
      setIsAddingReason(false);
    }
  };

  const toggleReasonState = async (r: CancelReason) => {
    try {
      await settingsApi.updateCancelReason(getToken()!, r.id, { isActive: !r.isActive });
      fetchReasons();
    } catch (e: any) { 
      toast.error(e.message); 
    }
  };

  const handleDeleteReason = (id: string) => {
    setReasonToDelete(id);
  };

  const tabs = [
    { key: 'general' as const, label: 'Thông tin Cửa hàng', icon: FileText, description: 'Dữ liệu in hoá đơn' },
    { key: 'reasons' as const, label: 'Lý do Huỷ / Hoàn đơn', icon: ListChecks, description: 'Danh mục lý do' },
    ...(user?.role === 'ADMIN' ? [{ key: 'users' as const, label: 'Quản lý nhân sự', icon: UsersIcon, description: 'Phân quyền tài khoản' }] : []),
  ];

  return (
    <div className="flex flex-col gap-6 pb-10">
      {/* Page Header */}
      <div className="flex items-center gap-3">
        <div className="p-2.5 bg-primary/10 rounded-xl">
          <Settings className="h-6 w-6 text-primary" />
        </div>
        <div>
          <h1 className="text-3xl font-bold tracking-tight text-foreground">Cài đặt Hệ thống</h1>
          <p className="text-muted-foreground text-sm mt-0.5">Quản lý cấu hình in hoá đơn và các danh mục cốt lõi của CMS.</p>
        </div>
      </div>

      {/* Tab Navigation + Content */}
      <div className="flex flex-col md:flex-row gap-6">
        {/* Sidebar Tabs */}
        <div className="w-full md:w-[260px] shrink-0">
          <Card className="shadow-sm border-muted/50 overflow-hidden">
            <CardContent className="p-2">
              <nav className="flex flex-col gap-1">
                {tabs.map((tab) => {
                  const Icon = tab.icon;
                  const isActive = activeTab === tab.key;
                  return (
                    <button
                      key={tab.key}
                      onClick={() => setActiveTab(tab.key)}
                      className={`flex items-center gap-3 w-full rounded-lg px-3.5 py-3 text-left transition-all duration-200 group ${
                        isActive
                          ? 'bg-primary/10 text-primary shadow-sm'
                          : 'text-muted-foreground hover:bg-muted/50 hover:text-foreground'
                      }`}
                    >
                      <div className={`p-1.5 rounded-md transition-colors ${
                        isActive ? 'bg-primary/15' : 'bg-muted group-hover:bg-muted-foreground/10'
                      }`}>
                        <Icon className="h-4 w-4" />
                      </div>
                      <div className="flex-1 min-w-0">
                        <div className={`text-sm font-medium leading-tight ${isActive ? 'text-primary' : ''}`}>{tab.label}</div>
                        <div className="text-xs text-muted-foreground mt-0.5 truncate">{tab.description}</div>
                      </div>
                    </button>
                  );
                })}
              </nav>
            </CardContent>
          </Card>
        </div>

        {/* Content Area */}
        <div className="flex-1 min-w-0">
          {/* General Tab */}
          {activeTab === 'general' && (
            <Card className="glass shadow-sm border-muted/50 overflow-hidden">
              <CardHeader className="bg-muted/30 border-b py-5">
                <CardTitle className="text-lg flex items-center gap-2">
                  <FileText className="h-5 w-5 text-primary" />
                  Thông tin In Hoá Đơn
                </CardTitle>
                <CardDescription>Các thông tin dưới đây sẽ được hiển thị trên tiêu đề và chân trang của mẫu in hoá đơn K80/A4.</CardDescription>
              </CardHeader>
              <CardContent className="pt-6">
                {isLoadingCompany ? (
                  <div className="p-8 text-center">
                    <Loader2 className="h-6 w-6 animate-spin text-muted-foreground mx-auto" />
                    <p className="text-sm text-muted-foreground mt-2">Đang tải cấu hình...</p>
                  </div>
                ) : company ? (
                  <div className="space-y-8">
                    {/* Thông tin cơ bản */}
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
                      <div className="space-y-2">
                        <Label className="font-medium">Tên cửa hàng / Công ty <span className="text-destructive">*</span></Label>
                        <Input value={company.name} onChange={e => setCompany({...company, name: e.target.value})} className="h-10" />
                      </div>
                      <div className="space-y-2">
                        <Label className="font-medium">Số điện thoại Hotline</Label>
                        <Input value={company.phone || ''} onChange={e => setCompany({...company, phone: e.target.value})} className="h-10" />
                      </div>
                      <div className="space-y-2">
                        <Label className="font-medium">Email</Label>
                        <Input value={company.email || ''} onChange={e => setCompany({...company, email: e.target.value})} className="h-10" />
                      </div>
                      <div className="space-y-2">
                        <Label className="font-medium">Mã số thuế</Label>
                        <Input value={company.taxCode || ''} onChange={e => setCompany({...company, taxCode: e.target.value})} className="h-10" />
                      </div>
                    </div>

                    <div className="border-t border-muted/50" />

                    {/* Thông tin mở rộng */}
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
                      <div className="space-y-2">
                        <Label className="font-medium">Địa chỉ hạch toán</Label>
                        <Textarea 
                          rows={3} 
                          value={company.address || ''} 
                          onChange={e => setCompany({...company, address: e.target.value})} 
                          className="resize-none"
                        />
                      </div>
                      <div className="space-y-2">
                        <Label className="font-medium">Thông tin chuyển khoản (Bank Info)</Label>
                        <Textarea 
                          rows={3} 
                          value={company.bankInfo || ''} 
                          onChange={e => setCompany({...company, bankInfo: e.target.value})} 
                          placeholder="VD: MBBank - 123456789 - NGUYEN VAN A"
                          className="resize-none"
                        />
                      </div>
                      <div className="md:col-span-2 space-y-2">
                        <Label className="font-medium">Ghi chú chân trang (Invoice Footer)</Label>
                        <Textarea 
                          rows={2} 
                          value={company.invoiceFooter || ''} 
                          onChange={e => setCompany({...company, invoiceFooter: e.target.value})} 
                          placeholder="Cảm ơn quý khách đã mua sắm!"
                          className="resize-none"
                        />
                      </div>
                    </div>

                    <div className="border-t border-muted/50 pt-4 flex justify-end">
                      <Button onClick={handleSaveCompany} disabled={isSavingCompany || !company.name} className="px-6 h-10 font-semibold shadow-md hover:shadow-lg transition-all duration-200">
                        {isSavingCompany ? <Loader2 className="mr-2 h-4 w-4 animate-spin" /> : <Save className="mr-2 h-4 w-4" />}
                        Lưu thay đổi cấu hình
                      </Button>
                    </div>
                  </div>
                ) : null}
              </CardContent>
            </Card>
          )}

          {/* Reasons Tab */}
          {activeTab === 'reasons' && (
            <Card className="glass shadow-sm border-muted/50 overflow-hidden">
              <CardHeader className="bg-muted/30 border-b py-5">
                <CardTitle className="text-lg flex items-center gap-2">
                  <ListChecks className="h-5 w-5 text-primary" />
                  Danh mục Lý do Huỷ / Hoàn trả
                </CardTitle>
                <CardDescription>Cung cấp các lựa chọn nhanh cho nhân viên khi xử lý trả hàng hoặc huỷ đơn (VD: Khách đổi ý, Sai thông tin...).</CardDescription>
              </CardHeader>
              <CardContent className="pt-6">
                <div className="flex items-center gap-3 mb-6">
                  <div className="relative flex-1 max-w-sm">
                    <Input 
                      placeholder="Nhập lý do mới..." 
                      value={newReasonLabel} 
                      onChange={e => setNewReasonLabel(e.target.value)} 
                      onKeyDown={e => e.key === 'Enter' && handleAddReason()}
                      className="h-10"
                    />
                  </div>
                  <Button onClick={handleAddReason} disabled={!newReasonLabel.trim() || isAddingReason} className="h-10 px-4 font-semibold shadow-sm">
                    {isAddingReason ? <Loader2 className="h-4 w-4 animate-spin" /> : <Plus className="h-4 w-4 mr-1.5" />}
                    Thêm
                  </Button>
                </div>

                <div className="border rounded-lg overflow-hidden">
                  <Table>
                    <TableHeader className="bg-muted/50">
                      <TableRow>
                        <TableHead className="px-6 text-foreground font-semibold">Lý do hiển thị</TableHead>
                        <TableHead className="text-center w-[120px] text-foreground font-semibold">Trạng thái</TableHead>
                        <TableHead className="text-right w-[80px] px-6 text-foreground font-semibold">Xoá</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {isLoadingReasons ? (
                        <TableRow>
                          <TableCell colSpan={3} className="text-center py-8">
                            <Loader2 className="h-5 w-5 animate-spin text-muted-foreground mx-auto" />
                          </TableCell>
                        </TableRow>
                      ) : reasons.length === 0 ? (
                        <TableRow>
                          <TableCell colSpan={3} className="text-center py-8 text-muted-foreground">Chưa có lý do nào được thiết lập.</TableCell>
                        </TableRow>
                      ) : (
                        reasons.map(r => (
                          <TableRow key={r.id} className="hover:bg-muted/30 transition-colors">
                            <TableCell className="font-medium px-6">{r.label}</TableCell>
                            <TableCell className="text-center">
                              <div className="flex justify-center">
                                <Switch 
                                  checked={r.isActive} 
                                  onCheckedChange={() => toggleReasonState(r)}
                                />
                              </div>
                            </TableCell>
                            <TableCell className="text-right px-6">
                              <Button variant="ghost" size="sm" className="text-destructive h-8 w-8 p-0 hover:bg-destructive/10" onClick={() => handleDeleteReason(r.id)}>
                                <Trash2 className="h-4 w-4" />
                              </Button>
                            </TableCell>
                          </TableRow>
                        ))
                      )}
                    </TableBody>
                  </Table>
                </div>
                <p className="text-xs text-muted-foreground mt-4 italic">
                  * Mẹo: Các lý do ở trạng thái Tắt (Off) sẽ không hiển thị trong menu Huỷ đơn của nhân viên, nhưng vẫn bảo tồn log dữ liệu cho các đơn hàng cũ.
                </p>
              </CardContent>
            </Card>
          )}

          {/* Users Tab */}
          {activeTab === 'users' && user?.role === 'ADMIN' && (
            <Card className="glass shadow-sm border-muted/50 overflow-hidden">
              <CardHeader className="bg-muted/30 border-b py-5">
                <CardTitle className="text-lg flex items-center gap-2">
                  <UsersIcon className="h-5 w-5 text-primary" />
                  Quản lý Nhân sự (Phân quyền)
                </CardTitle>
                <CardDescription>Quản lý tài khoản đăng nhập hệ thống. Tài khoản Staff bị giới hạn khả năng xoá dữ liệu và phân quyền.</CardDescription>
              </CardHeader>
              <CardContent className="pt-6">
                <div className="flex flex-wrap items-center gap-3 mb-6 bg-muted/20 p-4 rounded-xl border border-border/50">
                  <div className="flex-1 min-w-[200px] space-y-1">
                    <Label className="text-xs">Họ và tên</Label>
                    <Input placeholder="Nhập họ tên..." value={newUser.fullName} onChange={e => setNewUser({...newUser, fullName: e.target.value})} className="h-9" />
                  </div>
                  <div className="flex-1 min-w-[200px] space-y-1">
                    <Label className="text-xs">Email đăng nhập</Label>
                    <Input placeholder="nhanvien@email.com" type="email" value={newUser.email} onChange={e => setNewUser({...newUser, email: e.target.value})} className="h-9" />
                  </div>
                  <div className="flex-1 min-w-[150px] space-y-1">
                    <Label className="text-xs">Mật khẩu</Label>
                    <Input type="password" placeholder="Mật khẩu..." value={newUser.password} onChange={e => setNewUser({...newUser, password: e.target.value})} className="h-9" />
                  </div>
                  <div className="pt-5 shrink-0">
                    <Button onClick={handleAddUser} disabled={!newUser.email || !newUser.fullName || !newUser.password || isAddingUser} className="h-9 px-4 shadow-sm">
                      {isAddingUser ? <Loader2 className="h-4 w-4 animate-spin" /> : <Plus className="h-4 w-4 mr-1.5" />}
                      Tạo tài khoản
                    </Button>
                  </div>
                </div>

                <div className="border rounded-lg overflow-hidden">
                  <Table>
                    <TableHeader className="bg-muted/50">
                      <TableRow>
                        <TableHead className="px-6 text-foreground font-semibold">Tài khoản</TableHead>
                        <TableHead className="text-center w-[150px] text-foreground font-semibold">Quyền (Role)</TableHead>
                        <TableHead className="text-right w-[80px] px-6 text-foreground font-semibold">Xoá</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {isLoadingUsers ? (
                        <TableRow>
                          <TableCell colSpan={3} className="text-center py-8">
                            <Loader2 className="h-5 w-5 animate-spin text-muted-foreground mx-auto" />
                          </TableCell>
                        </TableRow>
                      ) : usersList.length === 0 ? (
                        <TableRow>
                          <TableCell colSpan={3} className="text-center py-8 text-muted-foreground">Chưa có tài khoản nào được hiển thị.</TableCell>
                        </TableRow>
                      ) : (
                        usersList.map(u => (
                          <TableRow key={u.id} className="hover:bg-muted/30 transition-colors">
                            <TableCell className="px-6">
                              <div className="font-semibold text-sm">{u.fullName}</div>
                              <div className="text-xs text-muted-foreground">{u.email}</div>
                            </TableCell>
                            <TableCell className="text-center">
                              <Button 
                                variant={u.role === 'ADMIN' ? 'default' : 'outline'} 
                                size="sm" 
                                className={`h-7 px-3 text-xs w-[80px] ${u.role === 'ADMIN' ? 'bg-primary' : ''}`}
                                onClick={() => toggleUserRole(u)}
                              >
                                {u.role === 'ADMIN' ? 'Admin' : 'Staff'}
                              </Button>
                            </TableCell>
                            <TableCell className="text-right px-6">
                              <Button 
                                variant="ghost" 
                                size="sm" 
                                className="text-destructive h-8 w-8 p-0 hover:bg-destructive/10" 
                                onClick={() => setUserToDelete(u.id)}
                                disabled={u.id === user?.id} // Không tự xóa mình
                              >
                                <Trash2 className="h-4 w-4" />
                              </Button>
                            </TableCell>
                          </TableRow>
                        ))
                      )}
                    </TableBody>
                  </Table>
                </div>
              </CardContent>
            </Card>
          )}
        </div>
      </div>

      <AlertDialog open={!!reasonToDelete || !!userToDelete} onOpenChange={(open) => {
        if (!open) {
          setReasonToDelete(null);
          setUserToDelete(null);
        }
      }}>
        <AlertDialogContent className="glass sm:max-w-[425px]">
          <AlertDialogHeader>
            <AlertDialogTitle className="flex items-center text-destructive">
              <AlertCircle className="w-5 h-5 mr-2" />
              {reasonToDelete ? 'Xóa lý do?' : 'Xóa tài khoản nhân sự?'}
            </AlertDialogTitle>
            <AlertDialogDescription className="text-foreground/80">
              {reasonToDelete 
                ? 'Cảnh báo: Nếu lý do này đã được sử dụng trong các đơn hàng lịch sử, việc xóa nó có thể gây báo lỗi hiển thị. Khuyến nghị bạn quay lại và sử dụng trạng thái Tắt (Off) thay vì xóa. Bạn vẫn tiếp tục xóa?'
                : 'Bạn có chắc muốn xóa tài khoản này khỏi hệ thống? Hành động này không thể hoàn tác và user sẽ không thể đăng nhập được nữa.'}
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel className="hover:bg-muted/50 border-0 bg-transparent shadow-none">Hủy bỏ</AlertDialogCancel>
            <AlertDialogAction onClick={() => reasonToDelete ? confirmDeleteReason() : confirmDeleteUser()} className="bg-destructive text-destructive-foreground hover:bg-destructive/90">
              Xác nhận xóa
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}
