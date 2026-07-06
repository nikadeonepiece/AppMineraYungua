import { Injectable } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';

const DEFAULT_LIMIT = 100;

@Injectable()
export class MobileSyncService {
  constructor(@InjectDataSource('APP_MINERA_YUNGUA_CONN') private readonly dataSource: DataSource) {}

  private buildPaged(items: any[], page: number, limit: number, total: number) {
    return {
      mensaje: 'Sincronización exitosa',
      items,
      page,
      limit,
      total,
      count: items.length,
      server_time: new Date().toISOString(),
    };
  }

  async syncEmpleados(updatedAfter?: string, page = 1, limit = DEFAULT_LIMIT) {
    const safePage = Math.max(1, Number(page) || 1);
    const safeLimit = Math.min(500, Math.max(1, Number(limit) || DEFAULT_LIMIT));
    const offset = (safePage - 1) * safeLimit;
    const cursor = updatedAfter ? new Date(updatedAfter) : new Date(0);

    const params: any[] = [cursor];
    const where = `WHERE p.estado_registro = 'ACTIVO' AND p.fecha_registro > ?`;

    const [rows, totalRes] = await Promise.all([
      this.dataSource.query(
        `SELECT
          p.id_personal AS id,
          p.dni,
          p.codigo_personal AS codigo_empleado,
          p.nombres,
          p.apellidos,
          a.nombre AS area,
          c.nombre AS cargo,
          1 AS activo,
          p.fecha_registro AS updated_at
        FROM personal p
        LEFT JOIN area a ON a.id_area = p.id_area AND a.estado_registro = 'ACTIVO'
        LEFT JOIN cargo c ON c.id_cargo = p.id_cargo AND c.estado_registro = 'ACTIVO'
        ${where}
        ORDER BY p.fecha_registro ASC
        LIMIT ? OFFSET ?`,
        [...params, safeLimit, offset],
      ),
      this.dataSource.query(`SELECT COUNT(*) AS total FROM personal p ${where}`, params),
    ]);

    return this.buildPaged(rows, safePage, safeLimit, Number(totalRes[0]?.total || 0));
  }

  async syncUsuarios(updatedAfter?: string, page = 1, limit = DEFAULT_LIMIT) {
    const safePage = Math.max(1, Number(page) || 1);
    const safeLimit = Math.min(500, Math.max(1, Number(limit) || DEFAULT_LIMIT));
    const offset = (safePage - 1) * safeLimit;
    const cursor = updatedAfter ? new Date(updatedAfter) : new Date(0);

    const params: any[] = [cursor];
    const where = `WHERE u.estado_registro = 'ACTIVO' AND u.fecha_registro > ?`;

    const [rows, totalRes] = await Promise.all([
      this.dataSource.query(
        `SELECT
          u.id_usuario AS id,
          u.correo AS username,
          u.id_rol AS rol_id,
          NULL AS empleado_id,
          1 AS activo,
          u.fecha_registro AS updated_at
        FROM sis_usuario u
        ${where}
        ORDER BY u.fecha_registro ASC
        LIMIT ? OFFSET ?`,
        [...params, safeLimit, offset],
      ),
      this.dataSource.query(`SELECT COUNT(*) AS total FROM sis_usuario u ${where}`, params),
    ]);

    return this.buildPaged(rows, safePage, safeLimit, Number(totalRes[0]?.total || 0));
  }

  async syncBiometria(updatedAfter?: string, page = 1, limit = DEFAULT_LIMIT) {
    const safePage = Math.max(1, Number(page) || 1);
    const safeLimit = Math.min(500, Math.max(1, Number(limit) || DEFAULT_LIMIT));
    const offset = (safePage - 1) * safeLimit;
    const cursor = updatedAfter ? new Date(updatedAfter) : new Date(0);

    const params: any[] = [cursor];
    const where = `WHERE pb.estado_registro = 'ACTIVO' AND pb.activo = 1 AND pb.fecha_registro > ?`;

    const [rows, totalRes] = await Promise.all([
      this.dataSource.query(
        `SELECT
          pb.id_biometria AS id,
          pb.id_personal AS empleado_id,
          pb.embedding_facial AS embedding,
          pb.activo,
          pb.fecha_registro AS updated_at
        FROM personal_biometria pb
        ${where}
        ORDER BY pb.fecha_registro ASC
        LIMIT ? OFFSET ?`,
        [...params, safeLimit, offset],
      ),
      this.dataSource.query(`SELECT COUNT(*) AS total FROM personal_biometria pb ${where}`, params),
    ]);

    const items = rows.map((row: any) => ({
      id: row.id,
      empleado_id: row.empleado_id,
      embedding: this.parseEmbedding(row.embedding),
      embedding_device: [],
      activo: row.activo === 1 || row.activo === true,
      updated_at: row.updated_at,
    }));

    return this.buildPaged(items, safePage, safeLimit, Number(totalRes[0]?.total || 0));
  }

  private parseEmbedding(raw: unknown): number[] {
    if (Array.isArray(raw)) {
      return raw.map((v) => Number(v)).filter((v) => Number.isFinite(v));
    }
    if (typeof raw === 'string') {
      try {
        const parsed = JSON.parse(raw);
        if (Array.isArray(parsed)) {
          return parsed.map((v) => Number(v)).filter((v) => Number.isFinite(v));
        }
      } catch {
        return [];
      }
    }
    return [];
  }
}
