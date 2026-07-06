import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';
import type { Response } from 'express';
import { existsSync, readFileSync } from 'fs';
import { join } from 'path';
import { AuditoriaService, PdfService } from '@app/common';
import { CreateCertificadoPosesionDto, UpdateCertificadoPosesionDto } from './dto/certificado-posesion.dto';

const PARTIDA_FIJA = '03002622';
const MESES_ES = [
  'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
  'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
];

const SELECT_PARCELA_CERTIFICADO = `
  SELECT
    p.id_parcela, p.denominacion, p.sector, p.hectareas,
    p.colindante_este, p.colindante_oeste, p.colindante_norte, p.colindante_sur,
    c.id_comunero, c.apellidos_nombres, c.dni,
    cs.nombre AS nombre_caserio, cs.id_caserio_padre,
    padre.nombre AS nombre_caserio_padre
  FROM parcela p
  JOIN comunero c ON c.id_comunero = p.id_comunero
  JOIN caserio cs ON cs.id_caserio = p.id_caserio AND cs.estado_registro = 'ACTIVO'
  LEFT JOIN caserio padre ON padre.id_caserio = cs.id_caserio_padre AND padre.estado_registro = 'ACTIVO'
`;

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
    private readonly pdfService: PdfService,
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

  async exportarPdf(query: any, res: Response) {
    const idComunero = Number(query.id_comunero);
    const idParcela = Number(query.id_parcela);
    if (!idComunero || isNaN(idComunero)) throw new BadRequestException('id_comunero inválido');
    if (!idParcela || isNaN(idParcela)) throw new BadRequestException('id_parcela inválido');

    const [row] = await this.dataSource.query(
      `${SELECT_PARCELA_CERTIFICADO}
       WHERE p.id_parcela = ? AND p.id_comunero = ? AND p.estado_registro = 'ACTIVO'
         AND c.estado_registro = 'ACTIVO'`,
      [idParcela, idComunero],
    );
    if (!row) {
      throw new NotFoundException('No se encontró la parcela del comunero seleccionado');
    }

    const fechaRef = query.fecha_emision ? new Date(String(query.fecha_emision)) : new Date();
    if (isNaN(fechaRef.getTime())) throw new BadRequestException('fecha_emision inválida');

    const caserio = row.id_caserio_padre ? (row.nombre_caserio_padre || '—') : (row.nombre_caserio || '—');
    const sector = row.sector?.trim()
      || (row.id_caserio_padre ? (row.nombre_caserio || '—') : '—');

    const html = this.buildCertificadoHtml({
      nombre: row.apellidos_nombres || '—',
      dni: row.dni || '—',
      parcela: row.denominacion || '—',
      hectareas: row.hectareas != null ? String(row.hectareas) : '—',
      caserio,
      sector,
      colEste: row.colindante_este || '—',
      colOeste: row.colindante_oeste || '—',
      colNorte: row.colindante_norte || '—',
      colSur: row.colindante_sur || '—',
      dia: String(fechaRef.getDate()),
      mes: MESES_ES[fechaRef.getMonth()] || '—',
      anio: String(fechaRef.getFullYear()),
    });

    const nombreArchivo = `Certificado_Posesion_${String(row.dni || idComunero).replace(/[^a-zA-Z0-9_\-.]/g, '_')}`;
    await this.pdfService.generarPdf(html, nombreArchivo, res);
  }

  private buildCertificadoHtml(data: {
    nombre: string; dni: string; parcela: string; hectareas: string;
    caserio: string; sector: string;
    colEste: string; colOeste: string; colNorte: string; colSur: string;
    dia: string; mes: string; anio: string;
  }): string {
    const templatePath = join(process.cwd(), 'templates', 'certificado_de_posesion.html');
    if (!existsSync(templatePath)) {
      throw new NotFoundException('Plantilla de certificado no encontrada en el servidor');
    }

    let html = readFileSync(templatePath, 'utf8');
    const logoHtml = this.buildLogoHtml();

    const replacements: Record<string, string> = {
      '{{LOGO_HTML}}': logoHtml,
      '{{PARTIDA}}': PARTIDA_FIJA,
      '{{NOMBRE}}': this.escapeHtml(data.nombre),
      '{{DNI}}': this.escapeHtml(data.dni),
      '{{PARCELA}}': this.escapeHtml(data.parcela),
      '{{HECTAREAS}}': this.escapeHtml(data.hectareas),
      '{{CASERIO}}': this.escapeHtml(data.caserio),
      '{{SECTOR}}': this.escapeHtml(data.sector),
      '{{COL_ESTE}}': this.escapeHtml(data.colEste),
      '{{COL_OESTE}}': this.escapeHtml(data.colOeste),
      '{{COL_NORTE}}': this.escapeHtml(data.colNorte),
      '{{COL_SUR}}': this.escapeHtml(data.colSur),
      '{{DIA}}': this.escapeHtml(data.dia),
      '{{MES}}': this.escapeHtml(data.mes),
      '{{ANIO}}': this.escapeHtml(data.anio),
    };

    for (const [token, value] of Object.entries(replacements)) {
      html = html.split(token).join(value);
    }
    return html;
  }

  private buildLogoHtml(): string {
    const logoPath = join(process.cwd(), 'templates', 'assets', 'logo.png');
    if (existsSync(logoPath)) {
      const base64 = readFileSync(logoPath).toString('base64');
      return `<img class="logo" src="data:image/png;base64,${base64}" alt="Logo Comunidad Campesina Chuyugual" />`;
    }
    return '<div class="logo-fallback">COMUNIDAD<br>CAMPESINA<br>CHUYUGUAL</div>';
  }

  private escapeHtml(value: string): string {
    return String(value)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#39;');
  }
}
