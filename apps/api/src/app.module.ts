import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { ScheduleModule } from '@nestjs/schedule';
import { APP_GUARD, APP_INTERCEPTOR } from '@nestjs/core';

import { PrismaModule } from './prisma/prisma.module';
import { UsersModule } from './users/users.module';
import { AuthModule } from './auth/auth.module';
import { JwtAuthGuard } from './common/guards/jwt-auth.guard';
import { RolesGuard } from './common/guards/roles.guard';
import { AuditInterceptor } from './common/interceptors/audit.interceptor';
import { CustomerGroupsModule } from './customer-groups/customer-groups.module';
import { CustomersModule } from './customers/customers.module';

import { AddressModule } from './common/address/address.module';
import { ProductsModule } from './products/products.module';
import { OrdersModule } from './orders/orders.module';
import { DashboardModule } from './dashboard/dashboard.module';
import { SettingsModule } from './settings/settings.module';
import { AuditCleanupService } from './common/services/audit-cleanup.service';

@Module({
  imports: [
    // Load .env file globally
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),

    // Cron scheduler — cho AuditLog cleanup
    ScheduleModule.forRoot(),

    // Database — Global module
    PrismaModule,

    // Feature modules
    UsersModule,
    AuthModule,
    CustomerGroupsModule,
    CustomersModule,
    AddressModule,
    ProductsModule,
    OrdersModule,
    DashboardModule,
    SettingsModule,
  ],
  providers: [
    // Global JWT guard — mọi route cần auth, dùng @Public() để bypass
    {
      provide: APP_GUARD,
      useClass: JwtAuthGuard,
    },
    // Global Roles guard — kiểm tra @Roles() decorator
    {
      provide: APP_GUARD,
      useClass: RolesGuard,
    },
    // Global Audit interceptor — ghi log CREATE/UPDATE/DELETE
    {
      provide: APP_INTERCEPTOR,
      useClass: AuditInterceptor,
    },
    // Auto-cleanup audit logs > 90 ngày
    AuditCleanupService,
  ],
})
export class AppModule {}
