import { Body, Controller, Delete, Get, Param, ParseIntPipe, Post, Put, Query, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard, PermissionsGuard, RequirePermissions } from '@app/auth';
import { ParcelaService } from './parcela.service';
import { CreateParcelaDto, UpdateParcelaDto } from './dto/parcela.dto';

@Controller('comuneros/parcelas')
@UseGuards(JwtAuthGuard, PermissionsGuard)
export class ParcelaController {
  constructor(private readonly parcelaService: ParcelaService) {}

  @RequirePermissions('COMUNEROS', 'ver_comunero')
  @Get()
  findAll(@Query() query: any) {
    return this.parcelaService.findAll(query);
  }

  @RequirePermissions('COMUNEROS', 'ver_comunero')
  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number) {
    return this.parcelaService.findOne(id);
  }

  @RequirePermissions('COMUNEROS', 'crear_comunero')
  @Post()
  create(@Body() dto: CreateParcelaDto, @Req() req: any) {
    return this.parcelaService.create(dto, req.user.userId);
  }

  @RequirePermissions('COMUNEROS', 'editar_comunero')
  @Put(':id')
  update(@Param('id', ParseIntPipe) id: number, @Body() dto: UpdateParcelaDto, @Req() req: any) {
    return this.parcelaService.update(id, dto, req.user.userId);
  }

  @RequirePermissions('COMUNEROS', 'eliminar_comunero')
  @Delete(':id')
  remove(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    return this.parcelaService.remove(id, req.user.userId);
  }
}
