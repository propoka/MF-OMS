import { Module } from '@nestjs/common';
import { CustomersService } from './customers.service';
import { CustomersController } from './customers.controller';
import { CustomerSpecialPricesController } from './special-prices.controller';
import { PrismaModule } from '../prisma/prisma.module';

@Module({
  imports: [PrismaModule],
  controllers: [CustomersController, CustomerSpecialPricesController],
  providers: [CustomersService],
  exports: [CustomersService],
})
export class CustomersModule {}
