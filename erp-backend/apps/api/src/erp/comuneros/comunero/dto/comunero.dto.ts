import { IsBoolean, IsNotEmpty, IsOptional, IsString, Matches, MaxLength } from 'class-validator';
import { PartialType } from '@nestjs/mapped-types';

export class CreateComuneroDto {
  @IsString()
  @IsNotEmpty()
  @Matches(/^\d{8}$/, { message: 'El DNI debe tener 8 dígitos' })
  dni!: string;

  @IsString()
  @IsNotEmpty()
  @MaxLength(200)
  apellidos_nombres!: string;

  @IsOptional()
  @IsBoolean()
  consentimiento_biometrico?: boolean;
}

export class UpdateComuneroDto extends PartialType(CreateComuneroDto) {}
