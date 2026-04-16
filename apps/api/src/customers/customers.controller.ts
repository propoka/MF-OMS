import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  Query,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiBearerAuth,
  ApiQuery,
} from '@nestjs/swagger';
import { CustomersService } from './customers.service';
import { CreateCustomerDto, UpdateCustomerDto } from './dto/customer.dto';
import { AuditLog } from '../common/decorators/audit-log.decorator';
import { Roles } from '../common/decorators/roles.decorator';
import { Role } from '@prisma/client';

@ApiTags('Customers (Khách hàng)')
@ApiBearerAuth()
@Controller('customers')
export class CustomersController {
  constructor(private readonly customersService: CustomersService) {}

  @Get()
  @ApiOperation({
    summary: 'Lấy filter danh sách khách hàng (có phân trang & công nợ)',
  })
  @ApiQuery({ name: 'skip', required: false, type: Number })
  @ApiQuery({ name: 'take', required: false, type: Number })
  @ApiQuery({
    name: 'search',
    required: false,
    type: String,
    description: 'SĐT hoặc Tên',
  })
  @ApiQuery({ name: 'groupId', required: false, type: String })
  findAll(
    @Query('skip') skip?: string,
    @Query('take') take?: string,
    @Query('search') search?: string,
    @Query('groupId') groupId?: string,
  ) {
    return this.customersService.findAll({
      skip: skip ? parseInt(skip, 10) : 0,
      take: take ? parseInt(take, 10) : 50,
      search,
      groupId,
    });
  }

  @Get(':id')
  @ApiOperation({ summary: 'Lấy chi tiết hồ sơ 1 khách hàng' })
  findOne(@Param('id') id: string) {
    return this.customersService.findOne(id);
  }

  @Post()
  @AuditLog('CREATE', 'Customer')
  @ApiOperation({ summary: 'Tạo mới hồ sơ khách hàng' })
  create(@Body() createCustomerDto: CreateCustomerDto) {
    return this.customersService.create(createCustomerDto);
  }

  @Post('import')
  @Roles(Role.ADMIN)
  @AuditLog('CREATE', 'Customer')
  @ApiOperation({
    summary: 'Import danh sách khách hàng từ Excel (JSON payload)',
  })
  import(@Body() customers: CreateCustomerDto[]) {
    return this.customersService.import(customers);
  }

  @Patch(':id')
  @AuditLog('UPDATE', 'Customer')
  @ApiOperation({ summary: 'Cập nhật hồ sơ khách hàng' })
  update(
    @Param('id') id: string,
    @Body() updateCustomerDto: UpdateCustomerDto,
  ) {
    return this.customersService.update(id, updateCustomerDto);
  }

  @Delete(':id')
  @AuditLog('DELETE', 'Customer')
  @ApiOperation({ summary: 'Xoá khách hàng (Chỉ xoá nếu chưa có đơn)' })
  remove(@Param('id') id: string) {
    return this.customersService.remove(id);
  }
}
