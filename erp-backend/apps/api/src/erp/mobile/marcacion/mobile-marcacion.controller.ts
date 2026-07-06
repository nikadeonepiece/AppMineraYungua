import { Body, Controller, Get, Post, Query, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '@app/auth';
import { MobileMarcacionService } from './mobile-marcacion.service';

@Controller()
@UseGuards(JwtAuthGuard)
export class MobileMarcacionController {
  constructor(private readonly marcacionService: MobileMarcacionService) {}

  @Post('asistencia/marcar')
  marcar(
    @Body() body: { empleado_id: string; metodo?: string; dispositivo_id?: string },
    @Req() req: any,
  ) {
    return this.marcacionService.marcarOnline(body, req.user.userId);
  }

  @Get('asistencia')
  listar(@Query('limit') limit?: string) {
    return this.marcacionService.listarRecientes(Number(limit));
  }

  @Post('v1/marcaciones')
  registrarOffline(@Body() body: any, @Req() req: any) {
    return this.marcacionService.registrarOffline(body, req.user.userId);
  }
}
