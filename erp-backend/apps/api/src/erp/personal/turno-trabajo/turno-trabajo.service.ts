import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';
import { AuditoriaService } from '@app/common';
import { CreateTurnoTrabajoDto, UpdateTurnoTrabajoDto } from './dto/turno-trabajo.dto';

@Injectable()
export class TurnoTrabajoService {
  constructor(
    @InjectDataSource('APP_MINERA_YUNGUA_CONN') private dataSource: DataSource,
    private readonly auditoriaService: AuditoriaService,
  ) {}

  async findAll(query: any) {
    const isExport = query.isExport === true;
    const page = isExport ? 1 : Number(query.page) || 1;
    const limit = isExport ? 5000 : Number(query.limit) || 10;
    const offset = (page - 1) * limit;

    const params: any[] = [];
    let where = `WHERE estado_registro = 'ACTIVO'`;
    if (query.search) {
      where += ` AND nombre_turno LIKE ?`;
      params.push(`%${String(query.search).trim()}%`);
    }

    const sql = `SELECT id_turno, nombre_turno, descripcion, hora_inicio, hora_fin FROM turno_trabajo ${where} ORDER BY nombre_turno ASC LIMIT ? OFFSET ?`;

    if (isExport) {
      return this.dataSource.query(sql, [...params, limit, offset]);
    }

    const [data, totalRes] = await Promise.all([
      this.dataSource.query(sql, [...params, limit, offset]),
      this.dataSource.query(`SELECT COUNT(*) as total FROM turno_trabajo ${where}`, params),
    ]);

    return { data, meta: { total: Number(totalRes[0]?.total || 0), page, limit } };
  }

  async findOne(id: number) {
    const [row] = await this.dataSource.query(
      `SELECT id_turno, nombre_turno, descripcion, hora_inicio, hora_fin FROM turno_trabajo WHERE id_turno = ? AND estado_registro = 'ACTIVO'`,
      [id],
    );
    if (!row) throw new NotFoundException('Turno de trabajo no encontrado');
    return row;
  }

  async create(dto: CreateTurnoTrabajoDto, userId: number) {
    const nombreTurno = dto.nombre_turno.trim().toUpperCase();
    const descripcion = dto.descripcion?.trim() || null;

    const res = await this.dataSource.query(
      `INSERT INTO turno_trabajo (nombre_turno, descripcion, hora_inicio, hora_fin, id_usuario_crea) VALUES (?, ?, ?, ?, ?)`,
      [nombreTurno, descripcion, dto.hora_inicio ?? null, dto.hora_fin ?? null, userId],
    );
    const id = Number(res.insertId);
    await this.auditoriaService.registrar('turno_trabajo', id, 'CREAR', userId, null, { ...dto, nombreTurno });
    return { id_turno: id, nombre_turno: nombreTurno, descripcion, hora_inicio: dto.hora_inicio ?? null, hora_fin: dto.hora_fin ?? null };
  }

  async update(id: number, dto: UpdateTurnoTrabajoDto, userId: number) {
    const antiguo = await this.findOne(id);
    const nombreTurno = dto.nombre_turno ? dto.nombre_turno.trim().toUpperCase() : antiguo.nombre_turno;
    const descripcion = dto.descripcion !== undefined ? (dto.descripcion?.trim() || null) : antiguo.descripcion;
    const horaInicio = dto.hora_inicio ?? antiguo.hora_inicio;
    const horaFin = dto.hora_fin ?? antiguo.hora_fin;

    const res = await this.dataSource.query(
      `UPDATE turno_trabajo SET nombre_turno = ?, descripcion = ?, hora_inicio = ?, hora_fin = ?, id_usuario_mod = ? WHERE id_turno = ? AND estado_registro = 'ACTIVO'`,
      [nombreTurno, descripcion, horaInicio, horaFin, userId, id],
    );
    if (res.affectedRows === 0) throw new NotFoundException('Turno de trabajo no encontrado o ya eliminado');

    await this.auditoriaService.registrar('turno_trabajo', id, 'ACTUALIZAR', userId, antiguo, { nombreTurno, descripcion, horaInicio, horaFin });
    return { id_turno: id, nombre_turno: nombreTurno, descripcion, hora_inicio: horaInicio, hora_fin: horaFin };
  }

  async remove(id: number, userId: number) {
    const antiguo = await this.findOne(id);

    const res = await this.dataSource.query(
      `UPDATE turno_trabajo SET estado_registro = 'ELIMINADO', id_usuario_mod = ? WHERE id_turno = ? AND estado_registro = 'ACTIVO'`,
      [userId, id],
    );
    if (res.affectedRows === 0) throw new NotFoundException('Turno de trabajo no encontrado o ya eliminado');

    await this.auditoriaService.registrar('turno_trabajo', id, 'ELIMINAR', userId, antiguo, null);
    return { mensaje: 'Turno de trabajo eliminado correctamente' };
  }
}
