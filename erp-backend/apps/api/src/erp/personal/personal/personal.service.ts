import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';
import { AuditoriaService } from '@app/common';
import { CreatePersonalDto, UpdatePersonalDto } from './dto/personal.dto';

const SELECT_LISTADO = `
  SELECT
    p.id_personal, p.dni, p.codigo_personal, p.nombres, p.apellidos,
    p.telefono, p.correo, p.fecha_ingreso,
    p.id_area, a.nombre AS nombre_area,
    p.id_cargo, c.nombre AS nombre_cargo,
    p.id_regimen, r.nombre AS nombre_regimen,
    p.id_comunero, cm.apellidos_nombres AS nombre_comunero,
    p.centro_trabajo, p.consentimiento_biometrico
  FROM personal p
  LEFT JOIN area a ON a.id_area = p.id_area AND a.estado_registro = 'ACTIVO'
  LEFT JOIN cargo c ON c.id_cargo = p.id_cargo AND c.estado_registro = 'ACTIVO'
  LEFT JOIN regimen_laboral r ON r.id_regimen = p.id_regimen AND r.estado_registro = 'ACTIVO'
  LEFT JOIN comunero cm ON cm.id_comunero = p.id_comunero
`;

@Injectable()
export class PersonalService {
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
      where += ` AND (p.dni LIKE ? OR p.codigo_personal LIKE ? OR p.nombres LIKE ? OR p.apellidos LIKE ?)`;
      const term = `%${String(query.search).trim()}%`;
      params.push(term, term, term, term);
    }
    if (query.id_area) {
      where += ` AND p.id_area = ?`;
      params.push(Number(query.id_area));
    }
    if (query.id_cargo) {
      where += ` AND p.id_cargo = ?`;
      params.push(Number(query.id_cargo));
    }

    const sql = `${SELECT_LISTADO} ${where} ORDER BY p.apellidos ASC, p.nombres ASC LIMIT ? OFFSET ?`;

    if (isExport) {
      return this.dataSource.query(sql, [...params, limit, offset]);
    }

    const [data, totalRes] = await Promise.all([
      this.dataSource.query(sql, [...params, limit, offset]),
      this.dataSource.query(`SELECT COUNT(*) as total FROM personal p ${where}`, params),
    ]);

    return { data, meta: { total: Number(totalRes[0]?.total || 0), page, limit } };
  }

  async buscarComuneros(search: string, idPersonalActual?: number, idComuneroActual?: number) {
    const params: any[] = [];
    let where = `WHERE p.estado_registro = 'ACTIVO'`;
    if (search) {
      where += ` AND (p.dni LIKE ? OR p.apellidos_nombres LIKE ?)`;
      const term = `%${String(search).trim()}%`;
      params.push(term, term);
    }
    const excluirVinculados = `AND (pe.id_personal IS NULL OR pe.id_personal = ?)`;
    params.push(idPersonalActual || 0);

    let orderBy = 'ORDER BY p.apellidos_nombres ASC';
    if (idComuneroActual) {
      orderBy = 'ORDER BY CASE WHEN p.id_comunero = ? THEN 0 ELSE 1 END, p.apellidos_nombres ASC';
      params.push(idComuneroActual);
    }

    const sql = `
      SELECT p.id_comunero, p.dni, p.apellidos_nombres
      FROM comunero p
      LEFT JOIN personal pe ON pe.id_comunero = p.id_comunero AND pe.estado_registro = 'ACTIVO'
      ${where} ${excluirVinculados}
      ${orderBy}
      LIMIT 20
    `;
    return this.dataSource.query(sql, params);
  }

  async findOne(id: number) {
    const [row] = await this.dataSource.query(
      `SELECT p.* FROM personal p WHERE p.id_personal = ? AND p.estado_registro = 'ACTIVO'`,
      [id],
    );
    if (!row) throw new NotFoundException('Trabajador no encontrado');
    return row;
  }

  private async assertCatalogosActivos(
    dto: { id_area?: number; id_cargo?: number; id_regimen?: number; id_comunero?: number },
    idPersonalActual?: number,
  ) {
    if (dto.id_area) {
      const [row] = await this.dataSource.query(
        `SELECT id_area FROM area WHERE id_area = ? AND estado_registro = 'ACTIVO'`,
        [dto.id_area],
      );
      if (!row) throw new NotFoundException('El área seleccionada no existe o fue eliminada');
    }
    if (dto.id_cargo) {
      const [row] = await this.dataSource.query(
        `SELECT id_cargo FROM cargo WHERE id_cargo = ? AND estado_registro = 'ACTIVO'`,
        [dto.id_cargo],
      );
      if (!row) throw new NotFoundException('El cargo seleccionado no existe o fue eliminado');
    }
    if (dto.id_regimen) {
      const [row] = await this.dataSource.query(
        `SELECT id_regimen FROM regimen_laboral WHERE id_regimen = ? AND estado_registro = 'ACTIVO'`,
        [dto.id_regimen],
      );
      if (!row) throw new NotFoundException('El régimen laboral seleccionado no existe o fue eliminado');
    }
    if (dto.id_comunero) {
      const [comunero] = await this.dataSource.query(
        `SELECT id_comunero FROM comunero WHERE id_comunero = ? AND estado_registro = 'ACTIVO'`,
        [dto.id_comunero],
      );
      if (!comunero) throw new NotFoundException('El comunero seleccionado no existe o fue eliminado');

      const [vinculado] = await this.dataSource.query(
        `SELECT id_personal FROM personal WHERE id_comunero = ? AND estado_registro = 'ACTIVO' AND id_personal != ?`,
        [dto.id_comunero, idPersonalActual || 0],
      );
      if (vinculado) throw new ConflictException('Ese comunero ya está vinculado a otro trabajador');
    }
  }

  async create(dto: CreatePersonalDto, userId: number) {
    await this.assertCatalogosActivos(dto);

    const nombres = dto.nombres.trim().toUpperCase();
    const apellidos = dto.apellidos.trim().toUpperCase();
    const codigoPersonal = dto.codigo_personal?.trim() || null;
    const consentimiento = dto.consentimiento_biometrico ? 1 : 0;

    const res = await this.dataSource.query(
      `INSERT INTO personal (
        dni, codigo_personal, nombres, apellidos, telefono, correo, fecha_nacimiento, sexo,
        fecha_ingreso, id_area, id_cargo, id_regimen, id_comunero, centro_trabajo, observaciones,
        consentimiento_biometrico, fecha_consentimiento_biometrico, id_usuario_crea
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ${consentimiento ? 'CURDATE()' : 'NULL'}, ?)`,
      [
        dto.dni,
        codigoPersonal,
        nombres,
        apellidos,
        dto.telefono?.trim() || null,
        dto.correo?.trim().toLowerCase() || null,
        dto.fecha_nacimiento || null,
        dto.sexo || null,
        dto.fecha_ingreso || null,
        dto.id_area ?? null,
        dto.id_cargo ?? null,
        dto.id_regimen ?? null,
        dto.id_comunero ?? null,
        dto.centro_trabajo?.trim() || null,
        dto.observaciones?.trim() || null,
        consentimiento,
        userId,
      ],
    );
    const id = Number(res.insertId);
    await this.auditoriaService.registrar('personal', id, 'CREAR', userId, null, { ...dto, nombres, apellidos });
    return this.findOne(id);
  }

  async update(id: number, dto: UpdatePersonalDto, userId: number) {
    const antiguo = await this.findOne(id);
    await this.assertCatalogosActivos(dto, id);

    const nombres = dto.nombres ? dto.nombres.trim().toUpperCase() : antiguo.nombres;
    const apellidos = dto.apellidos ? dto.apellidos.trim().toUpperCase() : antiguo.apellidos;
    const codigoPersonal = dto.codigo_personal !== undefined ? (dto.codigo_personal?.trim() || null) : antiguo.codigo_personal;
    const telefono = dto.telefono !== undefined ? (dto.telefono?.trim() || null) : antiguo.telefono;
    const correo = dto.correo !== undefined ? (dto.correo?.trim().toLowerCase() || null) : antiguo.correo;
    const fechaNacimiento = dto.fecha_nacimiento ?? antiguo.fecha_nacimiento;
    const sexo = dto.sexo ?? antiguo.sexo;
    const fechaIngreso = dto.fecha_ingreso ?? antiguo.fecha_ingreso;
    const idArea = dto.id_area ?? antiguo.id_area;
    const idCargo = dto.id_cargo ?? antiguo.id_cargo;
    const idRegimen = dto.id_regimen ?? antiguo.id_regimen;
    const idComunero = dto.id_comunero !== undefined ? dto.id_comunero : antiguo.id_comunero;
    const centroTrabajo = dto.centro_trabajo !== undefined ? (dto.centro_trabajo?.trim() || null) : antiguo.centro_trabajo;
    const observaciones = dto.observaciones !== undefined ? (dto.observaciones?.trim() || null) : antiguo.observaciones;

    const consentimientoNuevo = dto.consentimiento_biometrico !== undefined ? !!dto.consentimiento_biometrico : !!antiguo.consentimiento_biometrico;
    const yaTeniaFecha = !!antiguo.fecha_consentimiento_biometrico;
    const fechaConsentimientoSql = consentimientoNuevo
      ? (yaTeniaFecha ? '?' : 'CURDATE()')
      : 'NULL';
    const paramsFechaConsentimiento = consentimientoNuevo && yaTeniaFecha ? [antiguo.fecha_consentimiento_biometrico] : [];

    const res = await this.dataSource.query(
      `UPDATE personal SET
        codigo_personal = ?, nombres = ?, apellidos = ?, telefono = ?, correo = ?,
        fecha_nacimiento = ?, sexo = ?, fecha_ingreso = ?, id_area = ?, id_cargo = ?, id_regimen = ?,
        id_comunero = ?, centro_trabajo = ?, observaciones = ?, consentimiento_biometrico = ?,
        fecha_consentimiento_biometrico = ${fechaConsentimientoSql}, id_usuario_mod = ?
      WHERE id_personal = ? AND estado_registro = 'ACTIVO'`,
      [
        codigoPersonal, nombres, apellidos, telefono, correo,
        fechaNacimiento, sexo, fechaIngreso, idArea, idCargo, idRegimen,
        idComunero, centroTrabajo, observaciones, consentimientoNuevo ? 1 : 0,
        ...paramsFechaConsentimiento,
        userId, id,
      ],
    );
    if (res.affectedRows === 0) throw new NotFoundException('Trabajador no encontrado o ya eliminado');

    await this.auditoriaService.registrar('personal', id, 'ACTUALIZAR', userId, antiguo, dto);
    return this.findOne(id);
  }

  async remove(id: number, userId: number) {
    const antiguo = await this.findOne(id);

    const res = await this.dataSource.query(
      `UPDATE personal SET estado_registro = 'ELIMINADO', id_usuario_mod = ? WHERE id_personal = ? AND estado_registro = 'ACTIVO'`,
      [userId, id],
    );
    if (res.affectedRows === 0) throw new NotFoundException('Trabajador no encontrado o ya eliminado');

    await this.auditoriaService.registrar('personal', id, 'ELIMINAR', userId, antiguo, null);
    return { mensaje: 'Trabajador eliminado correctamente' };
  }
}
