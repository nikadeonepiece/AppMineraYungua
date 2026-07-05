import { IsIn, IsInt, IsNotEmpty, IsNumber, IsOptional, IsString, Min, IsDateString } from 'class-validator';

export class CreateMarcacionDto {
  @IsInt()
  @Min(1)
  id_personal!: number;

  @IsIn(['FACIAL', 'QR', 'MANUAL'])
  metodo!: 'FACIAL' | 'QR' | 'MANUAL';

  @IsOptional()
  @IsDateString()
  fecha_hora?: string;

  @IsOptional()
  @IsInt()
  @Min(1)
  id_dispositivo?: number;

  @IsOptional()
  @IsNumber()
  latitud?: number;

  @IsOptional()
  @IsNumber()
  longitud?: number;

  @IsOptional()
  @IsString()
  @IsNotEmpty()
  hash_unico?: string;
}
