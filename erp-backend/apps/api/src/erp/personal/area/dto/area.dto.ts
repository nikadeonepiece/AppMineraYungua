import { IsNotEmpty, IsString, MaxLength } from 'class-validator';
import { PartialType } from '@nestjs/mapped-types';

export class CreateAreaDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  nombre!: string;
}

export class UpdateAreaDto extends PartialType(CreateAreaDto) {}
