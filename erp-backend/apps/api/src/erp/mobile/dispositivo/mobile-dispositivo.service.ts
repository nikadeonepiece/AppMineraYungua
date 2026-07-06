import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';

@Injectable()
export class MobileDispositivoService {
  constructor(@InjectDataSource('APP_MINERA_YUNGUA_CONN') private readonly dataSource: DataSource) {}

  async register(deviceId: string, userId: number) {
    const normalized = String(deviceId || '').trim();
    if (!normalized) throw new NotFoundException('deviceId requerido');

    const [existing] = await this.dataSource.query(
      `SELECT id_dispositivo FROM dispositivo_movil WHERE device_id = ? AND estado_registro = 'ACTIVO'`,
      [normalized],
    );
    if (existing) {
      return { mensaje: 'Dispositivo ya registrado', id_dispositivo: existing.id_dispositivo };
    }

    const res = await this.dataSource.query(
      `INSERT INTO dispositivo_movil (device_id, activo, revocado, id_usuario_crea)
       VALUES (?, 0, 0, ?)`,
      [normalized, userId],
    );
    return { mensaje: 'Dispositivo registrado', id_dispositivo: Number(res.insertId) };
  }

  async activate(deviceId: string, userId: number) {
    const normalized = String(deviceId || '').trim();
    const res = await this.dataSource.query(
      `UPDATE dispositivo_movil
       SET activo = 1, revocado = 0, id_usuario_mod = ?
       WHERE device_id = ? AND estado_registro = 'ACTIVO'`,
      [userId, normalized],
    );
    if (!res.affectedRows) {
      throw new NotFoundException('Dispositivo no encontrado');
    }
    return { mensaje: 'Dispositivo activado' };
  }
}
