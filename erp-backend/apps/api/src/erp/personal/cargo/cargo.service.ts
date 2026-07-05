import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';
import { AuditoriaService } from '@app/common';
import { CreateCargoDto, UpdateCargoDto } from './dto/cargo.dto';

@Injectable()
export class CargoService {
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
    if (query.id_area) {
      where += ` AND c.id_area = ?`;
      params.push(Number(query.id_area));
    }

    const sql = `
      SELECT c.id_cargo, c.id_area, a.nombre AS nombre_area, c.nombre, c.requiere_brevete
      FROM cargo c
      INNER JOIN area a ON a.id_area = c.id_area
      ${where}
      ORDER BY c.nombre ASC
      LIMIT ? OFFSET ?
    `;

    if (isExport) {
      return this.dataSource.query(sql, [...params, limit, offset]);
    }

    const [data, totalRes] = await Promise.all([
      this.dataSource.query(sql, [...params, limit, offset]),
      this.dataSource.query(
        `SELECT COUNT(*) as total FROM cargo c ${where}`,
        params,
      ),
    ]);

    return { data, meta: { total: Number(totalRes[0]?.total || 0), page, limit } };
  }

  async findOne(id: number) {
    const [row] = await this.dataSource.query(
      `SELECT id_cargo, id_area, nombre, requiere_brevete FROM cargo WHERE id_cargo = ? AND estado_registro = 'ACTIVO'`,
      [id],
    );
    if (!row) throw new NotFoundException('Cargo no encontrado');
    return row;
  }

  private async assertAreaActiva(idArea: number) {
    const [area] = await this.dataSource.query(
      `SELECT id_area FROM area WHERE id_area = ? AND estado_registro = 'ACTIVO'`,
      [idArea],
    );
    if (!area) throw new NotFoundException('El área seleccionada no existe o fue eliminada');
  }

  async create(dto: CreateCargoDto, userId: number) {
    await this.assertAreaActiva(dto.id_area);
    const nombre = dto.nombre.trim().toUpperCase();
    const requiereBrevete = dto.requiere_brevete ? 1 : 0;

    const res = await this.dataSource.query(
      `INSERT INTO cargo (id_area, nombre, requiere_brevete, id_usuario_crea) VALUES (?, ?, ?, ?)`,
      [dto.id_area, nombre, requiereBrevete, userId],
    );
    const id = Number(res.insertId);
    await this.auditoriaService.registrar('cargo', id, 'CREAR', userId, null, { ...dto, nombre });
    return { id_cargo: id, id_area: dto.id_area, nombre, requiere_brevete: !!requiereBrevete };
  }

  async update(id: number, dto: UpdateCargoDto, userId: number) {
    const antiguo = await this.findOne(id);
    if (dto.id_area) await this.assertAreaActiva(dto.id_area);

    const idArea = dto.id_area ?? antiguo.id_area;
    const nombre = dto.nombre ? dto.nombre.trim().toUpperCase() : antiguo.nombre;
    const requiereBrevete = dto.requiere_brevete !== undefined ? (dto.requiere_brevete ? 1 : 0) : antiguo.requiere_brevete;

    const res = await this.dataSource.query(
      `UPDATE cargo SET id_area = ?, nombre = ?, requiere_brevete = ?, id_usuario_mod = ? WHERE id_cargo = ? AND estado_registro = 'ACTIVO'`,
      [idArea, nombre, requiereBrevete, userId, id],
    );
    if (res.affectedRows === 0) throw new NotFoundException('Cargo no encontrado o ya eliminado');

    await this.auditoriaService.registrar('cargo', id, 'ACTUALIZAR', userId, antiguo, { idArea, nombre, requiereBrevete });
    return { id_cargo: id, id_area: idArea, nombre, requiere_brevete: !!requiereBrevete };
  }

  async remove(id: number, userId: number) {
    const antiguo = await this.findOne(id);

    const [{ total }] = await this.dataSource.query(
      `SELECT COUNT(*) as total FROM personal WHERE id_cargo = ? AND estado_registro = 'ACTIVO'`,
      [id],
    );
    if (Number(total) > 0) {
      throw new ConflictException('No se puede eliminar: el cargo tiene personal activo asignado.');
    }

    const res = await this.dataSource.query(
      `UPDATE cargo SET estado_registro = 'ELIMINADO', id_usuario_mod = ? WHERE id_cargo = ? AND estado_registro = 'ACTIVO'`,
      [userId, id],
    );
    if (res.affectedRows === 0) throw new NotFoundException('Cargo no encontrado o ya eliminado');

    await this.auditoriaService.registrar('cargo', id, 'ELIMINAR', userId, antiguo, null);
    return { mensaje: 'Cargo eliminado correctamente' };
  }
}
