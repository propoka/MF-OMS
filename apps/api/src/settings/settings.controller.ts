import { Controller, Get, Post, Body, Patch, Param, Delete } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { SettingsService } from './settings.service';
import { AuditLog } from '../common/decorators/audit-log.decorator';
import { UpdateCompanySettingsDto, CreateCancelReasonDto, UpdateCancelReasonDto } from './dto/settings.dto';

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
  @AuditLog('UPDATE', 'CompanySettings')
  updateCompanySettings(@Body() data: UpdateCompanySettingsDto) {
    return this.settingsService.updateCompanySettings(data);
  }

  @Get('cancel-reasons')
  getCancelReasons() {
    return this.settingsService.getCancelReasons();
  }

  @Post('cancel-reasons')
  @AuditLog('CREATE', 'CancelReason')
  createCancelReason(@Body() data: CreateCancelReasonDto) {
    return this.settingsService.createCancelReason(data);
  }

  @Patch('cancel-reasons/:id')
  @AuditLog('UPDATE', 'CancelReason')
  updateCancelReason(@Param('id') id: string, @Body() data: UpdateCancelReasonDto) {
    return this.settingsService.updateCancelReason(id, data);
  }

  @Delete('cancel-reasons/:id')
  @AuditLog('DELETE', 'CancelReason')
  deleteCancelReason(@Param('id') id: string) {
    return this.settingsService.deleteCancelReason(id);
  }
}
