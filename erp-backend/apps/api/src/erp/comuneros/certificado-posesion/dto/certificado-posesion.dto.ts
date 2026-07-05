import { IsDateString, IsInt, IsOptional, Min } from 'class-validator';
import { PartialType } from '@nestjs/mapped-types';

export class CreateCertificadoPosesionDto {
  @IsInt()
  @Min(1)
  id_parcela!: number;

  @IsInt()
  @Min(1)
  id_comunero!: number;

  @IsOptional()
  @IsDateString()
  fecha_emision?: string;
}

export class UpdateCertificadoPosesionDto extends PartialType(CreateCertificadoPosesionDto) {}
