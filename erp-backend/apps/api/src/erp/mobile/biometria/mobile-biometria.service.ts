import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
  UnprocessableEntityException,
} from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { ConfigService } from '@nestjs/config';
import { DataSource } from 'typeorm';
import { AuditoriaService, FaceClientService } from '@app/common';

@Injectable()
export class MobileBiometriaService {
  constructor(
    @InjectDataSource('APP_MINERA_YUNGUA_CONN') private readonly dataSource: DataSource,
    private readonly faceClient: FaceClientService,
    private readonly config: ConfigService,
    private readonly auditoriaService: AuditoriaService,
  ) {}

  private get similarityThreshold(): number {
    return Number(this.config.get<string>('BIOMETRIA_SIMILARITY_THRESHOLD') || 0.55);
  }

  private get duplicateWindowSeconds(): number {
    return Number(this.config.get<string>('BIOMETRIA_DUPLICATE_WINDOW_SECONDS') || 300);
  }

  private parsePersonalId(raw: string): number {
    const id = Number(String(raw).trim());
    if (!Number.isInteger(id) || id < 1) {
      throw new BadRequestException('empleado_id inválido');
    }
    return id;
  }

  async getConfig() {
    return {
      similarityThreshold: this.similarityThreshold,
      duplicateWindowSeconds: this.duplicateWindowSeconds,
    };
  }

  async buscar(query: string) {
    const term = `%${String(query || '').trim()}%`;
    if (term === '%%') return [];
    const rows = await this.dataSource.query(
      `SELECT
        p.id_personal AS empleadoId,
        p.dni,
        p.codigo_personal AS codigoEmpleado,
        p.nombres,
        p.apellidos,
        p.consentimiento_biometrico AS consentimientoBiometrico
      FROM personal p
      WHERE p.estado_registro = 'ACTIVO'
        AND (p.dni LIKE ? OR p.codigo_personal LIKE ? OR p.nombres LIKE ? OR p.apellidos LIKE ?)
      ORDER BY p.apellidos ASC, p.nombres ASC
      LIMIT 25`,
      [term, term, term, term],
    );
    return rows.map((row: any) => ({
      ...row,
      empleadoId: String(row.empleadoId),
    }));
  }

  async estado(empleadoId: string) {
    const idPersonal = this.parsePersonalId(empleadoId);
    const [personal] = await this.dataSource.query(
      `SELECT id_personal, consentimiento_biometrico FROM personal WHERE id_personal = ? AND estado_registro = 'ACTIVO'`,
      [idPersonal],
    );
    if (!personal) throw new NotFoundException('Trabajador no encontrado');

    const [bio] = await this.dataSource.query(
      `SELECT id_biometria FROM personal_biometria
       WHERE id_personal = ? AND activo = 1 AND estado_registro = 'ACTIVO'
       ORDER BY fecha_registro DESC LIMIT 1`,
      [idPersonal],
    );

    return {
      empleadoId: String(idPersonal),
      tieneBiometria: Boolean(bio),
      consentimientoBiometrico: personal.consentimiento_biometrico === 1,
    };
  }

  async catalogo() {
    const rows = await this.dataSource.query(
      `SELECT
        p.id_personal,
        p.dni,
        p.codigo_personal,
        p.nombres,
        p.apellidos,
        pb.embedding_facial
      FROM personal_biometria pb
      INNER JOIN personal p ON p.id_personal = pb.id_personal AND p.estado_registro = 'ACTIVO'
      WHERE pb.activo = 1 AND pb.estado_registro = 'ACTIVO'`,
    );

    return rows
      .map((row: any) => {
        const embedding = this.parseEmbedding(row.embedding_facial);
        if (embedding.length < 16) return null;
        return {
          empleadoId: String(row.id_personal),
          dni: row.dni,
          codigoEmpleado: row.codigo_personal,
          nombres: row.nombres,
          apellidos: row.apellidos,
          embedding,
        };
      })
      .filter(Boolean);
  }

  async generateEmbedding(imageBase64: string) {
    return this.faceClient.generateEmbedding(imageBase64);
  }

  async validarParCapturas(imageBase641: string, imageBase642: string) {
    const [a, b] = await Promise.all([
      this.faceClient.generateEmbedding(imageBase641),
      this.faceClient.generateEmbedding(imageBase642),
    ]);
    const compare = await this.faceClient.compareEmbeddings(a.embedding, b.embedding);
    return {
      score: compare.score,
      aceptado: compare.score >= this.similarityThreshold,
      similarityThreshold: this.similarityThreshold,
    };
  }

