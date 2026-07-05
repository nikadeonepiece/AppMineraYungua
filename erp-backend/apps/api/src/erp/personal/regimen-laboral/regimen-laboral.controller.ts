import { Body, Controller, Delete, Get, Param, ParseIntPipe, Post, Put, Query, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard, PermissionsGuard, RequirePermissions } from '@app/auth';
import { RegimenLaboralService } from './regimen-laboral.service';
import { CreateRegimenLaboralDto, UpdateRegimenLaboralDto } from './dto/regimen-laboral.dto';

@Controller('personal/regimenes-laborales')
@UseGuards(JwtAuthGuard, PermissionsGuard)
export class RegimenLaboralController {
  constructor(private readonly regimenService: RegimenLaboralService) {}

  @RequirePermissions('PERSONAL', 'ver_personal')
  @Get()
  findAll(@Query() query: any) {
    return this.regimenService.findAll(query);
  }

  @RequirePermissions('PERSONAL', 'ver_personal')
  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number) {
    return this.regimenService.findOne(id);
  }

  @RequirePermissions('PERSONAL', 'crear_personal')
  @Post()
  create(@Body() dto: CreateRegimenLaboralDto, @Req() req: any) {
    return this.regimenService.create(dto, req.user.userId);
  }

  @RequirePermissions('PERSONAL', 'editar_personal')
  @Put(':id')
  update(@Param('id', ParseIntPipe) id: number, @Body() dto: UpdateRegimenLaboralDto, @Req() req: any) {
    return this.regimenService.update(id, dto, req.user.userId);
  }

  @RequirePermissions('PERSONAL', 'eliminar_personal')
  @Delete(':id')
  remove(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    return this.regimenService.remove(id, req.user.userId);
  }
}
