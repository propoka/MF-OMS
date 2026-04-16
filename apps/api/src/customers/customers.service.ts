import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateCustomerDto, UpdateCustomerDto } from './dto/customer.dto';
import { Prisma } from '@prisma/client';

@Injectable()
export class CustomersService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(query: { skip?: number; take?: number; search?: string; groupId?: string }) {
    const { skip = 0, take = 50, search, groupId } = query;
    const where: Prisma.CustomerWhereInput = {};

    if (search) {
      where.OR = [
        { fullName: { contains: search, mode: 'insensitive' } },
        { phone: { contains: search } },
        { code: { contains: search, mode: 'insensitive' } },
      ];
    }

    if (groupId) {
      where.groupId = groupId;
    }

    const [total, customers] = await Promise.all([
      this.prisma.customer.count({ where }),
      this.prisma.customer.findMany({
        where,
        skip: Number(skip),
        take: Number(take),
        include: {
          group: { select: { name: true, discountPercent: true, priceType: true } },
          orders: {
            where: { deliveryStatus: { notIn: ['CANCELLED', 'RETURNED'] } },
            select: { totalAmount: true },
          },
        },
        orderBy: { createdAt: 'desc' },
      }),
    ]);

    // Tính toán doanh số
    const data = customers.map((c) => {
      const { orders, ...rest } = c;
      const totalRevenue = orders.reduce(
        (sum, o) => sum + Number(o.totalAmount),
        0,
      );
      return {
        ...rest,
        totalRevenue,
      };
    });

    return { total, data };
  }

  async findOne(id: string) {
    const customer = await this.prisma.customer.findUnique({
      where: { id },
      include: {
        group: true,
        orders: {
          where: { deliveryStatus: { notIn: ['CANCELLED', 'RETURNED'] } },
          select: { 
            id: true,
            orderNumber: true,
            deliveryStatus: true,
            subtotal: true,
            totalAmount: true, 
            createdAt: true
          },
          orderBy: { createdAt: 'desc' },
        },
      },
    });

    if (!customer) throw new NotFoundException('Không tìm thấy khách hàng');

    const { orders, ...rest } = customer;
    const totalRevenue = orders.reduce(
      (sum, o) => sum + Number(o.totalAmount),
      0,
    );

    return { ...rest, orders, totalRevenue };
  }

  async create(data: CreateCustomerDto) {
    try {
      const phoneToSave = data.phone && data.phone.trim() !== '' ? data.phone.trim() : null;
      let targetCode = data.code;
      
      if (!targetCode) {
        let isUnique = false;
        while (!isUnique) {
          const rnd = Math.floor(100000 + Math.random() * 900000).toString();
          targetCode = `KH${rnd}`;
          const existing = await this.prisma.customer.findUnique({ where: { code: targetCode } });
          if (!existing) isUnique = true;
        }
      }

      return await this.prisma.customer.create({
        data: {
          ...data,
          phone: phoneToSave,
          code: targetCode!,
        }
      });
    } catch (e: any) {
      if (e.code === 'P2002') {
        throw new BadRequestException('Số điện thoại này đã được đăng ký.');
      }
      throw e;
    }
  }

  async import(data: CreateCustomerDto[]) {
    if (!data || data.length === 0) {
      throw new BadRequestException('Không có dữ liệu import');
    }

    try {
      // Prisma createMany skipDuplicates is useful here
      const result = await this.prisma.customer.createMany({
        data: data.map(d => ({
          phone: d.phone,
          fullName: d.fullName,
          groupId: d.groupId,
          provinceCode: d.provinceCode,
          provinceName: d.provinceName,
          wardCode: d.wardCode,
          wardName: d.wardName,
          addressDetail: d.addressDetail,
          notes: d.notes,
          isActive: d.isActive !== undefined ? d.isActive : true
        })),
        skipDuplicates: true, // Ignore duplicates instead of crashing
      });

      return {
        message: `Đã import thành công ${result.count} khách hàng`,
        importedCount: result.count
      };
    } catch (e: any) {
      throw new BadRequestException('Lỗi import dữ liệu: ' + e.message);
    }
  }

  async update(id: string, data: UpdateCustomerDto) {
    const existing = await this.prisma.customer.findUnique({ where: { id } });
    if (!existing) throw new NotFoundException('Không tìm thấy khách hàng');

    try {
      const phoneToSave = data.phone && data.phone.trim() !== '' ? data.phone.trim() : (data.phone === '' ? null : undefined);
      
      return await this.prisma.customer.update({
        where: { id },
        data: {
          ...data,
          ...(phoneToSave !== undefined && { phone: phoneToSave })
        },
      });
    } catch (e: any) {
      if (e.code === 'P2002') {
        throw new BadRequestException('Số điện thoại này đã tồn tại ở hồ sơ khác.');
      }
      throw e;
    }
  }

  async remove(id: string) {
    const existing = await this.prisma.customer.findUnique({
      where: { id },
      include: { _count: { select: { orders: true } } },
    });

    if (!existing) throw new NotFoundException('Không tìm thấy khách hàng');
    
    // Nếu đã có đơn hàng thì không xoá cứng để bảo toàn dữ liệu
    if (existing._count.orders > 0) {
      throw new BadRequestException(
        'Khách hàng này đã có đơn hàng. Vui lòng vô hiệu hoá (Inactive) thay vì xoá.',
      );
    }

    return this.prisma.customer.delete({ where: { id } });
  }
}
