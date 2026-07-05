import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';
import { AuditoriaService } from '@app/common';
import { CreateComunidadCampesinaDto, UpdateComunidadCampesinaDto } from './dto/comunidad-campesina.dto';

const SELECT_COLS = `
  id_comunidad_campesina, nombre, distrito, provincia, departamento,
  numero_partida_registral, oficina_registral
`;

@Injectable()
export class ComunidadCampesinaService {
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
      where += ` AND (nombre LIKE ? OR distrito LIKE ? OR provincia LIKE ? OR departamento LIKE ?)`;
      const term = `%${String(query.search).trim()}%`;
      params.push(term, term, term, term);
    }

    const sql = `SELECT ${SELECT_COLS} FROM comunidad_campesina ${where} ORDER BY nombre ASC LIMIT ? OFFSET ?`;

    if (isExport) {
      return this.dataSource.query(sql, [...params, limit, offset]);
    }

    const [data, totalRes] = await Promise.all([
      this.dataSource.query(sql, [...params, limit, offset]),
      this.dataSource.query(`SELECT COUNT(*) as total FROM comunidad_campesina ${where}`, params),
    ]);

    return { data, meta: { total: Number(totalRes[0]?.total || 0), page, limit } };
  }

  async findOne(id: number) {
    const [row] = await this.dataSource.query(
      `SELECT ${SELECT_COLS} FROM comunidad_campesina WHERE id_comunidad_campesina = ? AND estado_registro = 'ACTIVO'`,
      [id],
    );
    if (!row) throw new NotFoundException('Comunidad campesina no encontrada');
    return row;
  }

  async create(dto: CreateComunidadCampesinaDto, userId: number) {
    const nombre = dto.nombre.trim().toUpperCase();
    const distrito = dto.distrito?.trim().toUpperCase() || null;
    const provincia = dto.provincia?.trim().toUpperCase() || null;
    const departamento = dto.departamento?.trim().toUpperCase() || null;
    const numeroPartidaRegistral = dto.numero_partida_registral?.trim() || null;
    const oficinaRegistral = dto.oficina_registral?.trim().toUpperCase() || null;

    const res = await this.dataSource.query(
      `INSERT INTO comunidad_campesina (
        nombre, distrito, provincia, departamento, numero_partida_registral, oficina_registral, id_usuario_crea
      ) VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [nombre, distrito, provincia, departamento, numeroPartidaRegistral, oficinaRegistral, userId],
    );
    const id = Number(res.insertId);
    const nuevo = { nombre, distrito, provincia, departamento, numero_partida_registral: numeroPartidaRegistral, oficina_registral: oficinaRegistral };
    await this.auditoriaService.registrar('comunidad_campesina', id, 'CREAR', userId, null, nuevo);
    return { id_comunidad_campesina: id, ...nuevo };
  }

  async update(id: number, dto: UpdateComunidadCampesinaDto, userId: number) {
    const antiguo = await this.findOne(id);

    const nombre = dto.nombre ? dto.nombre.trim().toUpperCase() : antiguo.nombre;
    const distrito = dto.distrito !== undefined ? (dto.distrito?.trim().toUpperCase() || null) : antiguo.distrito;
    const provincia = dto.provincia !== undefined ? (dto.provincia?.trim().toUpperCase() || null) : antiguo.provincia;
    const departamento = dto.departamento !== undefined ? (dto.departamento?.trim().toUpperCase() || null) : antiguo.departamento;
    const numeroPartidaRegistral = dto.numero_partida_registral !== undefined
      ? (dto.numero_partida_registral?.trim() || null)
      : antiguo.numero_partida_registral;
    const oficinaRegistral = dto.oficina_registral !== undefined
      ? (dto.oficina_registral?.trim().toUpperCase() || null)
      : antiguo.oficina_registral;

    const res = await this.dataSource.query(
      `UPDATE comunidad_campesina SET
        nombre = ?, distrito = ?, provincia = ?, departamento = ?,
        numero_partida_registral = ?, oficina_registral = ?, id_usuario_mod = ?
      WHERE id_comunidad_campesina = ? AND estado_registro = 'ACTIVO'`,
      [nombre, distrito, provincia, departamento, numeroPartidaRegistral, oficinaRegistral, userId, id],
    );
    if (res.affectedRows === 0) throw new NotFoundException('Comunidad campesina no encontrada o ya eliminada');

    const nuevo = { nombre, distrito, provincia, departamento, numero_partida_registral: numeroPartidaRegistral, oficina_registral: oficinaRegistral };
    await this.auditoriaService.registrar('comunidad_campesina', id, 'ACTUALIZAR', userId, antiguo, nuevo);
    return { id_comunidad_campesina: id, ...nuevo };
  }

  async remove(id: number, userId: number) {
    const antiguo = await this.findOne(id);

    const [{ total }] = await this.dataSource.query(
      `SELECT COUNT(*) as total FROM caserio WHERE id_comunidad_campesina = ? AND estado_registro = 'ACTIVO'`,
      [id],
    );
    if (Number(total) > 0) {
      throw new ConflictException('No se puede eliminar: la comunidad campesina tiene caseríos activos asociados.');
    }

    const res = await this.dataSource.query(
      `UPDATE comunidad_campesina SET estado_registro = 'ELIMINADO', id_usuario_mod = ? WHERE id_comunidad_campesina = ? AND estado_registro = 'ACTIVO'`,
      [userId, id],
    );
    if (res.affectedRows === 0) throw new NotFoundException('Comunidad campesina no encontrada o ya eliminada');

    await this.auditoriaService.registrar('comunidad_campesina', id, 'ELIMINAR', userId, antiguo, null);
    return { mensaje: 'Comunidad campesina eliminada correctamente' };
  }
}
