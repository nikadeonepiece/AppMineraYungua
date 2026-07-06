import { Controller, Get, Query, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '@app/auth';
import { MobileSyncService } from './mobile-sync.service';

@Controller('v1/sync')
@UseGuards(JwtAuthGuard)
export class MobileSyncController {
  constructor(private readonly syncService: MobileSyncService) {}

  @Get('areas')
  areas() {
    return this.syncService.listAreas();
  }

  @Get('empleados')
  empleados(
    @Query('updated_after') updatedAfter?: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('id_areas') idAreas?: string,
  ) {
    return this.syncService.syncEmpleados(updatedAfter, Number(page), Number(limit), idAreas);
  }

  @Get('usuarios')
  usuarios(@Query('updated_after') updatedAfter?: string, @Query('page') page?: string, @Query('limit') limit?: string) {
    return this.syncService.syncUsuarios(updatedAfter, Number(page), Number(limit));
  }

  @Get('biometria')
  biometria(
    @Query('updated_after') updatedAfter?: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('id_areas') idAreas?: string,
  ) {
    return this.syncService.syncBiometria(updatedAfter, Number(page), Number(limit), idAreas);
  }
}
