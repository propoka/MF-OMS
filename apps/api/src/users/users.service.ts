import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  async findByEmail(email: string) {
    return this.prisma.user.findUnique({
      where: { email },
    });
  }

  async findById(id: string) {
    return this.prisma.user.findUnique({
      where: { id },
      select: {
        id: true,
        email: true,
        fullName: true,
        role: true,
        isActive: true,
        createdAt: true,
      },
    });
  }

  async findAll() {
    return this.prisma.user.findMany({
      select: {
        id: true,
        email: true,
        fullName: true,
        role: true,
        isActive: true,
        createdAt: true,
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async updateRefreshToken(userId: string, hashedToken: string | null) {
    return this.prisma.user.update({
      where: { id: userId },
      data: { refreshTokenHash: hashedToken },
    });
  }

  async getRefreshTokenHash(userId: string): Promise<string | null> {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { refreshTokenHash: true },
    });
    return user?.refreshTokenHash || null;
  }

  async create(data: {
    email: string;
    fullName: string;
    passwordHash: string;
    role: any;
  }) {
    return this.prisma.user.create({
      data: {
        email: data.email,
        fullName: data.fullName,
        passwordHash: data.passwordHash,
        role: data.role,
      },
      select: {
        id: true,
        email: true,
        fullName: true,
        role: true,
        isActive: true,
        createdAt: true,
      },
    });
  }

  async updateRole(id: string, role: any) {
    return this.prisma.user.update({
      where: { id },
      data: { role },
      select: {
        id: true,
        email: true,
        fullName: true,
        role: true,
        isActive: true,
        createdAt: true,
      },
    });
  }

  async remove(id: string) {
    const user = await this.prisma.user.findUnique({
      where: { id },
      include: { _count: { select: { orders: true } } },
    });
    if (!user) throw new NotFoundException('Không tìm thấy người dùng');
    if (user._count.orders > 0) {
      throw new BadRequestException('Không thể xóa. Người dùng này đã khởi tạo đơn hàng. Vui lòng vô hiệu hóa thay vì xóa.');
    }

    return this.prisma.user.delete({
      where: { id },
    });
  }
}
