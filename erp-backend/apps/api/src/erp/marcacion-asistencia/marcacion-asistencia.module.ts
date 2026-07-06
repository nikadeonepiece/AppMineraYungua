import { Module } from '@nestjs/common';
import { MarcacionAsistenciaService } from './marcacion-asistencia.service';
import { MarcacionAsistenciaController } from './marcacion-asistencia.controller';

@Module({
  controllers: [MarcacionAsistenciaController],
  providers: [MarcacionAsistenciaService],
  exports: [MarcacionAsistenciaService],
})
export class MarcacionAsistenciaModule {}
