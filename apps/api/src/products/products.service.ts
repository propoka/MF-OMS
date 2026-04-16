import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
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
          category: { select: { name: true, code: true } },
          groupPrices: {
            include: { group: { select: { name: true } } },
          },
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
        category: true,
        groupPrices: true,
      },
    });
    if (!product) throw new NotFoundException('Không tìm thấy sản phẩm');
    return product;
  }

  async create(data: CreateProductDto) {
    const { groupPrices, categoryId, sku, ...productData } = data;
    try {
      if (!categoryId)
        throw new BadRequestException('Bắt buộc phải chọn danh mục sản phẩm');

      const category = await this.prisma.productCategory.findUnique({
        where: { id: categoryId },
      });
      if (!category) throw new NotFoundException('Không tìm thấy danh mục');

      let newSku = sku;

      // Nếu user không truyền SKU, tự auto-generate
      if (!newSku) {
        newSku = await this.getNextSku(categoryId);
      }

      return await this.prisma.product.create({
        data: {
          ...productData,
          sku: newSku,
          categoryId,
          groupPrices: groupPrices?.length
            ? {
                create: groupPrices
                  .filter(
                    (gp) =>
                      Number(gp.fixedPrice) !== Number(productData.retailPrice),
                  )
                  .map((gp) => ({
                    groupId: gp.groupId,
                    fixedPrice: gp.fixedPrice,
                  })),
              }
            : undefined,
        },
        include: { groupPrices: true, category: true },
      });
    } catch (e: any) {
      if (e.code === 'P2002')
        throw new BadRequestException('Mã SKU đã tồn tại');
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
          data: {
            ...productData,
            categoryId: data.categoryId,
          },
        });

        // Xử lý GroupPrices nếu được gửi kèm
        if (groupPrices !== undefined) {
          // Xoá hết giá nhóm cũ
          await tx.productGroupPrice.deleteMany({
            where: { productId: id },
          });

          // Tạo lại giá nhóm mới, BỎ QUA những nhóm bằng giá mốc (tránh rác DB)
          if (groupPrices.length > 0) {
            const validGroupPrices = groupPrices.filter(
              (gp) => Number(gp.fixedPrice) !== Number(updated.retailPrice),
            );

            if (validGroupPrices.length > 0) {
              await tx.productGroupPrice.createMany({
                data: validGroupPrices.map((gp) => ({
                  productId: id,
                  groupId: gp.groupId,
                  fixedPrice: gp.fixedPrice,
                })),
              });
            }
          }
        }

        // Lấy kết quả cuối
        return await tx.product.findUnique({
          where: { id },
          include: { groupPrices: true, category: true },
        });
      });
    } catch (e: any) {
      if (e.code === 'P2002')
        throw new BadRequestException('Mã SKU đã tồn tại');
      throw e;
    }
  }

  async remove(id: string) {
    const existing = await this.prisma.product.findUnique({
      where: { id },
      include: { _count: { select: { orderItems: true } } },
    });

    if (!existing) throw new NotFoundException('Không tìm thấy sản phẩm');
    if (existing._count.orderItems > 0) {
      throw new BadRequestException(
        'Sản phẩm đã có giao dịch mua bán, không thể xoá. Hãy chọn vô hiệu hoá (isActive = false).',
      );
    }

    return this.prisma.product.delete({ where: { id } });
  }

  async getNextSku(categoryId: string): Promise<string> {
    const category = await this.prisma.productCategory.findUnique({
      where: { id: categoryId },
    });
    if (!category) throw new NotFoundException('Không tìm thấy danh mục');

    const productsInCat = await this.prisma.product.findMany({
      where: { sku: { startsWith: category.code } },
      select: { sku: true },
    });

    let maxNumber = 0;
    productsInCat.forEach((p) => {
      const match = p.sku.match(/^([A-Z]+)(\d+)$/);
      if (match && match[1] === category.code) {
        const num = parseInt(match[2], 10);
        if (num > maxNumber) maxNumber = num;
      }
    });

    const nextNumber = maxNumber + 1;
    return `${category.code}${nextNumber.toString().padStart(2, '0')}`;
  }

  async import(
    products: {
      name: string;
      sku?: string;
      categoryCode: string;
      unit: string;
      retailPrice: number;
      weight?: number;
      dimensions?: string;
    }[],
  ) {
    let successCount = 0;
    let fallbackCategory = await this.prisma.productCategory.findFirst({
      where: { code: 'DEFAULT' },
    });
    if (!fallbackCategory) {
      fallbackCategory = await this.prisma.productCategory.create({
        data: { name: 'Chưa phân loại', code: 'DEFAULT' },
      });
    }

    const categories = await this.prisma.productCategory.findMany();
    const catMap = new Map(categories.map((c) => [c.code, c.id]));

    // Lọc bỏ dữ liệu rác (tên rỗng, giá âm, không có danh mục)
    const validProducts = products.filter(
      (p) =>
        p.name &&
        p.unit &&
        typeof p.retailPrice === 'number' &&
        p.retailPrice >= 0 &&
        p.categoryCode,
    );

    const invalidCount = products.length - validProducts.length;

    for (const p of validProducts) {
      const catId = catMap.get(p.categoryCode) || fallbackCategory.id;
      let skuToUse = p.sku;
      if (!skuToUse) {
        skuToUse = await this.getNextSku(catId);
      }

      try {
        await this.prisma.product.create({
          data: {
            name: p.name,
            sku: skuToUse,
            categoryId: catId,
            unit: p.unit,
            retailPrice: p.retailPrice,
            weight: p.weight,
            dimensions: p.dimensions,
            isActive: true,
          },
        });
        successCount++;
      } catch (e: any) {
        // Skip on duplicate SKU
        // In real app we might log this or return errors array
      }
    }
    return {
      successCount,
      totalTried: validProducts.length,
      invalidCount, // trả về thêm cho front-end nếu cần
    };
  }
}
