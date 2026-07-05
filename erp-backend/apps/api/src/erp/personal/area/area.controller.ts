import { Body, Controller, Delete, Get, Param, ParseIntPipe, Post, Put, Query, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard, PermissionsGuard, RequirePermissions } from '@app/auth';
import { AreaService } from './area.service';
import { CreateAreaDto, UpdateAreaDto } from './dto/area.dto';

@Controller('personal/areas')
@UseGuards(JwtAuthGuard, PermissionsGuard)
export class AreaController {
  constructor(private readonly areaService: AreaService) {}

  @RequirePermissions('PERSONAL', 'ver_personal')
  @Get()
  findAll(@Query() query: any) {
    return this.areaService.findAll(query);
  }

  @RequirePermissions('PERSONAL', 'ver_personal')
  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number) {
    return this.areaService.findOne(id);
  }

  @RequirePermissions('PERSONAL', 'crear_personal')
  @Post()
  create(@Body() dto: CreateAreaDto, @Req() req: any) {
    return this.areaService.create(dto, req.user.userId);
  }

  @RequirePermissions('PERSONAL', 'editar_personal')
  @Put(':id')
  update(@Param('id', ParseIntPipe) id: number, @Body() dto: UpdateAreaDto, @Req() req: any) {
    return this.areaService.update(id, dto, req.user.userId);
  }

  @RequirePermissions('PERSONAL', 'eliminar_personal')
  @Delete(':id')
  remove(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    return this.areaService.remove(id, req.user.userId);
  }
}
