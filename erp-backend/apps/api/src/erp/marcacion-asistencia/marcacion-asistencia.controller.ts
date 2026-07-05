import { Body, Controller, Get, Post, Query, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard, PermissionsGuard, RequirePermissions } from '@app/auth';
import { MarcacionAsistenciaService } from './marcacion-asistencia.service';
import { CreateMarcacionDto } from './dto/marcacion.dto';

@Controller('marcacion-asistencia')
@UseGuards(JwtAuthGuard, PermissionsGuard)
export class MarcacionAsistenciaController {
  constructor(private readonly marcacionService: MarcacionAsistenciaService) {}

  @RequirePermissions('PERSONAL', 'ver_asistencia_diaria')
  @Get('resumen-diario')
  resumenDiario(@Query() query: any) {
    return this.marcacionService.resumenDiario(query);
  }

  @RequirePermissions('PERSONAL', 'ver_asistencia_diaria')
  @Get()
  findAll(@Query() query: any) {
    return this.marcacionService.findAll(query);
  }

  @RequirePermissions('PERSONAL', 'marcar_asistencia')
  @Post()
  registrar(@Body() dto: CreateMarcacionDto, @Req() req: any) {
    return this.marcacionService.registrar(dto, req.user.userId);
  }
}
