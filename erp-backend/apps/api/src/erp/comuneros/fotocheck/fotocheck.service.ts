import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';
import type { Response } from 'express';
import { existsSync, readFileSync } from 'fs';
import { join } from 'path';
import * as QRCode from 'qrcode';
import { PdfService } from '@app/common';

const SELECT_COMUNERO_CASERIO = `
  SELECT
    c.id_comunero, c.apellidos_nombres, c.dni, c.foto,
    cc.numero_padron, cs.nombre AS nombre_caserio, cs.id_caserio
  FROM comunero_caserio cc
  JOIN comunero c ON c.id_comunero = cc.id_comunero AND c.estado_registro = 'ACTIVO'
  JOIN caserio cs ON cs.id_caserio = cc.id_caserio AND cs.estado_registro = 'ACTIVO'
`;

@Injectable()
export class FotocheckService {
  private logoHtmlCache: string | null = null;
  private templateCache: string | null = null;

  constructor(
    @InjectDataSource('APP_MINERA_YUNGUA_CONN') private dataSource: DataSource,
    private readonly pdfService: PdfService,
  ) {}

  async findComunerosByCaserio(query: any) {
    const idCaserio = Number(query.id_caserio);
    if (!idCaserio || isNaN(idCaserio)) throw new BadRequestException('id_caserio inválido');

    const page = Number(query.page) || 1;
    const limit = Number(query.limit) || 20;
    const offset = (page - 1) * limit;

    const params: any[] = [idCaserio];
    let where = `WHERE cc.id_caserio = ? AND cc.estado_registro = 'ACTIVO'`;

    if (query.search) {
      where += ` AND (c.apellidos_nombres LIKE ? OR c.dni LIKE ?)`;
      const term = `%${String(query.search).trim()}%`;
      params.push(term, term);
    }

    const sql = `${SELECT_COMUNERO_CASERIO} ${where} ORDER BY c.apellidos_nombres ASC LIMIT ? OFFSET ?`;

    const [data, totalRes] = await Promise.all([
      this.dataSource.query(sql, [...params, limit, offset]),
      this.dataSource.query(
        `SELECT COUNT(*) as total FROM comunero_caserio cc
         JOIN comunero c ON c.id_comunero = cc.id_comunero AND c.estado_registro = 'ACTIVO'
         ${where}`,
        params,
      ),
    ]);

    return { data, meta: { total: Number(totalRes[0]?.total || 0), page, limit } };
  }

  async exportarPdf(query: any, res: Response) {
    const idCaserio = Number(query.id_caserio);
    if (!idCaserio || isNaN(idCaserio)) throw new BadRequestException('id_caserio inválido');

    const [caserio] = await this.dataSource.query(
      `SELECT id_caserio, nombre FROM caserio WHERE id_caserio = ? AND estado_registro = 'ACTIVO'`,
      [idCaserio],
    );
    if (!caserio) throw new NotFoundException('Caserío no encontrado');

    let comuneros: any[];
    const esSeleccion = Boolean(query.ids);

    if (esSeleccion) {
      const ids = String(query.ids)
        .split(',')
        .map((v) => Number(v.trim()))
        .filter((v) => v && !isNaN(v));

      if (ids.length === 0) throw new BadRequestException('Debe seleccionar al menos un comunero');
      if (ids.length > 9) throw new BadRequestException('Máximo 9 comuneros por hoja de fotocheck');

      const placeholders = ids.map(() => '?').join(', ');
      comuneros = await this.dataSource.query(
        `${SELECT_COMUNERO_CASERIO}
         WHERE cc.id_caserio = ? AND cc.estado_registro = 'ACTIVO' AND c.id_comunero IN (${placeholders})
         ORDER BY FIELD(c.id_comunero, ${placeholders})`,
        [idCaserio, ...ids, ...ids],
      );

      if (comuneros.length !== ids.length) {
        throw new BadRequestException('Uno o más comuneros no pertenecen al caserío seleccionado');
      }
    } else {
      comuneros = await this.dataSource.query(
        `${SELECT_COMUNERO_CASERIO}
         WHERE cc.id_caserio = ? AND cc.estado_registro = 'ACTIVO'
         ORDER BY c.apellidos_nombres ASC`,
        [idCaserio],
      );
      if (comuneros.length === 0) {
        throw new NotFoundException('No hay comuneros registrados en este caserío');
      }
    }

    const hojasHtml = await this.buildHojasHtml(comuneros, caserio.nombre, !esSeleccion);
    const slug = String(caserio.nombre || idCaserio).replace(/[^a-zA-Z0-9_\-.]/g, '_');
    const nombreArchivo = esSeleccion
      ? `Fotocheck_${slug}_seleccion`
      : `Fotocheck_${slug}_completo`;

    await this.pdfService.generarPdfPorHojas(hojasHtml, nombreArchivo, res, {
      sinMargenPagina: true,
    });
  }

