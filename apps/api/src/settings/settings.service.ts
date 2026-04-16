import {
  Injectable,
  BadRequestException,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class SettingsService {
  constructor(private prisma: PrismaService) {}

  // ─── Company Settings ─────────────────────────────────────────

  async getCompanySettings() {
    let settings = await this.prisma.companySettings.findFirst();
    if (!settings) {
      settings = await this.prisma.companySettings.create({
        data: {
          name: 'MF Company',
          address: '123 Enterprise St',
          phone: '0123456789',
        },
      });
    }
    return settings;
  }

  async updateCompanySettings(data: any) {
    const settings = await this.getCompanySettings();
    return this.prisma.companySettings.update({
      where: { id: settings.id },
      data,
    });
  }

  // ─── Cancel Reasons ───────────────────────────────────────────

  async getCancelReasons() {
    return this.prisma.cancelReason.findMany({
      orderBy: { sortOrder: 'asc' },
    });
  }

  async createCancelReason(data: {
    label: string;
    sortOrder?: number;
    isActive?: boolean;
  }) {
    try {
      return await this.prisma.cancelReason.create({ data });
    } catch (e: any) {
      if (e.code === 'P2002') {
        throw new BadRequestException('Tên lý do huỷ đã tồn tại.');
      }
      throw e;
    }
  }

  async updateCancelReason(
    id: string,
    data: Partial<{ label: string; sortOrder: number; isActive: boolean }>,
  ) {
    const existing = await this.prisma.cancelReason.findUnique({
      where: { id },
    });
    if (!existing) throw new NotFoundException('Không tìm thấy lý do huỷ');
    try {
      return await this.prisma.cancelReason.update({
        where: { id },
        data,
      });
    } catch (e: any) {
      if (e.code === 'P2002') {
        throw new BadRequestException('Tên lý do huỷ đã tồn tại.');
      }
      throw e;
    }
  }

  async deleteCancelReason(id: string) {
    const existing = await this.prisma.cancelReason.findUnique({
      where: { id },
      include: { _count: { select: { orders: true } } },
    });
    if (!existing) throw new NotFoundException('Không tìm thấy lý do huỷ');
    if (existing._count.orders > 0) {
      throw new BadRequestException(
        `Lý do "${existing.label}" đang được sử dụng bởi ${existing._count.orders} đơn hàng. Hãy vô hiệu hoá thay vì xoá.`,
      );
    }
    return this.prisma.cancelReason.delete({ where: { id } });
  }
}
