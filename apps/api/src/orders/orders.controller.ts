import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  Query,
  Request,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiBearerAuth,
  ApiQuery,
} from '@nestjs/swagger';
import { OrdersService } from './orders.service';
import { PricingEngineService } from './pricing.service';
import {
  CreateOrderDto,
  UpdateOrderStatusDto,
  UpdateOrderDto,
} from './dto/order.dto';
import { AuditLog } from '../common/decorators/audit-log.decorator';
import { Roles } from '../common/decorators/roles.decorator';
import { Role } from '@prisma/client';

@ApiTags('Orders (Đơn hàng)')
@ApiBearerAuth()
@Controller('orders')
export class OrdersController {
  constructor(
    private readonly ordersService: OrdersService,
    private readonly pricingEngine: PricingEngineService,
  ) {}

  @Get()
  @ApiOperation({ summary: 'Lấy list đơn hàng (Phân trang, bộ lọc)' })
  @ApiQuery({ name: 'skip', required: false, type: Number })
  @ApiQuery({ name: 'take', required: false, type: Number })
  @ApiQuery({ name: 'search', required: false, type: String })
  @ApiQuery({ name: 'status', required: false, type: String })
  findAll(
    @Query('skip') skip?: string,
    @Query('take') take?: string,
    @Query('search') search?: string,
    @Query('status') status?: string,
  ) {
    return this.ordersService.findAll({
      skip: skip ? parseInt(skip, 10) : 0,
      take: take ? parseInt(take, 10) : 50,
      search,
      status,
    });
  }

  @Get(':id')
  @ApiOperation({ summary: 'Xem chi tiết hoá đơn / Phiếu xuất' })
  findOne(@Param('id') id: string) {
    return this.ordersService.findOne(id);
  }

  @Post('preview-pricing')
  @ApiOperation({ summary: 'Preview giá trước khi lên đơn (Pricing Engine)' })
  async previewPricing(
    @Body()
    body: {
      customerId: string;
      items: { productId: string; quantity: number; manualDiscount?: number }[];
    },
  ) {
    const result = await this.pricingEngine.calculatePricing(
      body.customerId,
      body.items,
    );
    return {
      customerSnapshot: result.customerSnapshot,
      items: result.orderItemsData.map((item) => ({
        productId: item.productId,
        snapshotProductName: item.snapshotProductName,
        snapshotProductSku: item.snapshotProductSku,
        snapshotProductUnit: item.snapshotProductUnit,
        snapshotUnitPrice: Number(item.snapshotUnitPrice),
        priceSource: item.priceSource,
        pricingNote: item.pricingNote,
        quantity: item.quantity,
        lineDiscount: Number(item.lineDiscount),
        lineTotal: Number(item.lineTotal),
      })),
      subtotal: Number(result.subtotal),
    };
  }

  @Post()
  @AuditLog('CREATE', 'Order')
  @ApiOperation({ summary: 'Tạo đơn hàng mới (Pricing Engine)' })
  create(@Request() req: any, @Body() createOrderDto: CreateOrderDto) {
    // req.user.id đến từ JwtAuthGuard
    return this.ordersService.create(req.user.id, createOrderDto);
  }

  @Post('import')
  @Roles(Role.ADMIN)
  @AuditLog('CREATE', 'Order')
  @ApiOperation({ summary: 'Import danh sách đơn hàng từ Excel' })
  import(@Request() req: any, @Body() orders: any[]) {
    return this.ordersService.import(req.user.id, orders);
  }

  @Patch(':id')
  @AuditLog('UPDATE', 'Order')
  @ApiOperation({ summary: 'Chỉnh sửa toàn bộ đơn hàng (Thay đổi kho)' })
  update(
    @Param('id') id: string,
    @Request() req: any,
    @Body() updateOrderDto: UpdateOrderDto,
  ) {
    return this.ordersService.update(id, req.user.id, updateOrderDto);
  }

  @Patch(':id/status')
  @AuditLog('STATUS_CHANGE', 'Order')
  @ApiOperation({ summary: 'Trạng thái Đơn hàng (Giao hàng/Thanh toán)' })
  updateStatus(
    @Param('id') id: string,
    @Body() updateData: UpdateOrderStatusDto,
  ) {
    return this.ordersService.updateStatus(id, updateData);
  }

  @Delete(':id')
  @Roles(Role.ADMIN)
  @AuditLog('DELETE', 'Order')
  @ApiOperation({ summary: 'Xoá đơn hàng (Phục hồi tồn kho)' })
  remove(@Param('id') id: string) {
    return this.ordersService.remove(id);
  }
}
