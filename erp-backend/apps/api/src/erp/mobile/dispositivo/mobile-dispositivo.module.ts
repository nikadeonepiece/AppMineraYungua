import { Module } from '@nestjs/common';
import { MobileDispositivoController } from './mobile-dispositivo.controller';
import { MobileDispositivoService } from './mobile-dispositivo.service';

@Module({
  controllers: [MobileDispositivoController],
  providers: [MobileDispositivoService],
})
export class MobileDispositivoModule {}
