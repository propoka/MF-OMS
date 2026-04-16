import { Controller, Delete, Post } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { AdvancedService } from './advanced.service';
import { AuditLog } from '../common/decorators/audit-log.decorator';
import { Roles } from '../common/decorators/roles.decorator';
import { Role } from '@prisma/client';

@ApiTags('Settings Advanced (Nâng cao)')
@ApiBearerAuth()
@Controller('settings/advanced')
@Roles(Role.ADMIN) // Tất cả các hành động ở đây chỉ Admin mới làm được
export class AdvancedController {
  constructor(private readonly advancedService: AdvancedService) {}

  @Delete('delete-all/products')
  @AuditLog('DELETE', 'AllProducts')
  @ApiOperation({ summary: 'Xóa tất cả Sản phẩm' })
  deleteAllProducts() {
    return this.advancedService.deleteAllProducts();
  }

  @Delete('delete-all/customers')
  @AuditLog('DELETE', 'AllCustomers')
  @ApiOperation({ summary: 'Xóa tất cả Khách hàng' })
  deleteAllCustomers() {
    return this.advancedService.deleteAllCustomers();
  }

  @Delete('delete-all/orders')
  @AuditLog('DELETE', 'AllOrders')
  @ApiOperation({ summary: 'Xóa tất cả Đơn hàng' })
  deleteAllOrders() {
    return this.advancedService.deleteAllOrders();
  }

  @Delete('delete-all/customer-groups')
  @AuditLog('DELETE', 'AllCustomerGroups')
  @ApiOperation({ summary: 'Xóa tất cả Nhóm KH' })
  deleteAllCustomerGroups() {
    return this.advancedService.deleteAllCustomerGroups();
  }

  @Delete('delete-all/product-categories')
  @AuditLog('DELETE', 'AllProductCategories')
  @ApiOperation({ summary: 'Xóa tất cả Danh mục SP' })
  deleteAllProductCategories() {
    return this.advancedService.deleteAllProductCategories();
  }

  @Post('seed-local')
  @AuditLog('CREATE', 'System')
  @ApiOperation({ summary: 'Khởi tạo Dữ liệu gốc từ CSV' })
  seedLocalData() {
    return this.advancedService.seedLocalData();
  }
}
