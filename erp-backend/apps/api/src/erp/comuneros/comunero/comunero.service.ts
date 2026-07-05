import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';
import { AuditoriaService } from '@app/common';
import { CreateComuneroDto, UpdateComuneroDto } from './dto/comunero.dto';

const SELECT_COLS = `
  id_comunero, dni, apellidos_nombres, dni_validado_reniec,
  consentimiento_biometrico, fecha_consentimiento_biometrico, fecha_registro
`;

@Injectable()
export class ComuneroService {
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
      where += ` AND (dni LIKE ? OR apellidos_nombres LIKE ?)`;
      const term = `%${String(query.search).trim()}%`;
      params.push(term, term);
    }

    const sql = `SELECT ${SELECT_COLS} FROM comunero ${where} ORDER BY apellidos_nombres ASC LIMIT ? OFFSET ?`;

    if (isExport) {
      return this.dataSource.query(sql, [...params, limit, offset]);
    }

    const [data, totalRes] = await Promise.all([
      this.dataSource.query(sql, [...params, limit, offset]),
      this.dataSource.query(`SELECT COUNT(*) as total FROM comunero ${where}`, params),
    ]);

    return { data, meta: { total: Number(totalRes[0]?.total || 0), page, limit } };
  }

  async findOne(id: number) {
    const [row] = await this.dataSource.query(
      `SELECT ${SELECT_COLS} FROM comunero WHERE id_comunero = ? AND estado_registro = 'ACTIVO'`,
      [id],
    );
    if (!row) throw new NotFoundException('Comunero no encontrado');
    return row;
  }

  async findCaserios(idComunero: number) {
    return this.dataSource.query(
      `SELECT cc.id_comunero_caserio, cc.id_caserio, c.nombre AS nombre_caserio
       FROM comunero_caserio cc
       JOIN caserio c ON c.id_caserio = cc.id_caserio
       WHERE cc.id_comunero = ? AND cc.estado_registro = 'ACTIVO'
       ORDER BY c.nombre ASC`,
      [idComunero],
    );
  }

  async addCaserio(idComunero: number, idCaserio: number, userId: number) {
    await this.findOne(idComunero);
    const [caserio] = await this.dataSource.query(
      `SELECT id_caserio FROM caserio WHERE id_caserio = ? AND estado_registro = 'ACTIVO'`,
      [idCaserio],
    );
    if (!caserio) throw new NotFoundException('El caserío seleccionado no existe o fue eliminado');

    const [existente] = await this.dataSource.query(
      `SELECT id_comunero_caserio FROM comunero_caserio WHERE id_comunero = ? AND id_caserio = ? AND estado_registro = 'ACTIVO'`,
      [idComunero, idCaserio],
    );
    if (existente) throw new ConflictException('El comunero ya está vinculado a ese caserío');

    const res = await this.dataSource.query(
      `INSERT INTO comunero_caserio (id_comunero, id_caserio, id_usuario_crea) VALUES (?, ?, ?)`,
      [idComunero, idCaserio, userId],
    );
    const id = Number(res.insertId);
    await this.auditoriaService.registrar('comunero_caserio', id, 'CREAR', userId, null, {
      id_comunero: idComunero, id_caserio: idCaserio,
    });
    return { id_comunero_caserio: id, id_comunero: idComunero, id_caserio: idCaserio };
  }

  async removeCaserio(idComunero: number, idComuneroCaserio: number, userId: number) {
    const [antiguo] = await this.dataSource.query(
      `SELECT * FROM comunero_caserio WHERE id_comunero_caserio = ? AND id_comunero = ? AND estado_registro = 'ACTIVO'`,
      [idComuneroCaserio, idComunero],
    );
    if (!antiguo) throw new NotFoundException('Vínculo no encontrado');

    const res = await this.dataSource.query(
      `UPDATE comunero_caserio SET estado_registro = 'ELIMINADO', id_usuario_mod = ? WHERE id_comunero_caserio = ?`,
      [userId, idComuneroCaserio],
    );
    if (res.affectedRows === 0) throw new NotFoundException('Vínculo no encontrado');

    await this.auditoriaService.registrar('comunero_caserio', idComuneroCaserio, 'ELIMINAR', userId, antiguo, null);
    return { mensaje: 'Vínculo eliminado correctamente' };
  }

  async create(dto: CreateComuneroDto, userId: number) {
    const dni = dto.dni.trim();
    const apellidosNombres = dto.apellidos_nombres.trim().toUpperCase();
    const consentimiento = dto.consentimiento_biometrico ? 1 : 0;

    const res = await this.dataSource.query(
      `INSERT INTO comunero (dni, apellidos_nombres, consentimiento_biometrico, fecha_consentimiento_biometrico, id_usuario_crea)
       VALUES (?, ?, ?, ${consentimiento ? 'CURDATE()' : 'NULL'}, ?)`,
      [dni, apellidosNombres, consentimiento, userId],
    );
    const id = Number(res.insertId);
    const nuevo = { dni, apellidos_nombres: apellidosNombres, consentimiento_biometrico: !!consentimiento };
    await this.auditoriaService.registrar('comunero', id, 'CREAR', userId, null, nuevo);
    return { id_comunero: id, ...nuevo };
  }

  async update(id: number, dto: UpdateComuneroDto, userId: number) {
    const antiguo = await this.findOne(id);

    const dni = dto.dni ? dto.dni.trim() : antiguo.dni;
    const apellidosNombres = dto.apellidos_nombres ? dto.apellidos_nombres.trim().toUpperCase() : antiguo.apellidos_nombres;
    const consentimientoNuevo = dto.consentimiento_biometrico !== undefined ? (dto.consentimiento_biometrico ? 1 : 0) : antiguo.consentimiento_biometrico;
    const yaConsentido = !!antiguo.consentimiento_biometrico;
    const fechaConsentimientoSql = consentimientoNuevo && !yaConsentido ? 'CURDATE()' : consentimientoNuevo ? 'fecha_consentimiento_biometrico' : 'NULL';

    const res = await this.dataSource.query(
      `UPDATE comunero SET dni = ?, apellidos_nombres = ?, consentimiento_biometrico = ?,
        fecha_consentimiento_biometrico = ${fechaConsentimientoSql}, id_usuario_mod = ?
       WHERE id_comunero = ? AND estado_registro = 'ACTIVO'`,
      [dni, apellidosNombres, consentimientoNuevo, userId, id],
    );
    if (res.affectedRows === 0) throw new NotFoundException('Comunero no encontrado o ya eliminado');

    const nuevo = { dni, apellidos_nombres: apellidosNombres, consentimiento_biometrico: !!consentimientoNuevo };
    await this.auditoriaService.registrar('comunero', id, 'ACTUALIZAR', userId, antiguo, nuevo);
    return { id_comunero: id, ...nuevo };
  }

  async remove(id: number, userId: number) {
    const antiguo = await this.findOne(id);

    const dependencias = await Promise.all([
      this.dataSource.query(`SELECT COUNT(*) as total FROM personal WHERE id_comunero = ? AND estado_registro = 'ACTIVO'`, [id]),
      this.dataSource.query(`SELECT COUNT(*) as total FROM comunero_caserio WHERE id_comunero = ? AND estado_registro = 'ACTIVO'`, [id]),
      this.dataSource.query(`SELECT COUNT(*) as total FROM parcela WHERE id_comunero = ? AND estado_registro = 'ACTIVO'`, [id]),
      this.dataSource.query(`SELECT COUNT(*) as total FROM certificado_posesion WHERE id_comunero = ? AND estado_registro = 'ACTIVO'`, [id]),
    ]);
    if (dependencias.some(([{ total }]) => Number(total) > 0)) {
      throw new ConflictException('No se puede eliminar: el comunero tiene vínculos (trabajador, caserío, parcela o certificado) activos.');
    }

    const res = await this.dataSource.query(
      `UPDATE comunero SET estado_registro = 'ELIMINADO', id_usuario_mod = ? WHERE id_comunero = ? AND estado_registro = 'ACTIVO'`,
      [userId, id],
    );
    if (res.affectedRows === 0) throw new NotFoundException('Comunero no encontrado o ya eliminado');

    await this.auditoriaService.registrar('comunero', id, 'ELIMINAR', userId, antiguo, null);
    return { mensaje: 'Comunero eliminado correctamente' };
  }
}
