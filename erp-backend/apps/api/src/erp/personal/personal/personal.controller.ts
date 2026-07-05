import { Body, Controller, Delete, Get, Param, ParseIntPipe, Post, Put, Query, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard, PermissionsGuard, RequirePermissions } from '@app/auth';
import { PersonalService } from './personal.service';
import { CreatePersonalDto, UpdatePersonalDto } from './dto/personal.dto';

@Controller('personal')
@UseGuards(JwtAuthGuard, PermissionsGuard)
export class PersonalController {
  constructor(private readonly personalService: PersonalService) {}

  @RequirePermissions('PERSONAL', 'ver_personal')
  @Get()
  findAll(@Query() query: any) {
    return this.personalService.findAll(query);
  }

  @RequirePermissions('PERSONAL', 'ver_personal')
  @Get('buscar-comunero')
  buscarComuneros(
    @Query('search') search: string,
    @Query('id_personal_actual') idPersonalActual?: string,
    @Query('id_comunero_actual') idComuneroActual?: string,
  ) {
    return this.personalService.buscarComuneros(
      search,
      idPersonalActual ? Number(idPersonalActual) : undefined,
      idComuneroActual ? Number(idComuneroActual) : undefined,
    );
  }

  @RequirePermissions('PERSONAL', 'ver_personal')
  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number) {
    return this.personalService.findOne(id);
  }

  @RequirePermissions('PERSONAL', 'crear_personal')
  @Post()
  create(@Body() dto: CreatePersonalDto, @Req() req: any) {
    return this.personalService.create(dto, req.user.userId);
  }

  @RequirePermissions('PERSONAL', 'editar_personal')
  @Put(':id')
  update(@Param('id', ParseIntPipe) id: number, @Body() dto: UpdatePersonalDto, @Req() req: any) {
    return this.personalService.update(id, dto, req.user.userId);
  }

  @RequirePermissions('PERSONAL', 'eliminar_personal')
  @Delete(':id')
  remove(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    return this.personalService.remove(id, req.user.userId);
  }
}