  async matchFromImage(imageBase64: string) {
    const generated = await this.faceClient.generateEmbedding(imageBase64);
    const catalog = await this.catalogo();
    if (catalog.length === 0) {
      throw new UnprocessableEntityException('Sin plantillas biométricas');
    }

    const scores: Array<{ empleadoId: string; score: number; row: any }> = [];
    for (const entry of catalog) {
      const score = this.cosineSimilarity(generated.embedding, entry.embedding);
      scores.push({ empleadoId: entry.empleadoId, score, row: entry });
    }

    scores.sort((a, b) => b.score - a.score);
    const best = scores[0];
    const second = scores[1];
    if (!best || best.score < this.similarityThreshold) {
      throw new UnprocessableEntityException('Sin coincidencia facial');
    }
    if (second && second.score >= this.similarityThreshold && best.score - second.score < 0.05) {
      throw new UnprocessableEntityException('Coincidencia ambigua');
    }

    return {
      empleadoId: best.empleadoId,
      score: best.score,
      nombres: best.row.nombres,
      apellidos: best.row.apellidos,
      dni: best.row.dni,
      codigoEmpleado: best.row.codigoEmpleado,
    };
  }

  async registrar(
    empleadoId: string,
    imagenesBase64: string[],
    embeddingDevice: number[] | undefined,
    userId: number,
  ) {
    const idPersonal = this.parsePersonalId(empleadoId);
    const [personal] = await this.dataSource.query(
      `SELECT id_personal, consentimiento_biometrico FROM personal WHERE id_personal = ? AND estado_registro = 'ACTIVO'`,
      [idPersonal],
    );
    if (!personal) throw new NotFoundException('Trabajador no encontrado');
    if (!personal.consentimiento_biometrico) {
      throw new ConflictException('El trabajador no tiene consentimiento biométrico');
    }
    if (!imagenesBase64?.length) {
      throw new BadRequestException('Debe enviar al menos una imagen');
    }

    const captures = await Promise.all(
      imagenesBase64.map((image) => this.faceClient.enrollmentCapture(image)),
    );
    const embedding = captures[captures.length - 1].embedding;

    const queryRunner = this.dataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();
    try {
      await queryRunner.query(
        `UPDATE personal_biometria SET activo = 0, id_usuario_mod = ? WHERE id_personal = ? AND activo = 1`,
        [userId, idPersonal],
      );
      const res = await queryRunner.query(
        `INSERT INTO personal_biometria (id_personal, embedding_facial, activo, id_usuario_crea)
         VALUES (?, ?, 1, ?)`,
        [idPersonal, JSON.stringify(embedding), userId],
      );
      const idBiometria = Number(res.insertId);
      await this.auditoriaService.registrarConTransaccion(
        queryRunner,
        'personal_biometria',
        idBiometria,
        'CREAR',
        userId,
        null,
        { id_personal: idPersonal, embedding_device: embeddingDevice?.length || 0 },
      );
      await queryRunner.commitTransaction();
      return {
        mensaje: 'Biometría registrada correctamente',
        id_biometria: idBiometria,
        empleadoId: String(idPersonal),
      };
    } catch (error) {
      await queryRunner.rollbackTransaction();
      throw error;
    } finally {
      await queryRunner.release();
    }
  }

  private cosineSimilarity(a: number[], b: number[]): number {
    const len = Math.min(a.length, b.length);
    if (len === 0) return 0;
    let dot = 0;
    let na = 0;
    let nb = 0;
    for (let i = 0; i < len; i++) {
      dot += a[i] * b[i];
      na += a[i] * a[i];
      nb += b[i] * b[i];
    }
    const denom = Math.sqrt(na) * Math.sqrt(nb);
    return denom === 0 ? 0 : dot / denom;
  }

  private parseEmbedding(raw: unknown): number[] {
    if (Array.isArray(raw)) {
      return raw.map((v) => Number(v)).filter((v) => Number.isFinite(v));
    }
    if (typeof raw === 'string') {
      try {
        const parsed = JSON.parse(raw);
        if (Array.isArray(parsed)) {
          return parsed.map((v) => Number(v)).filter((v) => Number.isFinite(v));
        }
      } catch {
        return [];
      }
    }
    return [];
  }
}
