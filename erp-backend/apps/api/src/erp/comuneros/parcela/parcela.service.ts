import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';
import { AuditoriaService } from '@app/common';
import { CreateParcelaDto, UpdateParcelaDto } from './dto/parcela.dto';

const SELECT_LISTADO = `
  SELECT
    p.id_parcela, p.denominacion, p.hectareas,
    p.colindante_este, p.colindante_oeste, p.colindante_norte, p.colindante_sur,
    p.id_comunero, c.apellidos_nombres AS nombre_comunero,
    p.id_caserio, cs.nombre AS nombre_caserio
  FROM parcela p
  JOIN comunero c ON c.id_comunero = p.id_comunero
  JOIN caserio cs ON cs.id_caserio = p.id_caserio
`;

@Injectable()
export class ParcelaService {
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
    let where = `WHERE p.estado_registro = 'ACTIVO'`;
    if (query.search) {
      where += ` AND (p.denominacion LIKE ? OR c.apellidos_nombres LIKE ? OR c.dni LIKE ?)`;
      const term = `%${String(query.search).trim()}%`;
      params.push(term, term, term);
    }
    if (query.id_comunero) {
      where += ` AND p.id_comunero = ?`;
      params.push(Number(query.id_comunero));
    }
    if (query.id_caserio) {
      where += ` AND p.id_caserio = ?`;
      params.push(Number(query.id_caserio));
    }

    const sql = `${SELECT_LISTADO} ${where} ORDER BY p.id_parcela DESC LIMIT ? OFFSET ?`;

    if (isExport) {
      return this.dataSource.query(sql, [...params, limit, offset]);
    }

    const [data, totalRes] = await Promise.all([
      this.dataSource.query(sql, [...params, limit, offset]),
      this.dataSource.query(`SELECT COUNT(*) as total FROM parcela p JOIN comunero c ON c.id_comunero = p.id_comunero ${where}`, params),
    ]);

    return { data, meta: { total: Number(totalRes[0]?.total || 0), page, limit } };
  }

  async findOne(id: number) {
    const [row] = await this.dataSource.query(
      `${SELECT_LISTADO} WHERE p.id_parcela = ? AND p.estado_registro = 'ACTIVO'`,
      [id],
    );
    if (!row) throw new NotFoundException('Parcela no encontrada');
    return row;
  }

  private async assertRelacionesActivas(idComunero: number, idCaserio: number) {
    const [comunero] = await this.dataSource.query(
      `SELECT id_comunero FROM comunero WHERE id_comunero = ? AND estado_registro = 'ACTIVO'`,
      [idComunero],
    );
    if (!comunero) throw new NotFoundException('El comunero seleccionado no existe o fue eliminado');

    const [caserio] = await this.dataSource.query(
      `SELECT id_caserio FROM caserio WHERE id_caserio = ? AND estado_registro = 'ACTIVO'`,
      [idCaserio],
    );
    if (!caserio) throw new NotFoundException('El caserío seleccionado no existe o fue eliminado');
  }

  async create(dto: CreateParcelaDto, userId: number) {
    await this.assertRelacionesActivas(dto.id_comunero, dto.id_caserio);

    const denominacion = dto.denominacion?.trim().toUpperCase() || null;
    const hectareas = dto.hectareas ?? null;
    const este = dto.colindante_este?.trim() || null;
    const oeste = dto.colindante_oeste?.trim() || null;
    const norte = dto.colindante_norte?.trim() || null;
    const sur = dto.colindante_sur?.trim() || null;

    const res = await this.dataSource.query(
      `INSERT INTO parcela (
        id_comunero, id_caserio, denominacion, hectareas,
        colindante_este, colindante_oeste, colindante_norte, colindante_sur, id_usuario_crea
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [dto.id_comunero, dto.id_caserio, denominacion, hectareas, este, oeste, norte, sur, userId],
    );
    const id = Number(res.insertId);
    const nuevo = {
      id_comunero: dto.id_comunero, id_caserio: dto.id_caserio, denominacion, hectareas,
      colindante_este: este, colindante_oeste: oeste, colindante_norte: norte, colindante_sur: sur,
    };
    await this.auditoriaService.registrar('parcela', id, 'CREAR', userId, null, nuevo);
    return { id_parcela: id, ...nuevo };
  }

  async update(id: number, dto: UpdateParcelaDto, userId: number) {
    const antiguo = await this.findOne(id);

    const idComunero = dto.id_comunero ?? antiguo.id_comunero;
    const idCaserio = dto.id_caserio ?? antiguo.id_caserio;
    if (dto.id_comunero || dto.id_caserio) await this.assertRelacionesActivas(idComunero, idCaserio);

    const denominacion = dto.denominacion !== undefined ? (dto.denominacion?.trim().toUpperCase() || null) : antiguo.denominacion;
    const hectareas = dto.hectareas !== undefined ? dto.hectareas : antiguo.hectareas;
    const este = dto.colindante_este !== undefined ? (dto.colindante_este?.trim() || null) : antiguo.colindante_este;
    const oeste = dto.colindante_oeste !== undefined ? (dto.colindante_oeste?.trim() || null) : antiguo.colindante_oeste;
    const norte = dto.colindante_norte !== undefined ? (dto.colindante_norte?.trim() || null) : antiguo.colindante_norte;
    const sur = dto.colindante_sur !== undefined ? (dto.colindante_sur?.trim() || null) : antiguo.colindante_sur;

    const res = await this.dataSource.query(
      `UPDATE parcela SET
        id_comunero = ?, id_caserio = ?, denominacion = ?, hectareas = ?,
        colindante_este = ?, colindante_oeste = ?, colindante_norte = ?, colindante_sur = ?, id_usuario_mod = ?
      WHERE id_parcela = ? AND estado_registro = 'ACTIVO'`,
      [idComunero, idCaserio, denominacion, hectareas, este, oeste, norte, sur, userId, id],
    );
    if (res.affectedRows === 0) throw new NotFoundException('Parcela no encontrada o ya eliminada');

    const nuevo = { id_comunero: idComunero, id_caserio: idCaserio, denominacion, hectareas, colindante_este: este, colindante_oeste: oeste, colindante_norte: norte, colindante_sur: sur };
    await this.auditoriaService.registrar('parcela', id, 'ACTUALIZAR', userId, antiguo, nuevo);
    return { id_parcela: id, ...nuevo };
  }

  async remove(id: number, userId: number) {
    const antiguo = await this.findOne(id);

    const [{ total }] = await this.dataSource.query(
      `SELECT COUNT(*) as total FROM certificado_posesion WHERE id_parcela = ? AND estado_registro = 'ACTIVO'`,
      [id],
    );
    if (Number(total) > 0) {
      throw new ConflictException('No se puede eliminar: la parcela tiene certificados de posesión activos asociados.');
    }

    const res = await this.dataSource.query(
      `UPDATE parcela SET estado_registro = 'ELIMINADO', id_usuario_mod = ? WHERE id_parcela = ? AND estado_registro = 'ACTIVO'`,
      [userId, id],
    );
    if (res.affectedRows === 0) throw new NotFoundException('Parcela no encontrada o ya eliminada');

    await this.auditoriaService.registrar('parcela', id, 'ELIMINAR', userId, antiguo, null);
    return { mensaje: 'Parcela eliminada correctamente' };
  }
}
