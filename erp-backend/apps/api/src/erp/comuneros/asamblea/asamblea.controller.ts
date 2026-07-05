import { Body, Controller, Delete, Get, Param, ParseIntPipe, Post, Put, Query, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard, PermissionsGuard, RequirePermissions } from '@app/auth';
import { AsambleaService } from './asamblea.service';
import { CreateAsambleaDto, UpdateAsambleaDto } from './dto/asamblea.dto';
import { MarcarAsistenciaAsambleaDto } from './dto/asistencia-asamblea.dto';

@Controller('comuneros/asambleas')
@UseGuards(JwtAuthGuard, PermissionsGuard)
export class AsambleaController {
  constructor(private readonly asambleaService: AsambleaService) {}

  @RequirePermissions('COMUNEROS', 'ver_asamblea')
  @Get()
  findAll(@Query() query: any) {
    return this.asambleaService.findAll(query);
  }

  @RequirePermissions('COMUNEROS', 'ver_asamblea')
  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number) {
    return this.asambleaService.findOne(id);
  }

  @RequirePermissions('COMUNEROS', 'ver_asamblea')
  @Get(':id/asistencia')
  findAsistencia(@Param('id', ParseIntPipe) id: number) {
    return this.asambleaService.findAsistencia(id);
  }

  @RequirePermissions('COMUNEROS', 'ver_asamblea')
  @Get(':id/comuneros')
  findComuneros(@Param('id', ParseIntPipe) id: number) {
    return this.asambleaService.findComuneros(id);
  }

  @RequirePermissions('COMUNEROS', 'crear_asamblea')
  @Post()
  create(@Body() dto: CreateAsambleaDto, @Req() req: any) {
    return this.asambleaService.create(dto, req.user.userId);
  }

  @RequirePermissions('COMUNEROS', 'marcar_asistencia_asamblea')
  @Post(':id/asistencia')
  marcarAsistencia(@Param('id', ParseIntPipe) id: number, @Body() dto: MarcarAsistenciaAsambleaDto, @Req() req: any) {
    return this.asambleaService.marcarAsistencia(id, dto, req.user.userId);
  }

  @RequirePermissions('COMUNEROS', 'crear_asamblea')
  @Put(':id')
  update(@Param('id', ParseIntPipe) id: number, @Body() dto: UpdateAsambleaDto, @Req() req: any) {
    return this.asambleaService.update(id, dto, req.user.userId);
  }

  @RequirePermissions('COMUNEROS', 'marcar_asistencia_asamblea')
  @Delete(':id/asistencia/:idAsistencia')
  quitarAsistencia(
    @Param('id', ParseIntPipe) id: number,
    @Param('idAsistencia', ParseIntPipe) idAsistencia: number,
    @Req() req: any,
  ) {
    return this.asambleaService.quitarAsistencia(id, idAsistencia, req.user.userId);
  }
}
