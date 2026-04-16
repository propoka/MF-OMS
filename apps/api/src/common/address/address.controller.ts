import { Controller, Get, Param } from '@nestjs/common';
import { ApiTags, ApiOperation } from '@nestjs/swagger';
import { AddressService } from './address.service';
import { Public } from '../decorators/public.decorator';

@ApiTags('Address (Địa chỉ hành chính)')
@Controller('address')
export class AddressController {
  constructor(private readonly addressService: AddressService) {}

  @Public()
  @Get('provinces')
  @ApiOperation({ summary: 'Lấy danh sách Tỉnh/Thành phố' })
  getProvinces() {
    return this.addressService.getProvinces();
  }

  @Public()
  @Get('provinces/:code/districts')
  @ApiOperation({ summary: 'Lấy danh sách Quận/Huyện theo mã Tỉnh/Thành' })
  getDistricts(@Param('code') code: string) {
    return this.addressService.getDistrictsByProvince(code);
  }
}
