import { IsBoolean, IsIn, IsInt, IsOptional, IsString, Min, MaxLength } from 'class-validator';

const METODOS_ASISTENCIA = ['FACIAL', 'QR', 'MANUAL'];

export class MarcarAsistenciaAsambleaDto {
  @IsInt()
  @Min(1)
  id_comunero!: number;

  @IsOptional()
  @IsBoolean()
  firmo?: boolean;

  @IsOptional()
  @IsIn(METODOS_ASISTENCIA)
  metodo?: string;

  @IsOptional()
  @IsString()
  @MaxLength(255)
  observaciones?: string;
}
