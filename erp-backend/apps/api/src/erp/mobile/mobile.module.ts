import { Module } from '@nestjs/common';
import { MobileBiometriaModule } from './biometria/mobile-biometria.module';
import { MobileDispositivoModule } from './dispositivo/mobile-dispositivo.module';
import { MobileMarcacionModule } from './marcacion/mobile-marcacion.module';
import { MobileSyncModule } from './sync/mobile-sync.module';

@Module({
  imports: [
    MobileSyncModule,
    MobileBiometriaModule,
    MobileMarcacionModule,
    MobileDispositivoModule,
  ],
})
export class MobileModule {}
