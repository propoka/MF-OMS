import { Controller, Get, Post, Body, Patch, Param, Delete } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { CustomerGroupsService } from './customer-groups.service';
import { CreateCustomerGroupDto, UpdateCustomerGroupDto } from './dto/customer-group.dto';
import { Roles } from '../common/decorators/roles.decorator';
import { Role } from '@prisma/client';
import { AuditLog } from '../common/decorators/audit-log.decorator';

@ApiTags('Customer Groups (Nhóm khách hàng)')
@ApiBearerAuth()
@Controller('customer-groups')
export class CustomerGroupsController {
  constructor(private readonly customerGroupsService: CustomerGroupsService) {}

  @Get()
  @ApiOperation({ summary: 'Lấy danh sách tất cả nhóm khách hàng' })
  findAll() {
    return this.customerGroupsService.findAll();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Lấy chi tiết 1 nhóm khách hàng' })
  findOne(@Param('id') id: string) {
    return this.customerGroupsService.findOne(id);
  }

  @Post()
  @Roles(Role.ADMIN)
  @AuditLog('CREATE', 'CustomerGroup')
  @ApiOperation({ summary: 'Tên nhóm mới (Chỉ Admin)' })
  create(@Body() createCustomerGroupDto: CreateCustomerGroupDto) {
    return this.customerGroupsService.create(createCustomerGroupDto);
  }

  @Patch(':id')
  @Roles(Role.ADMIN)
  @AuditLog('UPDATE', 'CustomerGroup')
  @ApiOperation({ summary: 'Cập nhật nhóm khách hàng (Chỉ Admin)' })
  update(@Param('id') id: string, @Body() updateCustomerGroupDto: UpdateCustomerGroupDto) {
    return this.customerGroupsService.update(id, updateCustomerGroupDto);
  }

  @Delete(':id')
  @Roles(Role.ADMIN)
  @AuditLog('DELETE', 'CustomerGroup')
  @ApiOperation({ summary: 'Xoá nhóm khách hàng (Chỉ Admin)' })
  remove(@Param('id') id: string) {
    return this.customerGroupsService.remove(id);
  }
}
