import { Body, Controller, Param, Patch, Post, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '@app/auth';
import { MobileDispositivoService } from './mobile-dispositivo.service';

@Controller('v1/tenants/devices')
@UseGuards(JwtAuthGuard)
export class MobileDispositivoController {
  constructor(private readonly dispositivoService: MobileDispositivoService) {}

  @Post('register')
  register(@Body() body: { deviceId: string }, @Req() req: any) {
    return this.dispositivoService.register(body.deviceId, req.user.userId);
  }

  @Patch(':deviceId/activate')
  activate(@Param('deviceId') deviceId: string, @Req() req: any) {
    return this.dispositivoService.activate(decodeURIComponent(deviceId), req.user.userId);
  }
}
