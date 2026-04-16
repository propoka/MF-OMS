import { Controller, Get, Post, Body, Patch, Param, Delete } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { CategoriesService } from './categories.service';
import { AuditLog } from '../common/decorators/audit-log.decorator';
import { Roles } from '../common/decorators/roles.decorator';
import { Role } from '@prisma/client';

@ApiTags('Product Categories (Danh mục SP)')
@ApiBearerAuth()
@Controller('product-categories')
export class CategoriesController {
  constructor(private readonly categoriesService: CategoriesService) {}

  @Get()
  @ApiOperation({ summary: 'Lấy list danh mục sản phẩm' })
  findAll() {
    return this.categoriesService.findAll();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Chi tiết danh mục' })
  findOne(@Param('id') id: string) {
    return this.categoriesService.findOne(id);
  }

  @Post()
  @Roles(Role.ADMIN)
  @AuditLog('CREATE', 'ProductCategory')
  @ApiOperation({ summary: 'Tạo danh mục mới' })
  create(@Body() body: { name: string; code: string; description?: string }) {
    return this.categoriesService.create(body);
  }

  @Patch(':id')
  @Roles(Role.ADMIN)
  @AuditLog('UPDATE', 'ProductCategory')
  @ApiOperation({ summary: 'Cập nhật danh mục' })
  update(@Param('id') id: string, @Body() body: { name?: string; code?: string; description?: string }) {
    return this.categoriesService.update(id, body);
  }

  @Post('migrate-skus')
  @Roles(Role.ADMIN)
  @AuditLog('UPDATE', 'Product')
  @ApiOperation({ summary: 'Dùng Regex phân rã SKU cũ để tạo danh mục' })
  migrateOldSkus() {
    return this.categoriesService.migrateOldSkus();
  }

  @Delete(':id')
  @Roles(Role.ADMIN)
  @AuditLog('DELETE', 'ProductCategory')
  @ApiOperation({ summary: 'Xoá danh mục' })
  remove(@Param('id') id: string) {
    return this.categoriesService.remove(id);
  }
}
