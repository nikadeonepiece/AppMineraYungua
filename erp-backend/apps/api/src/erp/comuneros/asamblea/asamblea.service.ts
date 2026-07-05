import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';
import { AuditoriaService } from '@app/common';
import { CreateAsambleaDto, UpdateAsambleaDto } from './dto/asamblea.dto';
import { MarcarAsistenciaAsambleaDto } from './dto/asistencia-asamblea.dto';

const SELECT_LISTADO = `
  SELECT
    a.id_asamblea, a.titulo, a.fecha, a.estado,
    GROUP_CONCAT(c.id_caserio ORDER BY c.nombre SEPARATOR ',') AS id_caserios_csv,
    GROUP_CONCAT(c.nombre ORDER BY c.nombre SEPARATOR ', ') AS nombre_caserios
  FROM asamblea a
  JOIN asamblea_caserio ac ON ac.id_asamblea = a.id_asamblea AND ac.estado_registro = 'ACTIVO'
  JOIN caserio c ON c.id_caserio = ac.id_caserio AND c.estado_registro = 'ACTIVO'
`;

function mapRow(row: any) {
  if (!row) return row;
  const { id_caserios_csv, ...rest } = row;
  return { ...rest, id_caserios: id_caserios_csv ? id_caserios_csv.split(',').map(Number) : [] };
}

@Injectable()
export class AsambleaService {
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
    let where = `WHERE a.estado_registro = 'ACTIVO'`;
    if (query.search) {
      where += ` AND a.id_asamblea IN (
        SELECT a2.id_asamblea FROM asamblea a2
        JOIN asamblea_caserio ac2 ON ac2.id_asamblea = a2.id_asamblea AND ac2.estado_registro = 'ACTIVO'
        JOIN caserio c2 ON c2.id_caserio = ac2.id_caserio
        WHERE a2.titulo LIKE ? OR c2.nombre LIKE ?
      )`;
      const term = `%${String(query.search).trim()}%`;
      params.push(term, term);
    }
    if (query.id_caserio) {
      where += ` AND a.id_asamblea IN (SELECT id_asamblea FROM asamblea_caserio WHERE id_caserio = ? AND estado_registro = 'ACTIVO')`;
      params.push(Number(query.id_caserio));
    }

    const sql = `${SELECT_LISTADO} ${where} GROUP BY a.id_asamblea ORDER BY a.fecha DESC, a.id_asamblea DESC LIMIT ? OFFSET ?`;

    if (isExport) {
      const rows = await this.dataSource.query(sql, [...params, limit, offset]);
      return rows.map(mapRow);
    }

    const [data, totalRes] = await Promise.all([
      this.dataSource.query(sql, [...params, limit, offset]),
      this.dataSource.query(`SELECT COUNT(*) as total FROM asamblea a ${where}`, params),
    ]);

