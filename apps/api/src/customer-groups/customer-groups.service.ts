import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import {
  CreateCustomerGroupDto,
  UpdateCustomerGroupDto,
} from './dto/customer-group.dto';

@Injectable()
export class CustomerGroupsService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    return this.prisma.customerGroup.findMany({
      orderBy: { createdAt: 'desc' },
      include: {
        _count: {
          select: { customers: true },
        },
      },
    });
  }

  async findOne(id: string) {
    const group = await this.prisma.customerGroup.findUnique({
      where: { id },
      include: {
        _count: {
          select: { customers: true },
        },
      },
    });
    if (!group) throw new NotFoundException('Không tìm thấy nhóm khách hàng');
    return group;
  }

  async create(data: CreateCustomerGroupDto) {
    // Nếu tạo nhóm là mác định, cần bỏ mặc định các nhóm khác trước
    if (data.isDefault) {
      await this.prisma.customerGroup.updateMany({
        where: { isDefault: true },
        data: { isDefault: false },
      });
    }

    try {
      return await this.prisma.customerGroup.create({ data });
    } catch (e: any) {
      if (e.code === 'P2002')
        throw new BadRequestException('Tên nhóm đã tồn tại');
      throw e;
    }
  }

  async update(id: string, data: UpdateCustomerGroupDto) {
    const existing = await this.prisma.customerGroup.findUnique({
      where: { id },
    });
    if (!existing)
      throw new NotFoundException('Không tìm thấy nhóm khách hàng');

    if (data.isDefault && !existing.isDefault) {
      await this.prisma.customerGroup.updateMany({
        where: { isDefault: true, id: { not: id } },
        data: { isDefault: false },
      });
    }

    try {
      return await this.prisma.customerGroup.update({
        where: { id },
        data,
      });
    } catch (e: any) {
      if (e.code === 'P2002')
        throw new BadRequestException('Tên nhóm đã tồn tại');
      throw e;
    }
  }

  async remove(id: string) {
    const existing = await this.prisma.customerGroup.findUnique({
      where: { id },
      include: {
        _count: { select: { customers: true } },
      },
    });

    if (!existing)
      throw new NotFoundException('Không tìm thấy nhóm khách hàng');
    if (existing.isDefault)
      throw new BadRequestException('Không thể xoá nhóm khách hàng mặc định');
    if (existing._count.customers > 0)
      throw new BadRequestException(
        'Không thể xoá nhóm đang có khách hàng liên kết',
      );

    return this.prisma.customerGroup.delete({ where: { id } });
  }
}
