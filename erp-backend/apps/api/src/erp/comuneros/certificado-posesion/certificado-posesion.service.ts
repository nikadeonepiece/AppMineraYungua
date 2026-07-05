import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';
import { AuditoriaService } from '@app/common';
import { CreateCertificadoPosesionDto, UpdateCertificadoPosesionDto } from './dto/certificado-posesion.dto';

const SELECT_LISTADO = `
  SELECT
    cert.id_certificado, cert.fecha_emision,
    cert.id_parcela, p.denominacion AS denominacion_parcela,
    cert.id_comunero, c.apellidos_nombres AS nombre_comunero, c.dni
  FROM certificado_posesion cert
  JOIN parcela p ON p.id_parcela = cert.id_parcela
  JOIN comunero c ON c.id_comunero = cert.id_comunero
`;

@Injectable()
export class CertificadoPosesionService {
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
    let where = `WHERE cert.estado_registro = 'ACTIVO'`;
    if (query.search) {
      where += ` AND (c.apellidos_nombres LIKE ? OR c.dni LIKE ? OR p.denominacion LIKE ?)`;
      const term = `%${String(query.search).trim()}%`;
      params.push(term, term, term);
    }
    if (query.id_comunero) {
      where += ` AND cert.id_comunero = ?`;
      params.push(Number(query.id_comunero));
    }

    const sql = `${SELECT_LISTADO} ${where} ORDER BY cert.id_certificado DESC LIMIT ? OFFSET ?`;

    if (isExport) {
      return this.dataSource.query(sql, [...params, limit, offset]);
    }

    const [data, totalRes] = await Promise.all([
      this.dataSource.query(sql, [...params, limit, offset]),
      this.dataSource.query(
        `SELECT COUNT(*) as total FROM certificado_posesion cert
         JOIN parcela p ON p.id_parcela = cert.id_parcela
         JOIN comunero c ON c.id_comunero = cert.id_comunero ${where}`,
        params,
      ),
    ]);

    return { data, meta: { total: Number(totalRes[0]?.total || 0), page, limit } };
  }

  async findOne(id: number) {
    const [row] = await this.dataSource.query(
      `${SELECT_LISTADO} WHERE cert.id_certificado = ? AND cert.estado_registro = 'ACTIVO'`,
      [id],
    );
    if (!row) throw new NotFoundException('Certificado de posesión no encontrado');
    return row;
  }

  private async assertRelacionesActivas(idParcela: number, idComunero: number) {
    const [parcela] = await this.dataSource.query(
      `SELECT id_parcela FROM parcela WHERE id_parcela = ? AND estado_registro = 'ACTIVO'`,
      [idParcela],
    );
    if (!parcela) throw new NotFoundException('La parcela seleccionada no existe o fue eliminada');

    const [comunero] = await this.dataSource.query(
      `SELECT id_comunero FROM comunero WHERE id_comunero = ? AND estado_registro = 'ACTIVO'`,
      [idComunero],
    );
    if (!comunero) throw new NotFoundException('El comunero seleccionado no existe o fue eliminado');
  }

  async create(dto: CreateCertificadoPosesionDto, userId: number) {
    await this.assertRelacionesActivas(dto.id_parcela, dto.id_comunero);
    const fechaEmision = dto.fecha_emision || null;

    const res = await this.dataSource.query(
      `INSERT INTO certificado_posesion (id_parcela, id_comunero, fecha_emision, id_usuario_crea) VALUES (?, ?, ?, ?)`,
      [dto.id_parcela, dto.id_comunero, fechaEmision, userId],
    );
    const id = Number(res.insertId);
    const nuevo = { id_parcela: dto.id_parcela, id_comunero: dto.id_comunero, fecha_emision: fechaEmision };
    await this.auditoriaService.registrar('certificado_posesion', id, 'CREAR', userId, null, nuevo);
    return { id_certificado: id, ...nuevo };
  }

  async update(id: number, dto: UpdateCertificadoPosesionDto, userId: number) {
    const antiguo = await this.findOne(id);

    const idParcela = dto.id_parcela ?? antiguo.id_parcela;
    const idComunero = dto.id_comunero ?? antiguo.id_comunero;
    if (dto.id_parcela || dto.id_comunero) await this.assertRelacionesActivas(idParcela, idComunero);

    const fechaEmision = dto.fecha_emision !== undefined ? dto.fecha_emision : antiguo.fecha_emision;

    const res = await this.dataSource.query(
      `UPDATE certificado_posesion SET id_parcela = ?, id_comunero = ?, fecha_emision = ?, id_usuario_mod = ?
       WHERE id_certificado = ? AND estado_registro = 'ACTIVO'`,
      [idParcela, idComunero, fechaEmision, userId, id],
    );
    if (res.affectedRows === 0) throw new NotFoundException('Certificado de posesión no encontrado o ya eliminado');

    const nuevo = { id_parcela: idParcela, id_comunero: idComunero, fecha_emision: fechaEmision };
    await this.auditoriaService.registrar('certificado_posesion', id, 'ACTUALIZAR', userId, antiguo, nuevo);
    return { id_certificado: id, ...nuevo };
  }

  async remove(id: number, userId: number) {
    const antiguo = await this.findOne(id);

    const res = await this.dataSource.query(
      `UPDATE certificado_posesion SET estado_registro = 'ELIMINADO', id_usuario_mod = ? WHERE id_certificado = ? AND estado_registro = 'ACTIVO'`,
      [userId, id],
    );
    if (res.affectedRows === 0) throw new NotFoundException('Certificado de posesión no encontrado o ya eliminado');

    await this.auditoriaService.registrar('certificado_posesion', id, 'ELIMINAR', userId, antiguo, null);
    return { mensaje: 'Certificado de posesión eliminado correctamente' };
  }
}
