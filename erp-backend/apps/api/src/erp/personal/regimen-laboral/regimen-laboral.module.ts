import { Module } from '@nestjs/common';
import { RegimenLaboralService } from './regimen-laboral.service';
import { RegimenLaboralController } from './regimen-laboral.controller';

@Module({
  controllers: [RegimenLaboralController],
  providers: [RegimenLaboralService],
  exports: [RegimenLaboralService],
})
export class RegimenLaboralModule {}
