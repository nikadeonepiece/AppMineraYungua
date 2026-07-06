import { Body, Controller, Delete, Get, Param, ParseIntPipe, Post, Put, Query, Req, Res, UseGuards } from '@nestjs/common';
import type { Response } from 'express';
import { JwtAuthGuard, PermissionsGuard, RequirePermissions } from '@app/auth';
import { CertificadoPosesionService } from './certificado-posesion.service';
import { CreateCertificadoPosesionDto, UpdateCertificadoPosesionDto } from './dto/certificado-posesion.dto';

@Controller('comuneros/certificados-posesion')
@UseGuards(JwtAuthGuard, PermissionsGuard)
export class CertificadoPosesionController {
  constructor(private readonly certificadoPosesionService: CertificadoPosesionService) {}

  @RequirePermissions('COMUNEROS', 'ver_certificado_posesion')
  @Get()
  findAll(@Query() query: any) {
    return this.certificadoPosesionService.findAll(query);
  }

  @RequirePermissions('COMUNEROS', 'exportar_certificado_posesion')
  @Get('pdf')
  async exportarPdf(@Query() query: any, @Res() res: Response) {
    await this.certificadoPosesionService.exportarPdf(query, res);
  }

  @RequirePermissions('COMUNEROS', 'ver_certificado_posesion')
  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number) {
    return this.certificadoPosesionService.findOne(id);
  }

  @RequirePermissions('COMUNEROS', 'crear_certificado_posesion')
  @Post()
  create(@Body() dto: CreateCertificadoPosesionDto, @Req() req: any) {
    return this.certificadoPosesionService.create(dto, req.user.userId);
  }

  @RequirePermissions('COMUNEROS', 'editar_certificado_posesion')
  @Put(':id')
  update(@Param('id', ParseIntPipe) id: number, @Body() dto: UpdateCertificadoPosesionDto, @Req() req: any) {
    return this.certificadoPosesionService.update(id, dto, req.user.userId);
  }

  @RequirePermissions('COMUNEROS', 'eliminar_certificado_posesion')
  @Delete(':id')
  remove(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    return this.certificadoPosesionService.remove(id, req.user.userId);
  }
}
