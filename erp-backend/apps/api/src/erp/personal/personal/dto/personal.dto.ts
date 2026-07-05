import {
  IsBoolean,
  IsDateString,
  IsEmail,
  IsIn,
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
  Matches,
  MaxLength,
  Min,
} from 'class-validator';
import { PartialType } from '@nestjs/mapped-types';

export class CreatePersonalDto {
  @IsString()
  @Matches(/^\d{8}$/, { message: 'dni debe tener 8 dígitos' })
  dni!: string;

  @IsOptional()
  @IsString()
  @MaxLength(30)
  codigo_personal?: string;

  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  nombres!: string;

  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  apellidos!: string;

  @IsOptional()
  @IsString()
  @MaxLength(20)
  telefono?: string;

  @IsOptional()
  @IsEmail()
  correo?: string;

  @IsOptional()
  @IsDateString()
  fecha_nacimiento?: string;

  @IsOptional()
  @IsIn(['M', 'F'])
  sexo?: string;

  @IsOptional()
  @IsDateString()
  fecha_ingreso?: string;

  @IsOptional()
  @IsInt()
  @Min(1)
  id_area?: number;

  @IsOptional()
  @IsInt()
  @Min(1)
  id_cargo?: number;

  @IsOptional()
  @IsInt()
  @Min(1)
  id_regimen?: number;

  @IsOptional()
  @IsInt()
  @Min(1)
  id_comunero?: number;

  @IsOptional()
  @IsString()
  @MaxLength(120)
  centro_trabajo?: string;

  @IsOptional()
  @IsString()
  @MaxLength(255)
  observaciones?: string;

  @IsOptional()
  @IsBoolean()
  consentimiento_biometrico?: boolean;
}

export class UpdatePersonalDto extends PartialType(CreatePersonalDto) {}
