import { Body, Controller, Delete, Get, Param, ParseIntPipe, Post, Put, Query, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard, PermissionsGuard, RequirePermissions } from '@app/auth';
import { TurnoTrabajoService } from './turno-trabajo.service';
import { CreateTurnoTrabajoDto, UpdateTurnoTrabajoDto } from './dto/turno-trabajo.dto';

@Controller('personal/turnos-trabajo')
@UseGuards(JwtAuthGuard, PermissionsGuard)
export class TurnoTrabajoController {
  constructor(private readonly turnoService: TurnoTrabajoService) {}

  @RequirePermissions('PERSONAL', 'ver_personal')
  @Get()
  findAll(@Query() query: any) {
    return this.turnoService.findAll(query);
  }

  @RequirePermissions('PERSONAL', 'ver_personal')
  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number) {
    return this.turnoService.findOne(id);
  }

  @RequirePermissions('PERSONAL', 'crear_personal')
  @Post()
  create(@Body() dto: CreateTurnoTrabajoDto, @Req() req: any) {
    return this.turnoService.create(dto, req.user.userId);
  }

  @RequirePermissions('PERSONAL', 'editar_personal')
  @Put(':id')
  update(@Param('id', ParseIntPipe) id: number, @Body() dto: UpdateTurnoTrabajoDto, @Req() req: any) {
    return this.turnoService.update(id, dto, req.user.userId);
  }

  @RequirePermissions('PERSONAL', 'eliminar_personal')
  @Delete(':id')
  remove(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    return this.turnoService.remove(id, req.user.userId);
  }
}
