import { Injectable, BadRequestException, InternalServerErrorException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class AdvancedService {
  constructor(private prisma: PrismaService) {}

  async deleteAllProducts() {
    const orderItemsCount = await this.prisma.orderItem.count();
    if (orderItemsCount > 0) {
      throw new BadRequestException('Vui lòng xóa tất cả Đơn hàng trước khi xóa Sản phẩm (ràng buộc dữ liệu).');
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
      throw new BadRequestException('Vui lòng xóa tất cả Đơn hàng trước khi xóa Khách hàng (ràng buộc dữ liệu).');
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
      throw new BadRequestException('Vui lòng xóa tất cả Khách hàng trước khi xóa Nhóm khách hàng (ràng buộc dữ liệu).');
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
      throw new BadRequestException('Vui lòng xóa tất cả Sản phẩm trước khi xóa Danh mục sản phẩm (ràng buộc dữ liệu).');
    }
    await this.prisma.productCategory.deleteMany();
    return {
      success: true,
      message: 'All product categories have been deleted.',
    };
  }

  async seedLocalData() {
    const fs = require('fs');
    const util = require('util');
    const exec = util.promisify(require('child_process').exec);

    try {
        let backupSql = '';
        
        // Cố gắng tải file backup từ Web server (ưu tiên)
        const webUrl = process.env.WEB_URL || 'http://localhost:3000';
        try {
            console.log(`Đang tải file backup từ: ${webUrl}/oms_db_backup.sql`);
            const res = await fetch(`${webUrl}/oms_db_backup.sql`);
            if (res.ok) {
                backupSql = await res.text();
            } else {
                throw new InternalServerErrorException('Tải file backup từ Web server thất bại — HTTP Status: ' + res.status);
            }
        } catch (fetchErr) {
            // Dự phòng: Môi trường Docker internal network
            try {
                console.log(`Tải file qua WEB_URL thất bại. Chuyển hướng nạp qua docker internal network http://web:3000/oms_db_backup.sql`);
                const resInternal = await fetch(`http://web:3000/oms_db_backup.sql`);
                if (resInternal.ok) {
                    backupSql = await resInternal.text();
                } else {
                     throw new InternalServerErrorException('Tải file backup từ Docker internal network thất bại — HTTP Status: ' + resInternal.status);
                }
            } catch (fallbackErr) {
                // Dự phòng cuối: Đọc từ thư mục gốc (áp dụng khi dev local)
                const path = require('path');
                const localPath = path.resolve(process.cwd(), '../web/public/oms_db_backup.sql');
                if (fs.existsSync(localPath)) {
                    backupSql = fs.readFileSync(localPath, 'utf8');
                } else {
                    throw new InternalServerErrorException(`Không thể tìm thấy hoặc tải file oms_db_backup.sql từ cả máy chủ Web, mạng nội bộ lẫn file tĩnh cục bộ.`);
                }
            }
        }

        const atomicSql = `
BEGIN;
DROP SCHEMA IF EXISTS public CASCADE;
DROP SCHEMA IF EXISTS shadow CASCADE;
CREATE SCHEMA public;
${backupSql}
COMMIT;
        `;
        
        const tempPath = '/tmp/atomic_restore.sql';
        fs.writeFileSync(tempPath, atomicSql, 'utf8');

        // Chạy trực tiếp psql (yêu cầu postgresql-client đã cài trong container)
        // Lược bỏ query parameter (như ?schema=public) khỏi DATABASE_URL vì psql không hỗ trợ
        const psqlUrl = process.env.DATABASE_URL?.split('?')[0] || '';
        const restoreCmd = `psql "${psqlUrl}" -v ON_ERROR_STOP=1 -f /tmp/atomic_restore.sql`;
        try {
            const { stdout, stderr } = await exec(restoreCmd);
            console.log('Phục hồi dữ liệu MySQL/PostgreSQL:', stdout);
            if (stderr) console.warn('Cảnh báo từ quá trình phục hồi:', stderr);
        } catch(restoreDbErr: any) {
            if (fs.existsSync(tempPath)) fs.unlinkSync(tempPath);
            throw new InternalServerErrorException(restoreDbErr.message || 'Lỗi huỷ ngang. Database đã an toàn Rollback!');
        }
        
        if (fs.existsSync(tempPath)) fs.unlinkSync(tempPath);

        // BẮT BUỘC THAY VÌ DISCONNECT: Khởi động lại toàn bộ tiến trình.
        // Tại sao? 
        // 1. Prisma Query Engine (viết bằng Rust) thường bị 'panicked' (chết yểu) khi Schema bị DROP ngang.
        //    Lệnh $disconnect() đôi khi không đủ sức cứu sống lõi Rust này.
        // 2. Chạy lại Container sẽ kích hoạt \`entrypoint.sh\`, qua đó chạy lại \`prisma migrate deploy\`
        //    để đắp thêm các Index/Bản vá mới nhất (mà file backup.sql cũ bị thiếu) vào DB vừa phục hồi!
        setTimeout(() => {
            console.log('Force restarting API container to refresh Prisma Engine and trigger migrations...');
            process.exit(0);
        }, 2000);

        return { 
            success: true, 
            message: `Tiến trình Phục hồi thành công tuyệt đối! Hệ thống API sẽ tự động khởi động lại sau 2 giây để đồng bộ cấu trúc mới.` 
        };
    } catch (err: any) {
        console.error('Lỗi khi nạp SQL:', err);
        throw new InternalServerErrorException('Lỗi Nạp Dữ Liệu SQL: ' + (err.stderr || err.message));
    }
  }
}
