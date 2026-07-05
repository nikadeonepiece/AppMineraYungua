import { Module } from '@nestjs/common';
import { AsambleaService } from './asamblea.service';
import { AsambleaController } from './asamblea.controller';

@Module({
  controllers: [AsambleaController],
  providers: [AsambleaService],
  exports: [AsambleaService],
})
export class AsambleaModule {}
