import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { PrismaService } from '../../prisma/prisma.service';

/**
 * AuditCleanupService — Tự động dọn dẹp bảng AuditLog
 * 
 * Chính sách: Xóa bản ghi audit cũ hơn 90 ngày.
 * Lịch: Chạy tự động lúc 3:00 AM mỗi ngày.
 * 
 * Mục đích: Ngăn bảng audit_logs phình to vô hạn,
 * cải thiện hiệu suất truy vấn và tiết kiệm dung lượng DB.
 */
@Injectable()
export class AuditCleanupService {
  private readonly logger = new Logger(AuditCleanupService.name);

  // Số ngày giữ lại log (mặc định 90 ngày)
  private readonly RETENTION_DAYS = 90;

  constructor(private readonly prisma: PrismaService) {}

  @Cron(CronExpression.EVERY_DAY_AT_3AM)
  async cleanupOldAuditLogs() {
    try {
      const cutoffDate = new Date();
      cutoffDate.setDate(cutoffDate.getDate() - this.RETENTION_DAYS);

      const result = await this.prisma.auditLog.deleteMany({
        where: {
          createdAt: { lt: cutoffDate },
        },
      });

      if (result.count > 0) {
        this.logger.log(
          `[AuditCleanup] Đã xóa ${result.count} bản ghi audit cũ hơn ${this.RETENTION_DAYS} ngày.`,
        );
      }
    } catch (error) {
      this.logger.error('[AuditCleanup] Lỗi khi dọn dẹp audit log:', error);
    }
  }
}
