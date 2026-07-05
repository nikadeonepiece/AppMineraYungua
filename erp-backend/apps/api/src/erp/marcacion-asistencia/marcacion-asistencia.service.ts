import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';
import { AuditoriaService } from '@app/common';
import { CreateMarcacionDto } from './dto/marcacion.dto';

@Injectable()
export class MarcacionAsistenciaService {
  constructor(
    @InjectDataSource('APP_MINERA_YUNGUA_CONN') private dataSource: DataSource,
    private readonly auditoriaService: AuditoriaService,
  ) {}

  async registrar(dto: CreateMarcacionDto, userId: number) {
    const [personal] = await this.dataSource.query(
      `SELECT id_personal FROM personal WHERE id_personal = ? AND estado_registro = 'ACTIVO'`,
      [dto.id_personal],
    );
    if (!personal) throw new NotFoundException('Trabajador no encontrado');

    // Idempotencia: si la app reenvía la misma marcación (reintento offline), devolvemos la ya guardada.
    if (dto.hash_unico) {
      const [existente] = await this.dataSource.query(
        `SELECT * FROM marcacion_asistencia WHERE hash_unico = ?`,
        [dto.hash_unico],
      );
      if (existente) return { mensaje: 'Marcación ya registrada', data: existente };
    }

    if (dto.id_dispositivo) {
      const [dispositivo] = await this.dataSource.query(
        `SELECT id_dispositivo FROM dispositivo_movil WHERE id_dispositivo = ? AND activo = 1 AND revocado = 0 AND estado_registro = 'ACTIVO'`,
        [dto.id_dispositivo],
      );
      if (!dispositivo) throw new ConflictException('Dispositivo no autorizado o revocado');
    }

    const fechaHora = dto.fecha_hora ? new Date(dto.fecha_hora) : new Date();
    const fecha = fechaHora.toISOString().slice(0, 10);

    const queryRunner = this.dataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
      // El tipo de evento lo decide el backend (nunca el cliente): alterna
      // según cuál fue la última marcación de HOY para este trabajador.
      const [ultima] = await queryRunner.query(
        `SELECT tipo_evento FROM marcacion_asistencia
         WHERE id_personal = ? AND DATE(fecha_hora) = ?
         ORDER BY fecha_hora DESC LIMIT 1`,
        [dto.id_personal, fecha],
      );
      const tipoEvento: 'ENTRADA' | 'SALIDA' = !ultima || ultima.tipo_evento === 'SALIDA' ? 'ENTRADA' : 'SALIDA';

      const resInsert = await queryRunner.query(
        `INSERT INTO marcacion_asistencia
          (id_personal, tipo_evento, fecha_hora, metodo, id_dispositivo, latitud, longitud, hash_unico, id_usuario_crea)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          dto.id_personal,
          tipoEvento,
          fechaHora,
          dto.metodo,
          dto.id_dispositivo ?? null,
          dto.latitud ?? null,
          dto.longitud ?? null,
          dto.hash_unico ?? null,
          userId,
        ],
      );
      const idMarcacion = Number(resInsert.insertId);

      if (tipoEvento === 'ENTRADA') {
        await queryRunner.query(
          `INSERT INTO asistencia_diaria (id_personal, fecha, hora_entrada, tipo_asistencia, id_usuario_crea)
           VALUES (?, ?, ?, 'ASISTIO', ?)
           ON DUPLICATE KEY UPDATE
             hora_entrada = IF(hora_entrada IS NULL, VALUES(hora_entrada), hora_entrada)`,
          [dto.id_personal, fecha, fechaHora, userId],
        );
      } else {
        await queryRunner.query(
          `UPDATE asistencia_diaria
           SET hora_salida = ?,
               horas_trabajadas = ROUND(TIMESTAMPDIFF(MINUTE, hora_entrada, ?) / 60, 2),
               id_usuario_mod = ?
           WHERE id_personal = ? AND fecha = ?`,
          [fechaHora, fechaHora, userId, dto.id_personal, fecha],
        );
      }

      await this.auditoriaService.registrarConTransaccion(
        queryRunner, 'marcacion_asistencia', idMarcacion, 'CREAR', userId, null,
        { id_personal: dto.id_personal, tipo_evento: tipoEvento, metodo: dto.metodo },
      );

      await queryRunner.commitTransaction();
      return { mensaje: 'Marcación registrada correctamente', data: { id_marcacion: idMarcacion, tipo_evento: tipoEvento, fecha_hora: fechaHora } };
    } catch (error: any) {
      await queryRunner.rollbackTransaction();
      if (error.code === 'ER_DUP_ENTRY') throw new ConflictException('Marcación duplicada');
      throw error;
    } finally {
      await queryRunner.release();
    }
  }

  async findAll(query: any) {
    const params: any[] = [];
    let where = `WHERE m.estado_registro = 'ACTIVO'`;
    if (query.id_personal) {
      where += ` AND m.id_personal = ?`;
      params.push(Number(query.id_personal));
    }
    if (query.fecha) {
      where += ` AND DATE(m.fecha_hora) = ?`;
      params.push(query.fecha);
    }

    const page = Number(query.page) || 1;
    const limit = Number(query.limit) || 20;
    const offset = (page - 1) * limit;

    const sql = `
      SELECT m.id_marcacion, m.id_personal, p.nombres, p.apellidos, m.tipo_evento,
             m.fecha_hora, m.metodo, m.id_dispositivo, d.ubicacion
      FROM marcacion_asistencia m
      INNER JOIN personal p ON p.id_personal = m.id_personal
      LEFT JOIN dispositivo_movil d ON d.id_dispositivo = m.id_dispositivo
      ${where}
      ORDER BY m.fecha_hora DESC
      LIMIT ? OFFSET ?
    `;

    const [data, totalRes] = await Promise.all([
      this.dataSource.query(sql, [...params, limit, offset]),
      this.dataSource.query(`SELECT COUNT(*) as total FROM marcacion_asistencia m ${where}`, params),
    ]);

    return { data, meta: { total: Number(totalRes[0]?.total || 0), page, limit } };
  }

  async resumenDiario(query: any) {
    const params: any[] = [];
    let where = `WHERE a.estado_registro = 'ACTIVO'`;
    if (query.id_personal) {
      where += ` AND a.id_personal = ?`;
      params.push(Number(query.id_personal));
    }
    if (query.fecha) {
      where += ` AND a.fecha = ?`;
      params.push(query.fecha);
    }

    const page = Number(query.page) || 1;
    const limit = Number(query.limit) || 20;
    const offset = (page - 1) * limit;

    const sql = `
      SELECT a.id_asistencia_diaria, a.id_personal, p.nombres, p.apellidos, a.fecha,
             a.hora_entrada, a.hora_salida, a.horas_trabajadas, a.tardanza,
             a.minutos_tardanza, a.salida_anticipada, a.tipo_asistencia
      FROM asistencia_diaria a
      INNER JOIN personal p ON p.id_personal = a.id_personal
      ${where}
      ORDER BY a.fecha DESC, p.apellidos ASC
      LIMIT ? OFFSET ?
    `;

    const [data, totalRes] = await Promise.all([
      this.dataSource.query(sql, [...params, limit, offset]),
      this.dataSource.query(`SELECT COUNT(*) as total FROM asistencia_diaria a ${where}`, params),
    ]);

    return { data, meta: { total: Number(totalRes[0]?.total || 0), page, limit } };
  }
}
