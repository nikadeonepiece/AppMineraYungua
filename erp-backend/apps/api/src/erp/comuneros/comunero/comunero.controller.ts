import { Body, Controller, Delete, Get, Param, ParseIntPipe, Post, Put, Query, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard, PermissionsGuard, RequirePermissions } from '@app/auth';
import { ComuneroService } from './comunero.service';
import { CreateComuneroDto, UpdateComuneroDto } from './dto/comunero.dto';
import { AddComuneroCaserioDto } from './dto/comunero-caserio.dto';

@Controller('comuneros/comuneros')
@UseGuards(JwtAuthGuard, PermissionsGuard)
export class ComuneroController {
  constructor(private readonly comuneroService: ComuneroService) {}

  @RequirePermissions('COMUNEROS', 'ver_comunero')
  @Get()
  findAll(@Query() query: any) {
    return this.comuneroService.findAll(query);
  }

  @RequirePermissions('COMUNEROS', 'ver_comunero')
  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number) {
    return this.comuneroService.findOne(id);
  }

  @RequirePermissions('COMUNEROS', 'ver_comunero')
  @Get(':id/caserios')
  findCaserios(@Param('id', ParseIntPipe) id: number) {
    return this.comuneroService.findCaserios(id);
  }

  @RequirePermissions('COMUNEROS', 'crear_comunero')
  @Post()
  create(@Body() dto: CreateComuneroDto, @Req() req: any) {
    return this.comuneroService.create(dto, req.user.userId);
  }

  @RequirePermissions('COMUNEROS', 'editar_comunero')
  @Post(':id/caserios')
  addCaserio(@Param('id', ParseIntPipe) id: number, @Body() dto: AddComuneroCaserioDto, @Req() req: any) {
    return this.comuneroService.addCaserio(id, dto.id_caserio, req.user.userId);
  }

  @RequirePermissions('COMUNEROS', 'editar_comunero')
  @Put(':id')
  update(@Param('id', ParseIntPipe) id: number, @Body() dto: UpdateComuneroDto, @Req() req: any) {
    return this.comuneroService.update(id, dto, req.user.userId);
  }

  @RequirePermissions('COMUNEROS', 'eliminar_comunero')
  @Delete(':id')
  remove(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    return this.comuneroService.remove(id, req.user.userId);
  }

  @RequirePermissions('COMUNEROS', 'editar_comunero')
  @Delete(':id/caserios/:idVinculo')
  removeCaserio(
    @Param('id', ParseIntPipe) id: number,
    @Param('idVinculo', ParseIntPipe) idVinculo: number,
    @Req() req: any,
  ) {
    return this.comuneroService.removeCaserio(id, idVinculo, req.user.userId);
  }
}
