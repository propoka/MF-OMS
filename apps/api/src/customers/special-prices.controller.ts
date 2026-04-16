import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Delete,
  NotFoundException,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { PrismaService } from '../prisma/prisma.service';
import { Roles } from '../common/decorators/roles.decorator';
import { Role } from '@prisma/client';
import { AuditLog } from '../common/decorators/audit-log.decorator';
import {
  IsString,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  Min,
} from 'class-validator';

export class SpecialPriceDto {
  @IsString() @IsNotEmpty() productId: string;
  @IsNumber() @Min(0) price: number;
  @IsOptional() @IsString() notes?: string;
}

@ApiTags('Customer Special Prices')
@ApiBearerAuth()
@Controller('customers/:customerId/special-prices')
export class CustomerSpecialPricesController {
  constructor(private readonly prisma: PrismaService) {}

  @Get()
  @ApiOperation({ summary: 'Lấy tất cả giá đặc biệt của 1 KH' })
  async findAll(@Param('customerId') customerId: string) {
    return this.prisma.customerSpecialPrice.findMany({
      where: { customerId },
      include: {
        product: {
          select: {
            id: true,
            name: true,
            sku: true,
            unit: true,
            retailPrice: true,
          },
        },
      },
    });
  }

  @Post()
  @Roles(Role.ADMIN)
  @AuditLog('CREATE', 'CustomerSpecialPrice')
  @ApiOperation({ summary: 'Tạo hoặc cập nhật giá đặc biệt (Upsert)' })
  async upsert(
    @Param('customerId') customerId: string,
    @Body() dto: SpecialPriceDto,
  ) {
    // Check product exists
    const product = await this.prisma.product.findUnique({
      where: { id: dto.productId },
    });
    if (!product) throw new NotFoundException('Không tìm thấy sản phẩm');

    return this.prisma.customerSpecialPrice.upsert({
      where: {
        customerId_productId: {
          customerId,
          productId: dto.productId,
        },
      },
      update: {
        price: dto.price,
        notes: dto.notes,
      },
      create: {
        customerId,
        productId: dto.productId,
        price: dto.price,
        notes: dto.notes,
      },
    });
  }

  @Delete(':productId')
  @Roles(Role.ADMIN)
  @AuditLog('DELETE', 'CustomerSpecialPrice')
  @ApiOperation({ summary: 'Xoá giá đặc biệt của 1 sản phẩm cho KH này' })
  remove(
    @Param('customerId') customerId: string,
    @Param('productId') productId: string,
  ) {
    return this.prisma.customerSpecialPrice.delete({
      where: {
        customerId_productId: { customerId, productId },
      },
    });
  }
}
