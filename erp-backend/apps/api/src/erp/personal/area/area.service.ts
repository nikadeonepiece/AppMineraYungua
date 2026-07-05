import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';
import { AuditoriaService } from '@app/common';
import { CreateAreaDto, UpdateAreaDto } from './dto/area.dto';

@Injectable()
export class AreaService {
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
      where += ` AND nombre LIKE ?`;
      params.push(`%${String(query.search).trim()}%`);
    }

    const sql = `SELECT id_area, nombre FROM area ${where} ORDER BY nombre ASC LIMIT ? OFFSET ?`;

    if (isExport) {
      return this.dataSource.query(sql, [...params, limit, offset]);
    }

    const [data, totalRes] = await Promise.all([
      this.dataSource.query(sql, [...params, limit, offset]),
      this.dataSource.query(`SELECT COUNT(*) as total FROM area ${where}`, params),
    ]);

    return { data, meta: { total: Number(totalRes[0]?.total || 0), page, limit } };
  }

  async findOne(id: number) {
    const [row] = await this.dataSource.query(
      `SELECT id_area, nombre FROM area WHERE id_area = ? AND estado_registro = 'ACTIVO'`,
      [id],
    );
    if (!row) throw new NotFoundException('Área no encontrada');
    return row;
  }

  async create(dto: CreateAreaDto, userId: number) {
    const nombre = dto.nombre.trim().toUpperCase();
    const res = await this.dataSource.query(
      `INSERT INTO area (nombre, id_usuario_crea) VALUES (?, ?)`,
      [nombre, userId],
    );
    const id = Number(res.insertId);
    await this.auditoriaService.registrar('area', id, 'CREAR', userId, null, { nombre });
    return { id_area: id, nombre };
  }

  async update(id: number, dto: UpdateAreaDto, userId: number) {
    const antiguo = await this.findOne(id);
    const nombre = dto.nombre ? dto.nombre.trim().toUpperCase() : antiguo.nombre;

    const res = await this.dataSource.query(
      `UPDATE area SET nombre = ?, id_usuario_mod = ? WHERE id_area = ? AND estado_registro = 'ACTIVO'`,
      [nombre, userId, id],
    );
    if (res.affectedRows === 0) throw new NotFoundException('Área no encontrada o ya eliminada');

    await this.auditoriaService.registrar('area', id, 'ACTUALIZAR', userId, antiguo, { nombre });
    return { id_area: id, nombre };
  }

  async remove(id: number, userId: number) {
    const antiguo = await this.findOne(id);

    const [{ total }] = await this.dataSource.query(
      `SELECT COUNT(*) as total FROM cargo WHERE id_area = ? AND estado_registro = 'ACTIVO'`,
      [id],
    );
    if (Number(total) > 0) {
      throw new ConflictException('No se puede eliminar: el área tiene cargos activos asociados.');
    }

    const res = await this.dataSource.query(
      `UPDATE area SET estado_registro = 'ELIMINADO', id_usuario_mod = ? WHERE id_area = ? AND estado_registro = 'ACTIVO'`,
      [userId, id],
    );
    if (res.affectedRows === 0) throw new NotFoundException('Área no encontrada o ya eliminada');

    await this.auditoriaService.registrar('area', id, 'ELIMINAR', userId, antiguo, null);
    return { mensaje: 'Área eliminada correctamente' };
  }
}
