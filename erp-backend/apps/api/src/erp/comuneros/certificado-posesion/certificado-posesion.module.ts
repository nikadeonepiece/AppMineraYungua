import { Module } from '@nestjs/common';
import { CertificadoPosesionService } from './certificado-posesion.service';
import { CertificadoPosesionController } from './certificado-posesion.controller';

@Module({
  controllers: [CertificadoPosesionController],
  providers: [CertificadoPosesionService],
  exports: [CertificadoPosesionService],
})
export class CertificadoPosesionModule {}
