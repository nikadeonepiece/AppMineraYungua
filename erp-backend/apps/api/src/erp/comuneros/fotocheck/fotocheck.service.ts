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
    c.id_comunero, c.apellidos_nombres, c.dni,
    COALESCE(NULLIF(TRIM(p.foto), ''), NULLIF(TRIM(c.foto), '')) AS foto,
    cc.numero_padron, cs.nombre AS nombre_caserio, cs.id_caserio
  FROM comunero_caserio cc
  JOIN comunero c ON c.id_comunero = cc.id_comunero AND c.estado_registro = 'ACTIVO'
  JOIN caserio cs ON cs.id_caserio = cc.id_caserio AND cs.estado_registro = 'ACTIVO'
  LEFT JOIN personal p ON p.dni = c.dni AND p.estado_registro = 'ACTIVO'
`;

@Injectable()
export class FotocheckService {
  private logoHtmlCache: string | null = null;

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
    const templatePath = join(process.cwd(), 'templates', 'fotocheck_hoja.html');
    if (!existsSync(templatePath)) {
      throw new NotFoundException('Plantilla de fotocheck no encontrada en el servidor');
    }
    return readFileSync(templatePath, 'utf8');
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
    const { apellidos, nombres } = this.splitNombre(com.apellidos_nombres || '—');
    const apellidosHtml = this.escapeHtml(apellidos);
    const nombresHtml = this.escapeHtml(nombres);
    const dni = this.escapeHtml(com.dni || '—');
    const dniQr = this.normalizeDni(com.dni);
    const fotoHtml = this.buildFotoHtml(com.foto);
    const qrDataUrl = await QRCode.toDataURL(dniQr, {
      width: 400,
      margin: 1,
      errorCorrectionLevel: 'H',
    });

    return `
      <div class="card">
        <div class="card-top">
          <div class="wm-pattern"></div>
          <header class="card-header">
            <div class="brand">
              <span class="brand-line1">Comunidad Campesina</span>
              <span class="brand-line2">Chuyugual</span>
            </div>
            <div class="logo-wrap">${logoHtml}</div>
          </header>
          <div class="foto-wrap">${fotoHtml}</div>
          <div class="identity">
            ${nombresHtml ? `<div class="nombres">${nombresHtml}</div>` : ''}
            ${apellidosHtml ? `<div class="apellidos">${apellidosHtml}</div>` : ''}
          </div>
          <div class="wave-divider"></div>
        </div>
        <div class="card-bottom">
          <div class="guilloche"></div>
          <div class="cargo-wrap">
            <div class="cargo">Miembro Comunal</div>
          </div>
          <div class="footer">
            <div class="footer-left">
              <div class="icon-chakana">${this.buildChakanaSvg(com.id_comunero)}</div>
              <div class="dni-block">
                <div class="icon-id">${this.buildIdCardSvg()}</div>
                <div class="dni-lines">
                  <div class="dni-label">DNI:</div>
                  <div class="dni-num">${dni}</div>
                </div>
              </div>
            </div>
            <div class="qr-wrap"><img class="qr-img" src="${qrDataUrl}" alt="QR" /></div>
          </div>
        </div>
      </div>
    `;
  }

  private splitNombre(full: string): { apellidos: string; nombres: string } {
    const parts = String(full || '—')
      .trim()
      .split(/\s+/)
      .filter(Boolean);

    if (parts.length === 0) return { apellidos: '—', nombres: '' };
    if (parts.length === 1) return { apellidos: '', nombres: parts[0] };
    if (parts.length === 2) return { apellidos: parts[0], nombres: parts[1] };
    if (parts.length === 3) {
      return { apellidos: `${parts[0]} ${parts[1]}`, nombres: parts[2] };
    }

    return {
      apellidos: parts.slice(0, -2).join(' '),
      nombres: parts.slice(-2).join(' '),
    };
  }

  private buildChakanaSvg(id: number | string = '0'): string {
    const gid = `chk${id}`;
    return `<svg viewBox="0 0 48 48" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
      <defs>
        <linearGradient id="${gid}" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" stop-color="#3d7ec8"/>
          <stop offset="100%" stop-color="#b8a04e"/>
        </linearGradient>
      </defs>
      <rect x="20" y="4" width="8" height="12" rx="1" fill="url(#${gid})"/>
      <rect x="20" y="32" width="8" height="12" rx="1" fill="url(#${gid})"/>
      <rect x="4" y="20" width="12" height="8" rx="1" fill="url(#${gid})"/>
      <rect x="32" y="20" width="12" height="8" rx="1" fill="url(#${gid})"/>
      <rect x="14" y="14" width="8" height="8" rx="1" fill="url(#${gid})"/>
      <rect x="26" y="14" width="8" height="8" rx="1" fill="url(#${gid})"/>
      <rect x="14" y="26" width="8" height="8" rx="1" fill="url(#${gid})"/>
      <rect x="26" y="26" width="8" height="8" rx="1" fill="url(#${gid})"/>
      <circle cx="24" cy="24" r="4.5" fill="#fff"/>
    </svg>`;
  }

  private buildIdCardSvg(): string {
    return `<svg viewBox="0 0 40 28" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
      <rect x="1" y="3" width="38" height="22" rx="2" fill="none" stroke="#2b2b2b" stroke-width="2"/>
      <circle cx="12" cy="13" r="4" fill="#2b2b2b"/>
      <path d="M6 22 C6 18 8.5 16 12 16 C15.5 16 18 18 18 22" fill="#2b2b2b"/>
      <rect x="22" y="10" width="14" height="2" rx="1" fill="#b8a04e"/>
      <rect x="22" y="15" width="10" height="2" rx="1" fill="#c8c8c8"/>
    </svg>`;
  }

  private normalizeDni(dni: string | null | undefined): string {
    const digits = String(dni ?? '').replace(/\D/g, '');
    if (!digits) return '00000000';
    if (digits.length > 8) return digits.slice(0, 8);
    return digits.padStart(8, '0');
  }

  private buildLogoHtml(): string {
    if (this.logoHtmlCache) return this.logoHtmlCache;

    const logoPath = join(process.cwd(), 'templates', 'assets', 'logo.png');
    if (existsSync(logoPath)) {
      const base64 = readFileSync(logoPath).toString('base64');
      this.logoHtmlCache = `<img class="seal-logo" src="data:image/png;base64,${base64}" alt="Logo" />`;
      return this.logoHtmlCache;
    }

    this.logoHtmlCache =
      '<div class="seal-fallback">Comunidad<br>Campesina<br>Chuyugual</div>';
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
