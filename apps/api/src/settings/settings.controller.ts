import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
} from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { SettingsService } from './settings.service';
import { AuditLog } from '../common/decorators/audit-log.decorator';
import {
  UpdateCompanySettingsDto,
  CreateCancelReasonDto,
  UpdateCancelReasonDto,
} from './dto/settings.dto';
import { Roles } from '../common/decorators/roles.decorator';
import { Role } from '@prisma/client';

@ApiTags('Settings (Cài đặt)')
@ApiBearerAuth()
@Controller('settings')
export class SettingsController {
  constructor(private readonly settingsService: SettingsService) {}

  @Get('company')
  getCompanySettings() {
    return this.settingsService.getCompanySettings();
  }

  @Patch('company')
  @Roles(Role.ADMIN)
  @AuditLog('UPDATE', 'CompanySettings')
  updateCompanySettings(@Body() data: UpdateCompanySettingsDto) {
    return this.settingsService.updateCompanySettings(data);
  }

  @Get('cancel-reasons')
  getCancelReasons() {
    return this.settingsService.getCancelReasons();
  }

  @Post('cancel-reasons')
  @Roles(Role.ADMIN)
  @AuditLog('CREATE', 'CancelReason')
  createCancelReason(@Body() data: CreateCancelReasonDto) {
    return this.settingsService.createCancelReason(data);
  }

  @Patch('cancel-reasons/:id')
  @Roles(Role.ADMIN)
  @AuditLog('UPDATE', 'CancelReason')
  updateCancelReason(
    @Param('id') id: string,
    @Body() data: UpdateCancelReasonDto,
  ) {
    return this.settingsService.updateCancelReason(id, data);
  }

  @Delete('cancel-reasons/:id')
  @Roles(Role.ADMIN)
  @AuditLog('DELETE', 'CancelReason')
  deleteCancelReason(@Param('id') id: string) {
    return this.settingsService.deleteCancelReason(id);
  }
}
