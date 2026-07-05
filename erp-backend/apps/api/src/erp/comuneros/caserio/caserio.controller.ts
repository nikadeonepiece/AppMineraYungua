import { Body, Controller, Delete, Get, Param, ParseIntPipe, Post, Put, Query, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard, PermissionsGuard, RequirePermissions } from '@app/auth';
import { CaserioService } from './caserio.service';
import { CreateCaserioDto, UpdateCaserioDto } from './dto/caserio.dto';

@Controller('comuneros/caserios')
@UseGuards(JwtAuthGuard, PermissionsGuard)
export class CaserioController {
  constructor(private readonly caserioService: CaserioService) {}

  @RequirePermissions('COMUNEROS', 'ver_comunero')
  @Get()
  findAll(@Query() query: any) {
    return this.caserioService.findAll(query);
  }

  @RequirePermissions('COMUNEROS', 'ver_comunero')
  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number) {
    return this.caserioService.findOne(id);
  }

  @RequirePermissions('COMUNEROS', 'crear_comunero')
  @Post()
  create(@Body() dto: CreateCaserioDto, @Req() req: any) {
    return this.caserioService.create(dto, req.user.userId);
  }

  @RequirePermissions('COMUNEROS', 'editar_comunero')
  @Put(':id')
  update(@Param('id', ParseIntPipe) id: number, @Body() dto: UpdateCaserioDto, @Req() req: any) {
    return this.caserioService.update(id, dto, req.user.userId);
  }

  @RequirePermissions('COMUNEROS', 'eliminar_comunero')
  @Delete(':id')
  remove(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    return this.caserioService.remove(id, req.user.userId);
  }
}
