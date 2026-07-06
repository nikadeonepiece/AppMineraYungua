import { IsInt, IsNotEmpty, IsNumber, IsOptional, IsPositive, IsString, Min, MaxLength } from 'class-validator';
import { PartialType } from '@nestjs/mapped-types';

export class CreateParcelaDto {
  @IsInt()
  @Min(1)
  id_comunero!: number;

  @IsInt()
  @Min(1)
  id_caserio!: number;

  @IsOptional()
  @IsString()
  @IsNotEmpty()
  @MaxLength(150)
  denominacion?: string;

  @IsOptional()
  @IsString()
  @MaxLength(150)
  sector?: string;

  @IsOptional()
  @IsNumber()
  @IsPositive()
  hectareas?: number;

  @IsOptional()
  @IsString()
  colindante_este?: string;

  @IsOptional()
  @IsString()
  colindante_oeste?: string;

  @IsOptional()
  @IsString()
  colindante_norte?: string;

  @IsOptional()
  @IsString()
  colindante_sur?: string;
}

export class UpdateParcelaDto extends PartialType(CreateParcelaDto) {}
