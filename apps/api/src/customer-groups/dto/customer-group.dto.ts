import { IsString, IsNotEmpty, IsEnum, IsNumber, Min, Max, IsBoolean, IsOptional } from 'class-validator';
import { GroupPriceType } from '@prisma/client';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateCustomerGroupDto {
  @ApiProperty({ example: 'Khách VIP' })
  @IsString()
  @IsNotEmpty({ message: 'Tên nhóm không được để trống' })
  name: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  description?: string;

  @ApiPropertyOptional({ enum: GroupPriceType, default: GroupPriceType.PERCENTAGE })
  @IsEnum(GroupPriceType)
  @IsOptional()
  priceType?: GroupPriceType;

  @ApiPropertyOptional({ example: 10, description: 'Giảm 10% so với giá lẻ' })
  @IsNumber()
  @Min(0)
  @Max(100)
  @IsOptional()
  discountPercent?: number;

  @ApiPropertyOptional({ default: false })
  @IsBoolean()
  @IsOptional()
  isDefault?: boolean;
}

export class UpdateCustomerGroupDto {
  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  name?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  description?: string;

  @ApiPropertyOptional({ enum: GroupPriceType })
  @IsEnum(GroupPriceType)
  @IsOptional()
  priceType?: GroupPriceType;

  @ApiPropertyOptional()
  @IsNumber()
  @Min(0)
  @Max(100)
  @IsOptional()
  discountPercent?: number;

  @ApiPropertyOptional()
  @IsBoolean()
  @IsOptional()
  isDefault?: boolean;
}
