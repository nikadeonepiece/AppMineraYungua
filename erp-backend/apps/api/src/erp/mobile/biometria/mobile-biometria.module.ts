import { Module } from '@nestjs/common';
import { CommonModule } from '@app/common';
import { MobileBiometriaController } from './mobile-biometria.controller';
import { MobileBiometriaService } from './mobile-biometria.service';

@Module({
  imports: [CommonModule],
  controllers: [MobileBiometriaController],
  providers: [MobileBiometriaService],
})
export class MobileBiometriaModule {}
