'use client';

import { useState, useRef, useEffect } from 'react';
import * as xlsx from 'xlsx';
import { crmApi, CustomerGroup } from '@/lib/api';
import { useAuth } from '@/lib/auth-context';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { Label } from '@/components/ui/label';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { Loader2, UploadCloud, AlertCircle, FileSpreadsheet } from 'lucide-react';
import { toast } from 'sonner';

interface ImportCustomerModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSuccess: () => void;
}

export default function ImportCustomerModal({ isOpen, onClose, onSuccess }: ImportCustomerModalProps) {
  const { getToken } = useAuth();
  const fileInputRef = useRef<HTMLInputElement>(null);
  
  const [groups, setGroups] = useState<CustomerGroup[]>([]);
  const [groupId, setGroupId] = useState('');
  const [file, setFile] = useState<File | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState('');

  // Load Groups
  useEffect(() => {
    if (isOpen && groups.length === 0) {
      crmApi.getGroups(getToken()!)
        .then(res => {
          setGroups(res);
          const def = res.find(g => g.isDefault);
          if (def) setGroupId(def.id);
          else if (res.length > 0) setGroupId(res[0].id);
        })
        .catch(console.error);
    }
  }, [isOpen, groups.length, getToken]);

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const f = e.target.files?.[0];
    if (f) setFile(f);
  };

  const handleImport = async () => {
    if (!file || !groupId) return;
    
    setError('');
    setIsSubmitting(true);
    
    try {
      const data = await file.arrayBuffer();
      const workbook = xlsx.read(data);
      const worksheet = workbook.Sheets[workbook.SheetNames[0]];
      const jsonData = xlsx.utils.sheet_to_json<any>(worksheet);

      const customers = jsonData.map(row => ({
        fullName: String(row['Họ và tên'] ?? row['Tên'] ?? row.fullName ?? '').trim(),
        phone: String(row['Số điện thoại'] ?? row['SĐT'] ?? row.phone ?? '').trim(),
        groupId,
      })).filter(c => c.fullName && c.phone); // Filter valid rows

      if (customers.length === 0) {
        throw new Error("Không tìm thấy dữ liệu hợp lệ trong file Excel. Vui lòng kiểm tra lại cấu trúc cột 'Họ và tên', 'Số điện thoại'.");
      }

      const res = await crmApi.importCustomers(getToken()!, customers as any);
      toast.success((res as any).message || `Trích xuất dữ liệu ${customers.length} hồ sơ hoàn tất!`);
      
      setFile(null);
      if (fileInputRef.current) fileInputRef.current.value = '';
      onSuccess();
    } catch (err: any) {
      setError(err.message || 'Lỗi xử lý file Excel');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <Dialog open={isOpen} onOpenChange={(open) => !open && onClose()}>
      <DialogContent className="glass sm:max-w-[450px]">
        <DialogHeader>
          <DialogTitle>Nhập Hồ sơ Khách hàng. (Từ Excel)</DialogTitle>
        </DialogHeader>
        
        <div className="space-y-6 py-4">
          {error && (
            <div className="p-3 bg-destructive/10 text-destructive text-sm rounded-md flex items-center gap-2">
              <AlertCircle className="h-4 w-4" />
              {error}
            </div>
          )}

          <div className="space-y-2">
            <Label>Nhóm khách hàng áp dụng</Label>
            <div className="text-xs text-muted-foreground pb-1">Tất cả khách hàng import sẽ được xếp vào nhóm này.</div>
            <Select disabled={isSubmitting} value={groupId} onValueChange={(v) => setGroupId(v || '')}>
              <SelectTrigger>
                <SelectValue placeholder="Chọn nhóm khách hàng..." />
              </SelectTrigger>
              <SelectContent>
                {groups.map(g => (
                  <SelectItem key={g.id} value={g.id}>{g.name}</SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          <div className="space-y-2">
            <Label>File dữ liệu (.xlsx, .csv)</Label>
            <div 
              className={`border-2 border-dashed rounded-lg p-6 flex flex-col items-center justify-center cursor-pointer transition-colors hover:bg-muted/50 ${file ? 'border-primary bg-primary/5' : 'border-muted-foreground/25'}`}
              onClick={() => fileInputRef.current?.click()}
            >
              <input 
                type="file" 
                ref={fileInputRef} 
                className="hidden" 
                accept=".xlsx, .xls, .csv" 
                onChange={handleFileChange}
              />
              {file ? (
                <>
                  <FileSpreadsheet className="h-10 w-10 text-primary mb-2" />
                  <span className="font-medium text-sm">{file.name}</span>
                  <span className="text-xs text-muted-foreground mt-1">{(file.size / 1024).toFixed(1)} KB</span>
                </>
              ) : (
                <>
                  <UploadCloud className="h-10 w-10 text-muted-foreground mb-2" />
                  <span className="font-medium text-sm">Bấm để chọn file dữ liệu</span>
                  <span className="text-xs text-muted-foreground mt-1 text-center">Các định dạng hỗ trợ: .xlsx, .xls, .csv<br/>Yêu cầu cột: "Họ và tên", "Số điện thoại"</span>
                </>
              )}
            </div>
          </div>
        </div>
        
        <DialogFooter>
          <Button type="button" variant="outline" onClick={onClose} disabled={isSubmitting} className="hover:bg-muted/50 border-0 bg-transparent shadow-none">
            Hủy bỏ
          </Button>
          <Button onClick={handleImport} disabled={isSubmitting || !file || !groupId}>
            {isSubmitting && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
            Tiến hành Lưu trữ
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
