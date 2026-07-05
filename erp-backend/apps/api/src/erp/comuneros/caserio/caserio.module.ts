import { Module } from '@nestjs/common';
import { CaserioService } from './caserio.service';
import { CaserioController } from './caserio.controller';

@Module({
  controllers: [CaserioController],
  providers: [CaserioService],
  exports: [CaserioService],
})
export class CaserioModule {}
