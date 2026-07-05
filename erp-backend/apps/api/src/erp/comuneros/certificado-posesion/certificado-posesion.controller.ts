import { Body, Controller, Delete, Get, Param, ParseIntPipe, Post, Put, Query, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard, PermissionsGuard, RequirePermissions } from '@app/auth';
import { CertificadoPosesionService } from './certificado-posesion.service';
import { CreateCertificadoPosesionDto, UpdateCertificadoPosesionDto } from './dto/certificado-posesion.dto';

@Controller('comuneros/certificados-posesion')
@UseGuards(JwtAuthGuard, PermissionsGuard)
export class CertificadoPosesionController {
  constructor(private readonly certificadoPosesionService: CertificadoPosesionService) {}

  @RequirePermissions('COMUNEROS', 'ver_comunero')
  @Get()
  findAll(@Query() query: any) {
    return this.certificadoPosesionService.findAll(query);
  }

  @RequirePermissions('COMUNEROS', 'ver_comunero')
  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number) {
    return this.certificadoPosesionService.findOne(id);
  }

  @RequirePermissions('COMUNEROS', 'crear_comunero')
  @Post()
  create(@Body() dto: CreateCertificadoPosesionDto, @Req() req: any) {
    return this.certificadoPosesionService.create(dto, req.user.userId);
  }

  @RequirePermissions('COMUNEROS', 'editar_comunero')
  @Put(':id')
  update(@Param('id', ParseIntPipe) id: number, @Body() dto: UpdateCertificadoPosesionDto, @Req() req: any) {
    return this.certificadoPosesionService.update(id, dto, req.user.userId);
  }

  @RequirePermissions('COMUNEROS', 'eliminar_comunero')
  @Delete(':id')
  remove(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    return this.certificadoPosesionService.remove(id, req.user.userId);
  }
}
