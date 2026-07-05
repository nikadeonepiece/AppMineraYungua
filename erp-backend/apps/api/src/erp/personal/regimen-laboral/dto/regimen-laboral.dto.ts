import { IsInt, IsNotEmpty, IsOptional, IsString, Min, MaxLength } from 'class-validator';
import { PartialType } from '@nestjs/mapped-types';

export class CreateRegimenLaboralDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(50)
  nombre!: string;

  @IsOptional()
  @IsInt()
  @Min(1)
  dias_trabajo?: number;

  @IsOptional()
  @IsInt()
  @Min(1)
  dias_descanso?: number;
}

export class UpdateRegimenLaboralDto extends PartialType(CreateRegimenLaboralDto) {}
