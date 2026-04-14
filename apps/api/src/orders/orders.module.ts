import { Module } from '@nestjs/common';
import { OrdersService } from './orders.service';
import { OrdersController } from './orders.controller';
import { PricingEngineService } from './pricing.service';

@Module({
  controllers: [OrdersController],
  providers: [OrdersService, PricingEngineService],
  exports: [OrdersService, PricingEngineService],
})
export class OrdersModule {}
