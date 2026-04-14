import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateProductDto, UpdateProductDto } from './dto/product.dto';
import { Prisma } from '@prisma/client';

@Injectable()
export class ProductsService {
  constructor(private prisma: PrismaService) {}

  async findAll(query: { skip?: number; take?: number; search?: string }) {
    const { skip = 0, take = 50, search } = query;
    const where: Prisma.ProductWhereInput = {};

    if (search) {
      where.OR = [
        { name: { contains: search, mode: 'insensitive' } },
        { sku: { contains: search, mode: 'insensitive' } },
      ];
    }

    const [total, data] = await Promise.all([
      this.prisma.product.count({ where }),
      this.prisma.product.findMany({
        where,
        skip: Number(skip),
        take: Number(take),
        include: {
          groupPrices: {
            include: { group: { select: { name: true } } }
          }
        },
        orderBy: { createdAt: 'desc' },
      }),
    ]);

    return { total, data };
  }

  async findOne(id: string) {
    const product = await this.prisma.product.findUnique({
      where: { id },
      include: {
        groupPrices: true,
      },
    });
    if (!product) throw new NotFoundException('Không tìm thấy sản phẩm');
    return product;
  }

  async create(data: CreateProductDto) {
    const { groupPrices, ...productData } = data;
    try {
      return await this.prisma.product.create({
        data: {
          ...productData,
          groupPrices: groupPrices?.length ? {
            create: groupPrices.map(gp => ({
              groupId: gp.groupId,
              fixedPrice: gp.fixedPrice,
            }))
          } : undefined
        },
        include: { groupPrices: true }
      });
    } catch (e: any) {
      if (e.code === 'P2002') throw new BadRequestException('Mã SKU đã tồn tại');
      throw e;
    }
  }

  async update(id: string, data: UpdateProductDto) {
    const existing = await this.prisma.product.findUnique({ where: { id } });
    if (!existing) throw new NotFoundException('Không tìm thấy sản phẩm');

    const { groupPrices, ...productData } = data;

    try {
      return await this.prisma.$transaction(async (tx) => {
        // Cập nhật giá trị cơ bản của Product
        const updated = await tx.product.update({
          where: { id },
          data: productData,
        });

        // Xử lý GroupPrices nếu được gửi kèm
        if (groupPrices !== undefined) {
          // Xoá hết giá nhóm cũ
          await tx.productGroupPrice.deleteMany({
            where: { productId: id }
          });
          
          // Tạo lại giá nhóm mới
          if (groupPrices.length > 0) {
            await tx.productGroupPrice.createMany({
              data: groupPrices.map(gp => ({
                productId: id,
                groupId: gp.groupId,
                fixedPrice: gp.fixedPrice,
              }))
            });
          }
        }

        // Lấy kết quả cuối
        return await tx.product.findUnique({
          where: { id },
          include: { groupPrices: true }
        });
      });
    } catch (e: any) {
      if (e.code === 'P2002') throw new BadRequestException('Mã SKU đã tồn tại');
      throw e;
    }
  }

  async remove(id: string) {
    const existing = await this.prisma.product.findUnique({
      where: { id },
      include: { _count: { select: { orderItems: true } } }
    });
    
    if (!existing) throw new NotFoundException('Không tìm thấy sản phẩm');
    if (existing._count.orderItems > 0) {
      throw new BadRequestException('Sản phẩm đã có giao dịch mua bán, không thể xoá. Hãy chọn vô hiệu hoá (isActive = false).');
    }

    return this.prisma.product.delete({ where: { id } });
  }
}
