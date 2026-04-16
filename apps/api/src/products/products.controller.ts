import { Controller, Get, Post, Body, Patch, Param, Delete, Query } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { ProductsService } from './products.service';
import { CreateProductDto, UpdateProductDto } from './dto/product.dto';
import { AuditLog } from '../common/decorators/audit-log.decorator';
import { Roles } from '../common/decorators/roles.decorator';
import { Role } from '@prisma/client';

@ApiTags('Products (Sản phẩm)')
@ApiBearerAuth()
@Controller('products')
export class ProductsController {
  constructor(private readonly productsService: ProductsService) {}

  @Get()
  @ApiOperation({ summary: 'Lấy list SP có phân trang & tìm kiếm' })
  @ApiQuery({ name: 'skip', required: false, type: Number })
  @ApiQuery({ name: 'take', required: false, type: Number })
  @ApiQuery({ name: 'search', required: false, type: String })
  findAll(
    @Query('skip') skip?: string,
    @Query('take') take?: string,
    @Query('search') search?: string,
  ) {
    return this.productsService.findAll({
      skip: skip ? parseInt(skip, 10) : 0,
      take: take ? parseInt(take, 10) : 50,
      search,
    });
  }

  @Get(':id')
  @ApiOperation({ summary: 'Chi tiết sản phẩm' })
  findOne(@Param('id') id: string) {
    return this.productsService.findOne(id);
  }

  @Get('next-sku/:categoryId')
  @ApiOperation({ summary: 'Lấy Mã SKU gợi ý tiếp theo cho một Danh mục' })
  async getNextSku(@Param('categoryId') categoryId: string) {
    const sku = await this.productsService.getNextSku(categoryId);
    return { sku };
  }

  @Post()
  @AuditLog('CREATE', 'Product')
  @ApiOperation({ summary: 'Tạo sản phẩm & set GroupPrice' })
  create(@Body() createProductDto: CreateProductDto) {
    return this.productsService.create(createProductDto);
  }

  @Post('import')
  @Roles(Role.ADMIN)
  @AuditLog('CREATE', 'Product')
  @ApiOperation({ summary: 'Import danh sách sản phẩm từ Excel (JSON payload)' })
  import(@Body() products: any[]) {
    return this.productsService.import(products);
  }

  @Patch(':id')
  @AuditLog('UPDATE', 'Product')
  @ApiOperation({ summary: 'Cập nhật sản phẩm & sửa GroupPrice' })
  update(@Param('id') id: string, @Body() updateProductDto: UpdateProductDto) {
    return this.productsService.update(id, updateProductDto);
  }

  @Delete(':id')
  @Roles(Role.ADMIN)
  @AuditLog('DELETE', 'Product')
  @ApiOperation({ summary: 'Xoá sản phẩm' })
  remove(@Param('id') id: string) {
    return this.productsService.remove(id);
  }
}
