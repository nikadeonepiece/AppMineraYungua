import { BadRequestException, Injectable } from '@nestjs/common';
import { existsSync, mkdirSync, unlinkSync, writeFileSync } from 'fs';
import { extname, join } from 'path';

const ALLOWED_EXT = new Set(['.jpg', '.jpeg', '.png', '.webp']);
const MAX_BYTES = 5 * 1024 * 1024;

@Injectable()
export class UploadService {
  private readonly uploadsRoot = join(process.cwd(), 'uploads');

  saveImage(subdir: string, file: Express.Multer.File, namePrefix: string): string {
    if (!file?.buffer?.length) {
      throw new BadRequestException('No se recibió el archivo');
    }

    const ext = extname(file.originalname || '').toLowerCase();
    if (!ALLOWED_EXT.has(ext)) {
      throw new BadRequestException('Formato no permitido. Use JPG, PNG o WEBP');
    }
    if (file.size > MAX_BYTES) {
      throw new BadRequestException('El archivo no debe superar 5 MB');
    }

    const dir = join(this.uploadsRoot, subdir);
    if (!existsSync(dir)) {
      mkdirSync(dir, { recursive: true });
    }

    const safePrefix = String(namePrefix).replace(/[^a-zA-Z0-9_-]/g, '_');
    const filename = `${safePrefix}_${Date.now()}${ext}`;
    writeFileSync(join(dir, filename), file.buffer);

    return `${subdir}/${filename}`.replace(/\\/g, '/');
  }

  deleteIfExists(relativePath: string | null | undefined): void {
    if (!relativePath?.trim()) return;
    const rel = relativePath.replace(/^uploads[\\/]/, '').replace(/^\/+/, '');
    const full = join(this.uploadsRoot, rel);
    if (existsSync(full)) {
      unlinkSync(full);
    }
  }
}
