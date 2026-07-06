import { Module } from '@nestjs/common';
import { CommonModule } from '@app/common';
import { FotocheckService } from './fotocheck.service';
import { FotocheckController } from './fotocheck.controller';

@Module({
  imports: [CommonModule],
  controllers: [FotocheckController],
  providers: [FotocheckService],
})
export class FotocheckModule {}
