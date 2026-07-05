import { Body, Controller, Delete, Get, Param, ParseIntPipe, Post, Put, Query, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard, PermissionsGuard, RequirePermissions } from '@app/auth';
import { CargoService } from './cargo.service';
import { CreateCargoDto, UpdateCargoDto } from './dto/cargo.dto';

@Controller('personal/cargos')
@UseGuards(JwtAuthGuard, PermissionsGuard)
export class CargoController {
  constructor(private readonly cargoService: CargoService) {}

  @RequirePermissions('PERSONAL', 'ver_personal')
  @Get()
  findAll(@Query() query: any) {
    return this.cargoService.findAll(query);
  }

  @RequirePermissions('PERSONAL', 'ver_personal')
  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number) {
    return this.cargoService.findOne(id);
  }

  @RequirePermissions('PERSONAL', 'crear_personal')
  @Post()
  create(@Body() dto: CreateCargoDto, @Req() req: any) {
    return this.cargoService.create(dto, req.user.userId);
  }

  @RequirePermissions('PERSONAL', 'editar_personal')
  @Put(':id')
  update(@Param('id', ParseIntPipe) id: number, @Body() dto: UpdateCargoDto, @Req() req: any) {
    return this.cargoService.update(id, dto, req.user.userId);
  }

  @RequirePermissions('PERSONAL', 'eliminar_personal')
  @Delete(':id')
  remove(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    return this.cargoService.remove(id, req.user.userId);
  }
}
