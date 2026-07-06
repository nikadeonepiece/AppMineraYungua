import { createHash } from 'crypto';
import { Injectable, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class ReplaySignatureService {
  constructor(private readonly config: ConfigService) {}

  private get secret(): string {
    return this.config.get<string>('REPLAY_SECRET') || 'offline-replay-secret-dev';
  }

  private get windowMs(): number {
    return Number(this.config.get<string>('REPLAY_TIMESTAMP_WINDOW_MS') || 300000);
  }

  normalizeFechaUtcIso(value: string | Date): string {
    const date = value instanceof Date ? value : new Date(value);
    const u = date;
    const truncated = new Date(
      Date.UTC(
        u.getUTCFullYear(),
        u.getUTCMonth(),
        u.getUTCDate(),
        u.getUTCHours(),
        u.getUTCMinutes(),
        u.getUTCSeconds(),
        u.getUTCMilliseconds(),
      ),
    );
    return truncated.toISOString();
  }

  computeMarcacionPayloadHash(input: {
    uuid: string;
    empleado_id: string;
    fecha_hora: string;
    tipo: string;
    metodo: string;
    latitud?: number | null;
    longitud?: number | null;
    foto_path?: string | null;
    device_id: string;
  }): string {
    const payload = {
      uuid: input.uuid,
      empleado_id: input.empleado_id,
      fecha_hora: this.normalizeFechaUtcIso(input.fecha_hora),
      tipo: input.tipo,
      metodo: input.metodo,
      latitud: input.latitud ?? null,
      longitud: input.longitud ?? null,
      foto_path: input.foto_path ?? null,
      device_id: input.device_id,
    };
    return createHash('sha256').update(JSON.stringify(payload)).digest('hex');
  }

  computeNonceSignature(nonce: string, payloadHash: string, timestampMs: number): string {
    const raw = `${nonce}|${payloadHash}|${timestampMs}|${this.secret}`;
    return createHash('sha256').update(raw).digest('hex');
  }

  assertMarcacionRequest(input: {
    nonce: string;
    payload_hash: string;
    request_signature: string;
    request_ts: number;
    uuid: string;
    empleado_id: string;
    fecha_hora: string;
    tipo: string;
    metodo: string;
    latitud?: number | null;
    longitud?: number | null;
    foto_path?: string | null;
    device_id: string;
  }): void {
    const now = Date.now();
    if (Math.abs(now - input.request_ts) > this.windowMs) {
      throw new UnauthorizedException('Timestamp fuera de ventana');
    }

    const expectedHash = this.computeMarcacionPayloadHash(input);
    if (expectedHash !== input.payload_hash) {
      throw new UnauthorizedException('Hash de payload inválido');
    }

    const expectedSignature = this.computeNonceSignature(
      input.nonce,
      input.payload_hash,
      input.request_ts,
    );
    if (expectedSignature !== input.request_signature) {
      throw new UnauthorizedException('Firma de solicitud inválida');
    }
  }
}
