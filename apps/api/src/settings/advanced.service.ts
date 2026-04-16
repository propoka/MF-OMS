import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class AdvancedService {
  constructor(private prisma: PrismaService) {}

  async deleteAllProducts() {
    const orderItemsCount = await this.prisma.orderItem.count();
    if (orderItemsCount > 0) {
      throw new Error('Vui lòng xóa tất cả Đơn hàng trước khi xóa Sản phẩm (ràng buộc dữ liệu).');
    }
    await this.prisma.$transaction([
      this.prisma.productGroupPrice.deleteMany(),
      this.prisma.customerSpecialPrice.deleteMany(),
      this.prisma.product.deleteMany(),
    ]);
    return {
      success: true,
      message: 'All products and their prices have been deleted.',
    };
  }

  async deleteAllCustomers() {
    const ordersCount = await this.prisma.order.count();
    if (ordersCount > 0) {
      throw new Error('Vui lòng xóa tất cả Đơn hàng trước khi xóa Khách hàng (ràng buộc dữ liệu).');
    }
    await this.prisma.$transaction([
      this.prisma.customerSpecialPrice.deleteMany(),
      this.prisma.customer.deleteMany(),
    ]);
    return { success: true, message: 'All customers have been deleted.' };
  }

  async deleteAllOrders() {
    await this.prisma.$transaction([
      this.prisma.orderItem.deleteMany(),
      this.prisma.order.deleteMany(),
    ]);
    return { success: true, message: 'All orders have been deleted.' };
  }

  async deleteAllCustomerGroups() {
    const customersCount = await this.prisma.customer.count();
    if (customersCount > 0) {
      throw new Error('Vui lòng xóa tất cả Khách hàng trước khi xóa Nhóm khách hàng (ràng buộc dữ liệu).');
    }
    await this.prisma.$transaction([
      this.prisma.productGroupPrice.deleteMany(),
      this.prisma.customerGroup.deleteMany({ where: { isDefault: false } }),
    ]);
    return {
      success: true,
      message: 'All non-default customer groups have been deleted.',
    };
  }

  async deleteAllProductCategories() {
    const productsCount = await this.prisma.product.count();
    if (productsCount > 0) {
      throw new Error('Vui lòng xóa tất cả Sản phẩm trước khi xóa Danh mục sản phẩm (ràng buộc dữ liệu).');
    }
    await this.prisma.productCategory.deleteMany();
    return {
      success: true,
      message: 'All product categories have been deleted.',
    };
  }

  async seedLocalData() {
    const fs = require('fs');
    const path = require('path');
    const util = require('util');
    const exec = util.promisify(require('child_process').exec);
    
    // Fix đường dẫn file backup SQL
    const backupPath = path.resolve(process.cwd(), '../web/public/oms_db_backup.sql');
    
    if (!fs.existsSync(backupPath)) {
      throw new Error(`Không tìm thấy file backup tại: ${backupPath}. Vui lòng đảm bảo file oms_db_backup.sql đang ở thư mục apps/web/public.`);
    }

    try {
        // Thuật toán: Tạo ra 1 kịch bản ATOMIC TRANSACTION (Giao dịch nguyên tử).
        // Gom bộ 3 lệnh "Xoá + Xây Lại + Nạp" vào trong một khối BEGIN ... COMMIT duy nhất.
        // Nêu gặp lỗi, mọi thao tác (kể cả việc xoá Schema) sẽ bốc hơi và Rollback y nguyên.
        const backupSql = fs.readFileSync(backupPath, 'utf8');
        const atomicSql = `
BEGIN;
DROP SCHEMA IF EXISTS public CASCADE;
DROP SCHEMA IF EXISTS shadow CASCADE;
CREATE SCHEMA public;
${backupSql}
COMMIT;
        `;
        
        const tempPath = path.resolve(process.cwd(), '../web/public/temp_atomic_restore.sql');
        fs.writeFileSync(tempPath, atomicSql, 'utf8');

        // Copy file siêu kịch bản vào container
        const copyCmd = `docker cp "${tempPath}" mf_oms_postgres:/tmp/atomic_restore.sql`;
        await exec(copyCmd);

        // Chạy psql với cờ siêu nghiêm ngặt: -v ON_ERROR_STOP=1 (lỗi 1 chữ là huỷ toàn bộ)
        const restoreCmd = `docker exec mf_oms_postgres psql -U oms_user -d oms_db -v ON_ERROR_STOP=1 -f /tmp/atomic_restore.sql`;
        
        try {
            await exec(restoreCmd);
        } catch(restoreDbErr: any) {
            fs.unlinkSync(tempPath); // Xoá file rác
            throw new Error(restoreDbErr.message || 'Lỗi huỷ ngang. Database đã an toàn Rollback!');
        }
        
        fs.unlinkSync(tempPath); // Xoá file sau khi xong

        return { 
            success: true, 
            message: `Tiến trình Phục hồi thành công tuyệt đối! Đã bọc Transaction an toàn 100%.` 
        };
    } catch (err: any) {
        console.error('Lỗi khi nạp SQL:', err);
        throw new Error('Lỗi Nạp Dữ Liệu SQL: ' + (err.stderr || err.message));
    }
  }
}
