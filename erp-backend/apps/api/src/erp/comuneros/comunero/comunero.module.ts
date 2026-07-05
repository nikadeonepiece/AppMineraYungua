import { Module } from '@nestjs/common';
import { ComuneroService } from './comunero.service';
import { ComuneroController } from './comunero.controller';

@Module({
  controllers: [ComuneroController],
  providers: [ComuneroService],
  exports: [ComuneroService],
})
export class ComuneroModule {}
