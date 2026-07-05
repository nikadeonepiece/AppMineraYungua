import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';
import { AuditoriaService } from '@app/common';
import { CreateRegimenLaboralDto, UpdateRegimenLaboralDto } from './dto/regimen-laboral.dto';

@Injectable()
export class RegimenLaboralService {
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

    const sql = `SELECT id_regimen, nombre, dias_trabajo, dias_descanso FROM regimen_laboral ${where} ORDER BY nombre ASC LIMIT ? OFFSET ?`;

    if (isExport) {
      return this.dataSource.query(sql, [...params, limit, offset]);
    }

    const [data, totalRes] = await Promise.all([
      this.dataSource.query(sql, [...params, limit, offset]),
      this.dataSource.query(`SELECT COUNT(*) as total FROM regimen_laboral ${where}`, params),
    ]);

    return { data, meta: { total: Number(totalRes[0]?.total || 0), page, limit } };
  }

  async findOne(id: number) {
    const [row] = await this.dataSource.query(
      `SELECT id_regimen, nombre, dias_trabajo, dias_descanso FROM regimen_laboral WHERE id_regimen = ? AND estado_registro = 'ACTIVO'`,
      [id],
    );
    if (!row) throw new NotFoundException('Régimen laboral no encontrado');
    return row;
  }

  async create(dto: CreateRegimenLaboralDto, userId: number) {
    const nombre = dto.nombre.trim().toUpperCase();
    const res = await this.dataSource.query(
      `INSERT INTO regimen_laboral (nombre, dias_trabajo, dias_descanso, id_usuario_crea) VALUES (?, ?, ?, ?)`,
      [nombre, dto.dias_trabajo ?? null, dto.dias_descanso ?? null, userId],
    );
    const id = Number(res.insertId);
    await this.auditoriaService.registrar('regimen_laboral', id, 'CREAR', userId, null, { ...dto, nombre });
    return { id_regimen: id, nombre, dias_trabajo: dto.dias_trabajo ?? null, dias_descanso: dto.dias_descanso ?? null };
  }

  async update(id: number, dto: UpdateRegimenLaboralDto, userId: number) {
    const antiguo = await this.findOne(id);
    const nombre = dto.nombre ? dto.nombre.trim().toUpperCase() : antiguo.nombre;
    const diasTrabajo = dto.dias_trabajo ?? antiguo.dias_trabajo;
    const diasDescanso = dto.dias_descanso ?? antiguo.dias_descanso;

    const res = await this.dataSource.query(
      `UPDATE regimen_laboral SET nombre = ?, dias_trabajo = ?, dias_descanso = ?, id_usuario_mod = ? WHERE id_regimen = ? AND estado_registro = 'ACTIVO'`,
      [nombre, diasTrabajo, diasDescanso, userId, id],
    );
    if (res.affectedRows === 0) throw new NotFoundException('Régimen laboral no encontrado o ya eliminado');

    await this.auditoriaService.registrar('regimen_laboral', id, 'ACTUALIZAR', userId, antiguo, { nombre, diasTrabajo, diasDescanso });
    return { id_regimen: id, nombre, dias_trabajo: diasTrabajo, dias_descanso: diasDescanso };
  }

  async remove(id: number, userId: number) {
    const antiguo = await this.findOne(id);

    const [{ total }] = await this.dataSource.query(
      `SELECT COUNT(*) as total FROM personal WHERE id_regimen = ? AND estado_registro = 'ACTIVO'`,
      [id],
    );
    if (Number(total) > 0) {
      throw new ConflictException('No se puede eliminar: el régimen tiene personal activo asignado.');
    }

    const res = await this.dataSource.query(
      `UPDATE regimen_laboral SET estado_registro = 'ELIMINADO', id_usuario_mod = ? WHERE id_regimen = ? AND estado_registro = 'ACTIVO'`,
      [userId, id],
    );
    if (res.affectedRows === 0) throw new NotFoundException('Régimen laboral no encontrado o ya eliminado');

    await this.auditoriaService.registrar('regimen_laboral', id, 'ELIMINAR', userId, antiguo, null);
    return { mensaje: 'Régimen laboral eliminado correctamente' };
  }
}
