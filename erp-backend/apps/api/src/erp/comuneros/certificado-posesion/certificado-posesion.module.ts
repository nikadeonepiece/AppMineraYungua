import { Module } from '@nestjs/common';
import { CommonModule } from '@app/common';
import { CertificadoPosesionService } from './certificado-posesion.service';
import { CertificadoPosesionController } from './certificado-posesion.controller';

@Module({
  imports: [CommonModule],
  controllers: [CertificadoPosesionController],
  providers: [CertificadoPosesionService],
  exports: [CertificadoPosesionService],
})
export class CertificadoPosesionModule {}
