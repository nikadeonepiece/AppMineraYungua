import { Body, Controller, Delete, Get, Param, ParseIntPipe, Post, Put, Query, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard, PermissionsGuard, RequirePermissions } from '@app/auth';
import { ComunidadCampesinaService } from './comunidad-campesina.service';
import { CreateComunidadCampesinaDto, UpdateComunidadCampesinaDto } from './dto/comunidad-campesina.dto';

@Controller('comuneros/comunidad-campesina')
@UseGuards(JwtAuthGuard, PermissionsGuard)
export class ComunidadCampesinaController {
  constructor(private readonly comunidadCampesinaService: ComunidadCampesinaService) {}

  @RequirePermissions('COMUNEROS', 'ver_comunero')
  @Get()
  findAll(@Query() query: any) {
    return this.comunidadCampesinaService.findAll(query);
  }

  @RequirePermissions('COMUNEROS', 'ver_comunero')
  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number) {
    return this.comunidadCampesinaService.findOne(id);
  }

  @RequirePermissions('COMUNEROS', 'crear_comunero')
  @Post()
  create(@Body() dto: CreateComunidadCampesinaDto, @Req() req: any) {
    return this.comunidadCampesinaService.create(dto, req.user.userId);
  }

  @RequirePermissions('COMUNEROS', 'editar_comunero')
  @Put(':id')
  update(@Param('id', ParseIntPipe) id: number, @Body() dto: UpdateComunidadCampesinaDto, @Req() req: any) {
    return this.comunidadCampesinaService.update(id, dto, req.user.userId);
  }

  @RequirePermissions('COMUNEROS', 'eliminar_comunero')
  @Delete(':id')
  remove(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    return this.comunidadCampesinaService.remove(id, req.user.userId);
  }
}
