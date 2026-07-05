import { IsInt, IsNotEmpty, IsOptional, IsString, Min, MaxLength } from 'class-validator';
import { PartialType } from '@nestjs/mapped-types';

export class CreateCaserioDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  nombre!: string;

  @IsOptional()
  @IsInt()
  @Min(1)
  id_comunidad_campesina?: number;

  @IsOptional()
  @IsInt()
  @Min(1)
  id_caserio_padre?: number;
}

export class UpdateCaserioDto extends PartialType(CreateCaserioDto) {}
