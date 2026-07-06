import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';
import { MarcacionAsistenciaService } from '../../marcacion-asistencia/marcacion-asistencia.service';
import { ReplaySignatureService } from '../common/replay-signature.service';

@Injectable()
export class MobileMarcacionService {
  constructor(
    @InjectDataSource('APP_MINERA_YUNGUA_CONN') private readonly dataSource: DataSource,
    private readonly marcacionService: MarcacionAsistenciaService,
    private readonly replaySignature: ReplaySignatureService,
  ) {}

  private mapMetodo(raw: string): 'FACIAL' | 'QR' | 'MANUAL' {
    const value = String(raw || '').trim().toLowerCase();
    if (value === 'qr') return 'QR';
    if (value === 'dni' || value === 'manual') return 'MANUAL';
    return 'FACIAL';
  }

  private async resolvePersonalId(empleadoId: string): Promise<number> {
    const text = String(empleadoId || '').trim();
    const asNum = Number(text);
    if (Number.isInteger(asNum) && asNum > 0) return asNum;

    const [row] = await this.dataSource.query(
      `SELECT id_personal FROM personal WHERE estado_registro = 'ACTIVO' AND (dni = ? OR codigo_personal = ?) LIMIT 1`,
      [text, text],
    );
    if (!row) throw new NotFoundException('Trabajador no encontrado');
    return Number(row.id_personal);
  }

  private async resolveDispositivoId(deviceRef?: string | null): Promise<number | undefined> {
    const deviceId = String(deviceRef || '').trim();
    if (!deviceId) return undefined;
    const [row] = await this.dataSource.query(
      `SELECT id_dispositivo FROM dispositivo_movil
       WHERE device_id = ? AND activo = 1 AND revocado = 0 AND estado_registro = 'ACTIVO'`,
      [deviceId],
    );
    if (!row) throw new ConflictException('Dispositivo no autorizado o revocado');
    return Number(row.id_dispositivo);
  }

  async marcarOnline(
    body: { empleado_id: string; metodo?: string; dispositivo_id?: string },
    userId: number,
  ) {
    const idPersonal = await this.resolvePersonalId(body.empleado_id);
    const idDispositivo = await this.resolveDispositivoId(body.dispositivo_id);
    const result = await this.marcacionService.registrar(
      {
        id_personal: idPersonal,
        metodo: this.mapMetodo(body.metodo || 'facial'),
        id_dispositivo: idDispositivo,
      },
      userId,
    );
    return {
      mensaje: result.mensaje,
      data: result.data,
    };
  }

  async registrarOffline(
    body: {
      uuid: string;
      empleado_id: string;
      fecha_hora: string;
      tipo: string;
      metodo: string;
      device_id: string;
      nonce: string;
      request_ts: number;
      payload_hash: string;
      request_signature: string;
      latitud?: number;
      longitud?: number;
      foto_path?: string;
    },
    userId: number,
  ) {
    this.replaySignature.assertMarcacionRequest(body);
    const idPersonal = await this.resolvePersonalId(body.empleado_id);
    const idDispositivo = await this.resolveDispositivoId(body.device_id);
    const result = await this.marcacionService.registrar(
      {
        id_personal: idPersonal,
        metodo: this.mapMetodo(body.metodo),
        fecha_hora: body.fecha_hora,
        id_dispositivo: idDispositivo,
        latitud: body.latitud,
        longitud: body.longitud,
        hash_unico: body.uuid,
      },
      userId,
    );
    return {
      id: result.data?.id_marcacion ?? body.uuid,
      mensaje: result.mensaje,
      data: result.data,
    };
  }

  async listarRecientes(limit = 50) {
    const safeLimit = Math.min(100, Math.max(1, Number(limit) || 50));
    const rows = await this.dataSource.query(
      `SELECT
        m.id_marcacion,
        m.id_personal AS empleado_id,
        m.tipo_evento AS tipo,
        LOWER(m.metodo) AS metodo,
        m.fecha_hora,
        p.nombres,
        p.apellidos,
        p.dni
      FROM marcacion_asistencia m
      INNER JOIN personal p ON p.id_personal = m.id_personal
      WHERE m.estado_registro = 'ACTIVO'
      ORDER BY m.fecha_hora DESC
      LIMIT ?`,
      [safeLimit],
    );
    return rows.map((row: any) => ({
      ...row,
      empleado_id: String(row.empleado_id),
      tipo: String(row.tipo || '').toLowerCase(),
      metodo:
        row.metodo === 'manual'
          ? 'dni'
          : String(row.metodo || 'facial').toLowerCase(),
    }));
  }
}
