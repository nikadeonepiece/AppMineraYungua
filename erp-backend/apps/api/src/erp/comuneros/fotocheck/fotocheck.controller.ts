import { Controller, Get, Query, Res, UseGuards } from '@nestjs/common';
import type { Response } from 'express';
import { JwtAuthGuard, PermissionsGuard, RequirePermissions } from '@app/auth';
import { FotocheckService } from './fotocheck.service';

@Controller('comuneros/fotocheck')
@UseGuards(JwtAuthGuard, PermissionsGuard)
export class FotocheckController {
  constructor(private readonly fotocheckService: FotocheckService) {}

  @RequirePermissions('COMUNEROS', 'ver_fotocheck')
  @Get('comuneros')
  findComuneros(@Query() query: any) {
    return this.fotocheckService.findComunerosByCaserio(query);
  }

  @RequirePermissions('COMUNEROS', 'generar_fotocheck')
  @Get('pdf')
  async exportarPdf(@Query() query: any, @Res() res: Response) {
    await this.fotocheckService.exportarPdf(query, res);
  }
}
