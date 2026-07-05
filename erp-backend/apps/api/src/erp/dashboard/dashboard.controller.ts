import { Controller, Get, UseGuards } from '@nestjs/common';
import { JwtAuthGuard, PermissionsGuard, RequirePermissions } from '@app/auth';
import { DashboardService } from './dashboard.service';

@Controller('dashboard')
@UseGuards(JwtAuthGuard, PermissionsGuard)
export class DashboardController {
  constructor(private readonly dashboardService: DashboardService) {}

  @RequirePermissions('DASHBOARD', 'ver_dashboard')
  @Get('resumen-comuneros')
  resumenComuneros() {
    return this.dashboardService.resumenComuneros();
  }
}