  private getTemplate(): string {
    if (this.templateCache) return this.templateCache;
    const templatePath = join(process.cwd(), 'templates', 'fotocheck_hoja.html');
    if (!existsSync(templatePath)) {
      throw new NotFoundException('Plantilla de fotocheck no encontrada en el servidor');
    }
    this.templateCache = readFileSync(templatePath, 'utf8');
    return this.templateCache;
  }

  private async buildHojasHtml(
    comuneros: any[],
    nombreCaserio: string,
    esCaserioCompleto: boolean,
  ): Promise<string[]> {
    const logoHtml = this.buildLogoHtml();
    const template = this.getTemplate();
    const hojas: string[] = [];
    const totalPages = Math.ceil(comuneros.length / 9);

    for (let i = 0; i < comuneros.length; i += 9) {
      const chunk = comuneros.slice(i, i + 9);
      const slots = await Promise.all(
        Array.from({ length: 9 }, async (_, pos) => {
          const com = chunk[pos];
          return com ? await this.buildCardHtml(com, logoHtml) : '<div class="card-empty"></div>';
        }),
      );

      const pageNum = Math.floor(i / 9) + 1;
      const titleHtml = esCaserioCompleto
        ? ''
        : `<div class="page-title">COMUNIDAD CAMPESINA CHUYUGUAL — ${this.escapeHtml(nombreCaserio)} — Hoja ${pageNum} de ${totalPages}</div>`;

      const pageBody = `
        <div class="sheet">
          ${titleHtml}
          <div class="grid">
            ${slots.join('\n')}
          </div>
        </div>
      `;

      hojas.push(template.replace('{{PAGES}}', pageBody));
    }

    return hojas;
  }

  private async buildCardHtml(com: any, logoHtml: string): Promise<string> {
    const nombre = this.escapeHtml(com.apellidos_nombres || '—');
    const dni = this.escapeHtml(com.dni || '—');
    const codigo = this.buildCodigo(com);
    const codigoHtml = this.escapeHtml(codigo);
    const fotoHtml = this.buildFotoHtml(com.foto);
    const qrDataUrl = await QRCode.toDataURL(codigo, {
      width: 160,
      margin: 0,
      errorCorrectionLevel: 'M',
    });

    return `
      <div class="card">
        <div class="card-deco card-deco-tl"></div>
        <div class="card-deco card-deco-b"></div>
        <div class="card-slot"></div>
        <div class="card-logo-wrap">${logoHtml}</div>
        <div class="foto-wrap">${fotoHtml}</div>
        <div class="nombre">${nombre}</div>
        <div class="sep"></div>
        <div class="cargo">Miembro Comunal</div>
        <div class="qr-wrap"><img class="qr-img" src="${qrDataUrl}" alt="QR" /></div>
        <div class="dni">DNI: ${dni}</div>
        <div class="codigo-bar">CÓDIGO: ${codigoHtml}</div>
      </div>
    `;
  }

  private buildCodigo(com: any): string {
    const year = new Date().getFullYear();
    const num = com.numero_padron ?? com.id_comunero;
    return `CCCH-${year}-${String(num).padStart(5, '0')}`;
  }

  private buildLogoHtml(): string {
    if (this.logoHtmlCache) return this.logoHtmlCache;

    const logoPath = join(process.cwd(), 'templates', 'assets', 'logo.png');
    if (existsSync(logoPath)) {
      const base64 = readFileSync(logoPath).toString('base64');
      this.logoHtmlCache = `<img class="card-logo" src="data:image/png;base64,${base64}" alt="Logo" />`;
      return this.logoHtmlCache;
    }

    this.logoHtmlCache = '<div class="card-logo-fallback">COMUNIDAD<br>CAMPESINA<br>CHUYUGUAL</div>';
    return this.logoHtmlCache;
  }

  private resolveFotoPath(foto: string | null): string | null {
    if (!foto?.trim()) return null;
    const relative = foto.replace(/^\/+/, '');
    const candidates = [
      join(process.cwd(), relative),
      join(process.cwd(), 'uploads', relative.replace(/^uploads[\\/]/, '')),
    ];
    for (const path of candidates) {
      if (existsSync(path)) return path;
    }
    return null;
  }

  private buildFotoHtml(foto: string | null): string {
    const path = this.resolveFotoPath(foto);
    if (!path) return '<div class="foto-placeholder">Sin foto</div>';

    const ext = path.toLowerCase().endsWith('.png') ? 'png' : 'jpeg';
    const base64 = readFileSync(path).toString('base64');
    return `<img src="data:image/${ext};base64,${base64}" alt="Foto" />`;
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