    return { data: data.map(mapRow), meta: { total: Number(totalRes[0]?.total || 0), page, limit } };
  }

  async findOne(id: number) {
    const [row] = await this.dataSource.query(
      `${SELECT_LISTADO} WHERE a.id_asamblea = ? AND a.estado_registro = 'ACTIVO' GROUP BY a.id_asamblea`,
      [id],
    );
    if (!row) throw new NotFoundException('Asamblea no encontrada');
    return mapRow(row);
  }

  async findAsistencia(idAsamblea: number) {
    return this.dataSource.query(
      `SELECT aa.id_asistencia, aa.id_comunero, c.apellidos_nombres, c.dni, aa.firmo, aa.metodo, aa.observaciones
       FROM asistencia_asamblea aa
       JOIN comunero c ON c.id_comunero = aa.id_comunero
       WHERE aa.id_asamblea = ? AND aa.estado_registro = 'ACTIVO'
       ORDER BY c.apellidos_nombres ASC`,
      [idAsamblea],
    );
  }

  async findComuneros(idAsamblea: number) {
    await this.findOne(idAsamblea);
    return this.dataSource.query(
      `SELECT DISTINCT c.id_comunero, c.apellidos_nombres, c.dni
       FROM comunero_caserio cc
       JOIN comunero c ON c.id_comunero = cc.id_comunero AND c.estado_registro = 'ACTIVO'
       WHERE cc.estado_registro = 'ACTIVO'
         AND cc.id_caserio IN (SELECT id_caserio FROM asamblea_caserio WHERE id_asamblea = ? AND estado_registro = 'ACTIVO')
       ORDER BY c.apellidos_nombres ASC`,
      [idAsamblea],
    );
  }

  private async assertCaseriosActivos(idCaserios: number[]) {
    if (!idCaserios || idCaserios.length === 0) return;
    const [row] = await this.dataSource.query(
      `SELECT COUNT(*) as total FROM caserio WHERE id_caserio IN (${idCaserios.map(() => '?').join(',')}) AND estado_registro = 'ACTIVO'`,
      idCaserios,
    );
    if (Number(row.total) !== idCaserios.length) {
      throw new NotFoundException('Uno o más caseríos seleccionados no existen o fueron eliminados');
    }
  }

  async create(dto: CreateAsambleaDto, userId: number) {
    const idCaserios = [...new Set(dto.id_caserios)];
    await this.assertCaseriosActivos(idCaserios);

    const titulo = dto.titulo?.trim().toUpperCase() || null;
    const fecha = dto.fecha || null;

    const res = await this.dataSource.query(
      `INSERT INTO asamblea (titulo, fecha, id_usuario_crea) VALUES (?, ?, ?)`,
      [titulo, fecha, userId],
    );
    const id = Number(res.insertId);

    const values = idCaserios.map((idCaserio) => [id, idCaserio, userId]);
    const placeholders = values.map(() => '(?, ?, ?)').join(', ');
    await this.dataSource.query(
      `INSERT INTO asamblea_caserio (id_asamblea, id_caserio, id_usuario_crea) VALUES ${placeholders}`,
      values.flat(),
    );

    const nuevo = { titulo, fecha, estado: 'PROGRAMADA', id_caserios: idCaserios };
    await this.auditoriaService.registrar('asamblea', id, 'CREAR', userId, null, nuevo);
    return { id_asamblea: id, ...nuevo };
  }

  async update(id: number, dto: UpdateAsambleaDto, userId: number) {
    const antiguo = await this.findOne(id);

    const titulo = dto.titulo !== undefined ? (dto.titulo?.trim().toUpperCase() || null) : antiguo.titulo;
    const fecha = dto.fecha !== undefined ? dto.fecha : antiguo.fecha;
    const estado = dto.estado ?? antiguo.estado;

    const res = await this.dataSource.query(
      `UPDATE asamblea SET titulo = ?, fecha = ?, estado = ?, id_usuario_mod = ?
       WHERE id_asamblea = ? AND estado_registro = 'ACTIVO'`,
      [titulo, fecha, estado, userId, id],
    );
    if (res.affectedRows === 0) throw new NotFoundException('Asamblea no encontrada o ya eliminada');

    let idCaserios: number[] = antiguo.id_caserios;
    if (dto.id_caserios) {
      idCaserios = [...new Set(dto.id_caserios)];
      await this.assertCaseriosActivos(idCaserios);

      await this.dataSource.query(
        `UPDATE asamblea_caserio SET estado_registro = 'ELIMINADO', id_usuario_mod = ?
         WHERE id_asamblea = ? AND estado_registro = 'ACTIVO' AND id_caserio NOT IN (${idCaserios.map(() => '?').join(',')})`,
        [userId, id, ...idCaserios],
      );

      const existentes = await this.dataSource.query(
        `SELECT id_caserio FROM asamblea_caserio WHERE id_asamblea = ? AND estado_registro = 'ACTIVO'`,
        [id],
      );
      const existentesSet = new Set(existentes.map((r: any) => Number(r.id_caserio)));
      const nuevos = idCaserios.filter((idCaserio) => !existentesSet.has(idCaserio));
      if (nuevos.length > 0) {
        const values = nuevos.map((idCaserio) => [id, idCaserio, userId]);
        const placeholders = values.map(() => '(?, ?, ?)').join(', ');
        await this.dataSource.query(
          `INSERT INTO asamblea_caserio (id_asamblea, id_caserio, id_usuario_crea) VALUES ${placeholders}
           ON DUPLICATE KEY UPDATE estado_registro = 'ACTIVO', id_usuario_mod = VALUES(id_usuario_crea)`,
          values.flat(),
        );
      }
    }

    const nuevo = { titulo, fecha, estado, id_caserios: idCaserios };
    await this.auditoriaService.registrar('asamblea', id, 'ACTUALIZAR', userId, antiguo, nuevo);
    return { id_asamblea: id, ...nuevo };
  }

  async marcarAsistencia(idAsamblea: number, dto: MarcarAsistenciaAsambleaDto, userId: number) {
    await this.findOne(idAsamblea);

    const [comunero] = await this.dataSource.query(
      `SELECT id_comunero FROM comunero WHERE id_comunero = ? AND estado_registro = 'ACTIVO'`,
      [dto.id_comunero],
    );
    if (!comunero) throw new NotFoundException('El comunero seleccionado no existe o fue eliminado');

    const [existente] = await this.dataSource.query(
      `SELECT id_asistencia FROM asistencia_asamblea WHERE id_asamblea = ? AND id_comunero = ? AND estado_registro = 'ACTIVO'`,
      [idAsamblea, dto.id_comunero],
    );
    if (existente) throw new ConflictException('El comunero ya tiene asistencia registrada en esta asamblea');

    const firmo = dto.firmo ? 1 : 0;
    const metodo = dto.metodo || 'MANUAL';
    const observaciones = dto.observaciones?.trim() || null;

    const res = await this.dataSource.query(
      `INSERT INTO asistencia_asamblea (id_asamblea, id_comunero, firmo, metodo, observaciones, id_usuario_crea)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [idAsamblea, dto.id_comunero, firmo, metodo, observaciones, userId],
    );
    const id = Number(res.insertId);
    const nuevo = { id_asamblea: idAsamblea, id_comunero: dto.id_comunero, firmo: !!firmo, metodo, observaciones };
    await this.auditoriaService.registrar('asistencia_asamblea', id, 'CREAR', userId, null, nuevo);
    return { id_asistencia: id, ...nuevo };
  }

  async quitarAsistencia(idAsamblea: number, idAsistencia: number, userId: number) {
    const [antiguo] = await this.dataSource.query(
      `SELECT * FROM asistencia_asamblea WHERE id_asistencia = ? AND id_asamblea = ? AND estado_registro = 'ACTIVO'`,
      [idAsistencia, idAsamblea],
    );
    if (!antiguo) throw new NotFoundException('Registro de asistencia no encontrado');

    const res = await this.dataSource.query(
      `UPDATE asistencia_asamblea SET estado_registro = 'ELIMINADO', id_usuario_mod = ? WHERE id_asistencia = ?`,
      [userId, idAsistencia],
    );
    if (res.affectedRows === 0) throw new NotFoundException('Registro de asistencia no encontrado');

    await this.auditoriaService.registrar('asistencia_asamblea', idAsistencia, 'ELIMINAR', userId, antiguo, null);
    return { mensaje: 'Asistencia eliminada correctamente' };
  }
}
