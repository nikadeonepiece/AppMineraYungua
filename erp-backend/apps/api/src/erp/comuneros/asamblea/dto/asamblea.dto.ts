import { ArrayMinSize, IsArray, IsDateString, IsIn, IsInt, IsNotEmpty, IsOptional, IsString, Min, MaxLength } from 'class-validator';
import { PartialType } from '@nestjs/mapped-types';

const ESTADOS_ASAMBLEA = ['PROGRAMADA', 'REALIZADA', 'CERRADA'];

export class CreateAsambleaDto {
  @IsArray()
  @ArrayMinSize(1)
  @IsInt({ each: true })
  @Min(1, { each: true })
  id_caserios!: number[];

  @IsOptional()
  @IsString()
  @IsNotEmpty()
  @MaxLength(200)
  titulo?: string;

  @IsOptional()
  @IsDateString()
  fecha?: string;
}

export class UpdateAsambleaDto extends PartialType(CreateAsambleaDto) {
  @IsOptional()
  @IsIn(ESTADOS_ASAMBLEA)
  estado?: string;
}
