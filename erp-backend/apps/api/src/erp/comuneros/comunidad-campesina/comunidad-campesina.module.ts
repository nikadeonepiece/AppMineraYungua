import { Module } from '@nestjs/common';
import { ComunidadCampesinaService } from './comunidad-campesina.service';
import { ComunidadCampesinaController } from './comunidad-campesina.controller';

@Module({
  controllers: [ComunidadCampesinaController],
  providers: [ComunidadCampesinaService],
  exports: [ComunidadCampesinaService],
})
export class ComunidadCampesinaModule {}
