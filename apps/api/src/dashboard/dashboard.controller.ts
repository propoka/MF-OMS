import { Controller, Get, Query } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { DashboardService } from './dashboard.service';

@ApiTags('Dashboard')
@ApiBearerAuth()
@Controller('dashboard')
export class DashboardController {
  constructor(private readonly dashboardService: DashboardService) {}

  @Get('kpis')
  @ApiOperation({ summary: 'Lấy dữ liệu tổng quan KPIs' })
  getKpis(@Query('days') days?: string) {
    return this.dashboardService.getKpis(days ? parseInt(days, 10) : 7);
  }

  @Get('report')
  @ApiOperation({ summary: 'Lấy dữ liệu báo cáo tuỳ chỉnh theo ngày' })
  getReport(
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
  ) {
    return this.dashboardService.getReport(startDate, endDate);
  }
}
