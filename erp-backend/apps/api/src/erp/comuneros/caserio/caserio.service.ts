import { BadRequestException, ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';
import { AuditoriaService } from '@app/common';
import { CreateCaserioDto, UpdateCaserioDto } from './dto/caserio.dto';

const SELECT_LISTADO = `
  SELECT
    c.id_caserio, c.nombre,
    c.id_comunidad_campesina, cc.nombre AS nombre_comunidad_campesina,
    c.id_caserio_padre, p.nombre AS nombre_caserio_padre
  FROM caserio c
  LEFT JOIN comunidad_campesina cc ON cc.id_comunidad_campesina = c.id_comunidad_campesina AND cc.estado_registro = 'ACTIVO'
  LEFT JOIN caserio p ON p.id_caserio = c.id_caserio_padre AND p.estado_registro = 'ACTIVO'
`;

@Injectable()
export class CaserioService {
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
    let where = `WHERE c.estado_registro = 'ACTIVO'`;
    if (query.search) {
      where += ` AND c.nombre LIKE ?`;
      params.push(`%${String(query.search).trim()}%`);
    }
    if (query.id_comunidad_campesina) {
      where += ` AND c.id_comunidad_campesina = ?`;
      params.push(Number(query.id_comunidad_campesina));
    }

    const sql = `${SELECT_LISTADO} ${where} ORDER BY c.nombre ASC LIMIT ? OFFSET ?`;

    if (isExport) {
      return this.dataSource.query(sql, [...params, limit, offset]);
    }

    const [data, totalRes] = await Promise.all([
      this.dataSource.query(sql, [...params, limit, offset]),
      this.dataSource.query(`SELECT COUNT(*) as total FROM caserio c ${where}`, params),
    ]);

    return { data, meta: { total: Number(totalRes[0]?.total || 0), page, limit } };
  }

  async findOne(id: number) {
    const [row] = await this.dataSource.query(
      `${SELECT_LISTADO} WHERE c.id_caserio = ? AND c.estado_registro = 'ACTIVO'`,
      [id],
    );
    if (!row) throw new NotFoundException('Caserío no encontrado');
    return row;
  }

  private async assertCatalogosActivos(dto: { id_comunidad_campesina?: number; id_caserio_padre?: number }, idCaserioActual?: number) {
    if (dto.id_comunidad_campesina) {
      const [row] = await this.dataSource.query(
        `SELECT id_comunidad_campesina FROM comunidad_campesina WHERE id_comunidad_campesina = ? AND estado_registro = 'ACTIVO'`,
        [dto.id_comunidad_campesina],
      );
      if (!row) throw new NotFoundException('La comunidad campesina seleccionada no existe o fue eliminada');
    }
    if (dto.id_caserio_padre) {
      if (idCaserioActual && dto.id_caserio_padre === idCaserioActual) {
        throw new BadRequestException('Un caserío no puede ser su propio caserío padre');
      }
      const [row] = await this.dataSource.query(
        `SELECT id_caserio FROM caserio WHERE id_caserio = ? AND estado_registro = 'ACTIVO'`,
        [dto.id_caserio_padre],
      );
      if (!row) throw new NotFoundException('El caserío padre seleccionado no existe o fue eliminado');
    }
  }

  async create(dto: CreateCaserioDto, userId: number) {
    await this.assertCatalogosActivos(dto);
    const nombre = dto.nombre.trim().toUpperCase();

    const res = await this.dataSource.query(
      `INSERT INTO caserio (nombre, id_comunidad_campesina, id_caserio_padre, id_usuario_crea) VALUES (?, ?, ?, ?)`,
      [nombre, dto.id_comunidad_campesina ?? null, dto.id_caserio_padre ?? null, userId],
    );
    const id = Number(res.insertId);
    const nuevo = { nombre, id_comunidad_campesina: dto.id_comunidad_campesina ?? null, id_caserio_padre: dto.id_caserio_padre ?? null };
    await this.auditoriaService.registrar('caserio', id, 'CREAR', userId, null, nuevo);
    return { id_caserio: id, ...nuevo };
  }

  async update(id: number, dto: UpdateCaserioDto, userId: number) {
    const antiguo = await this.findOne(id);
    await this.assertCatalogosActivos(dto, id);

    const nombre = dto.nombre ? dto.nombre.trim().toUpperCase() : antiguo.nombre;
    const idComunidadCampesina = dto.id_comunidad_campesina !== undefined ? dto.id_comunidad_campesina : antiguo.id_comunidad_campesina;
    const idCaserioPadre = dto.id_caserio_padre !== undefined ? dto.id_caserio_padre : antiguo.id_caserio_padre;

    const res = await this.dataSource.query(
      `UPDATE caserio SET nombre = ?, id_comunidad_campesina = ?, id_caserio_padre = ?, id_usuario_mod = ?
       WHERE id_caserio = ? AND estado_registro = 'ACTIVO'`,
      [nombre, idComunidadCampesina ?? null, idCaserioPadre ?? null, userId, id],
    );
    if (res.affectedRows === 0) throw new NotFoundException('Caserío no encontrado o ya eliminado');

    const nuevo = { nombre, id_comunidad_campesina: idComunidadCampesina, id_caserio_padre: idCaserioPadre };
    await this.auditoriaService.registrar('caserio', id, 'ACTUALIZAR', userId, antiguo, nuevo);
    return { id_caserio: id, ...nuevo };
  }

  async remove(id: number, userId: number) {
    const antiguo = await this.findOne(id);

    const dependencias = await Promise.all([
      this.dataSource.query(`SELECT COUNT(*) as total FROM caserio WHERE id_caserio_padre = ? AND estado_registro = 'ACTIVO'`, [id]),
      this.dataSource.query(`SELECT COUNT(*) as total FROM comunero_caserio WHERE id_caserio = ? AND estado_registro = 'ACTIVO'`, [id]),
      this.dataSource.query(`SELECT COUNT(*) as total FROM parcela WHERE id_caserio = ? AND estado_registro = 'ACTIVO'`, [id]),
      this.dataSource.query(`SELECT COUNT(*) as total FROM asamblea_caserio WHERE id_caserio = ? AND estado_registro = 'ACTIVO'`, [id]),
    ]);
    if (dependencias.some(([{ total }]) => Number(total) > 0)) {
      throw new ConflictException('No se puede eliminar: el caserío tiene sub-caseríos, comuneros, parcelas o asambleas activas asociadas.');
    }

    const res = await this.dataSource.query(
      `UPDATE caserio SET estado_registro = 'ELIMINADO', id_usuario_mod = ? WHERE id_caserio = ? AND estado_registro = 'ACTIVO'`,
      [userId, id],
    );
    if (res.affectedRows === 0) throw new NotFoundException('Caserío no encontrado o ya eliminado');

    await this.auditoriaService.registrar('caserio', id, 'ELIMINAR', userId, antiguo, null);
    return { mensaje: 'Caserío eliminado correctamente' };
  }
}
