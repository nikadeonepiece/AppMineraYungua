import { IsNotEmpty, IsOptional, IsString, Matches, MaxLength } from 'class-validator';
import { PartialType } from '@nestjs/mapped-types';

const HORA_REGEX = /^([01]\d|2[0-3]):([0-5]\d)(:[0-5]\d)?$/;

export class CreateTurnoTrabajoDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(50)
  nombre_turno!: string;

  @IsOptional()
  @IsString()
  @MaxLength(100)
  descripcion?: string;

  @IsOptional()
  @Matches(HORA_REGEX, { message: 'hora_inicio debe tener formato HH:mm' })
  hora_inicio?: string;

  @IsOptional()
  @Matches(HORA_REGEX, { message: 'hora_fin debe tener formato HH:mm' })
  hora_fin?: string;
}

export class UpdateTurnoTrabajoDto extends PartialType(CreateTurnoTrabajoDto) {}
