import { Module } from '@nestjs/common';
import { MarcacionAsistenciaModule } from '../../marcacion-asistencia/marcacion-asistencia.module';
import { ReplaySignatureService } from '../common/replay-signature.service';
import { MobileMarcacionController } from './mobile-marcacion.controller';
import { MobileMarcacionService } from './mobile-marcacion.service';

@Module({
  imports: [MarcacionAsistenciaModule],
  controllers: [MobileMarcacionController],
  providers: [MobileMarcacionService, ReplaySignatureService],
})
export class MobileMarcacionModule {}
