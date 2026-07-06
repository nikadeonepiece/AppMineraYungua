import { Body, Controller, Get, Post, Query, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '@app/auth';
import { MobileBiometriaService } from './mobile-biometria.service';

@Controller('empleados/biometria')
@UseGuards(JwtAuthGuard)
export class MobileBiometriaController {
  constructor(private readonly biometriaService: MobileBiometriaService) {}

  @Get('config')
  config() {
    return this.biometriaService.getConfig();
  }

  @Get('buscar')
  buscar(@Query('q') q?: string) {
    return this.biometriaService.buscar(q || '');
  }

  @Get('estado')
  estado(@Query('empleado_id') empleadoId: string) {
    return this.biometriaService.estado(empleadoId);
  }

  @Get('catalogo')
  catalogo() {
    return this.biometriaService.catalogo();
  }

  @Post('generate-embedding')
  generateEmbedding(@Body() body: { imageBase64: string }) {
    return this.biometriaService.generateEmbedding(body.imageBase64);
  }

  @Post('validar-par-capturas')
  validarParCapturas(@Body() body: { imageBase641: string; imageBase642: string }) {
    return this.biometriaService.validarParCapturas(body.imageBase641, body.imageBase642);
  }

  @Post('match-from-image')
  matchFromImage(@Body() body: { imageBase64: string }) {
    return this.biometriaService.matchFromImage(body.imageBase64);
  }

  @Post('registro')
  registro(
    @Body()
    body: {
      empleadoId: string;
      imagenesBase64: string[];
      embeddingDevice?: number[];
    },
    @Req() req: any,
  ) {
    return this.biometriaService.registrar(
      body.empleadoId,
      body.imagenesBase64,
      body.embeddingDevice,
      req.user.userId,
    );
  }
}
