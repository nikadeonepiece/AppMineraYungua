import { IsBoolean, IsInt, IsNotEmpty, IsOptional, IsString, MaxLength, Min } from 'class-validator';
import { PartialType } from '@nestjs/mapped-types';

export class CreateCargoDto {
  @IsInt()
  @Min(1)
  id_area!: number;

  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  nombre!: string;

  @IsOptional()
  @IsBoolean()
  requiere_brevete?: boolean;
}

export class UpdateCargoDto extends PartialType(CreateCargoDto) {}
