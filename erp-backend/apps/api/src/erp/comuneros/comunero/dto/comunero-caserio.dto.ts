import { IsInt, Min } from 'class-validator';

export class AddComuneroCaserioDto {
  @IsInt()
  @Min(1)
  id_caserio!: number;
}
