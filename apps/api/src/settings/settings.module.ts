import { Module } from '@nestjs/common';
import { SettingsService } from './settings.service';
import { SettingsController } from './settings.controller';
import { AdvancedService } from './advanced.service';
import { AdvancedController } from './advanced.controller';
import { PrismaModule } from '../prisma/prisma.module';

@Module({
  imports: [PrismaModule],
  controllers: [SettingsController, AdvancedController],
  providers: [SettingsService, AdvancedService],
})
export class SettingsModule {}
