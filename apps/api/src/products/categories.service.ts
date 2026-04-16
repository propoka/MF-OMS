import {
  Injectable,
  BadRequestException,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class CategoriesService {
  constructor(private prisma: PrismaService) {}

  async findAll() {
    return this.prisma.productCategory.findMany({
      orderBy: { name: 'asc' },
      include: {
        _count: {
          select: { products: true },
        },
      },
    });
  }

  async findOne(id: string) {
    const cat = await this.prisma.productCategory.findUnique({ where: { id } });
    if (!cat) throw new NotFoundException('Không tìm thấy danh mục');
    return cat;
  }

  async create(data: { name: string; code: string; description?: string }) {
    try {
      return await this.prisma.productCategory.create({
        data: {
          name: data.name,
          code: data.code.toUpperCase(),
          description: data.description,
        },
      });
    } catch (e: any) {
      if (e.code === 'P2002')
        throw new BadRequestException(
          'Tên danh mục hoặc mã tiền tố (code) đã tồn tại',
        );
      throw e;
    }
  }

  async update(
    id: string,
    data: { name?: string; code?: string; description?: string },
  ) {
    const cat = await this.findOne(id);
    try {
      return await this.prisma.productCategory.update({
        where: { id },
        data: {
          ...data,
          code: data.code ? data.code.toUpperCase() : undefined,
        },
      });
    } catch (e: any) {
      if (e.code === 'P2002')
        throw new BadRequestException(
          'Tên danh mục hoặc mã tiền tố (code) đã tồn tại',
        );
      throw e;
    }
  }

  async remove(id: string) {
    const existing = await this.prisma.productCategory.findUnique({
      where: { id },
      include: { _count: { select: { products: true } } },
    });

    if (!existing) throw new NotFoundException('Không tìm thấy danh mục');
    if (existing._count.products > 0) {
      throw new BadRequestException(
        'Danh mục này đã chứa sản phẩm, không thể xoá.',
      );
    }

    return this.prisma.productCategory.delete({ where: { id } });
  }

  async migrateOldSkus() {
    const products = await this.prisma.product.findMany({
      where: { categoryId: null },
    });

    let updatedCount = 0;
    const categoryCache: Record<string, string> = {}; // code -> id

    // Load existing categories into cache
    const existingCats = await this.prisma.productCategory.findMany();
    existingCats.forEach((c) => (categoryCache[c.code] = c.id));

    for (const product of products) {
      // RegEx bóc tách chữ và số, bỏ qua khoảng trắng, dấu gạch nối
      const match = product.sku.match(/^([a-zA-Z]+)[-_\s]*(\d+)$/);
      if (match) {
        const prefix = match[1].toUpperCase();

        let categoryId = categoryCache[prefix];

        if (!categoryId) {
          // Tạo mới danh mục
          const newCat = await this.prisma.productCategory.create({
            data: {
              name: prefix, // Tạm lấy code làm name, KH có thể sửa sau
              code: prefix,
            },
          });
          categoryId = newCat.id;
          categoryCache[prefix] = categoryId;
        }

        // Migrate product
        await this.prisma.product.update({
          where: { id: product.id },
          data: { categoryId },
        });
        updatedCount++;
      }
    }

    return { totalMigrated: updatedCount };
  }
}
