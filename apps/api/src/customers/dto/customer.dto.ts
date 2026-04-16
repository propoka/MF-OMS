import { IsString, IsNotEmpty, IsOptional, IsBoolean, Matches } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

const phoneRegex = /(84|0[3|5|7|8|9])+([0-9]{8})\b/;

export class CreateCustomerDto {
  @ApiPropertyOptional({ example: 'KH129381' })
  @IsString()
  @IsOptional()
  code?: string;

  @ApiPropertyOptional({ example: '0987654321' })
  @IsString()
  @IsOptional()
  @Matches(phoneRegex, { message: 'Số điện thoại không hợp lệ (định dạng VN)' })
  phone?: string;

  @ApiProperty({ example: 'Nguyễn Văn A' })
  @IsString()
  @IsNotEmpty({ message: 'Tên khách hàng không được để trống' })
  fullName: string;

  @ApiProperty({ description: 'ID của nhóm khách hàng' })
  @IsString()
  @IsNotEmpty()
  groupId: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  provinceCode?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  provinceName?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  wardCode?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  wardName?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  addressDetail?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  notes?: string;

  @ApiPropertyOptional()
  @IsBoolean()
  @IsOptional()
  isActive?: boolean;
}

export class UpdateCustomerDto {
  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  @Matches(phoneRegex, { message: 'Số điện thoại không hợp lệ' })
  phone?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  fullName?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  groupId?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  provinceCode?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  provinceName?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  wardCode?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  wardName?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  addressDetail?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  notes?: string;

  @ApiPropertyOptional()
  @IsBoolean()
  @IsOptional()
  isActive?: boolean;
}
