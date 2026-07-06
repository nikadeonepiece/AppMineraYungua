import { Injectable, Logger, ServiceUnavailableException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

export interface FaceEmbeddingResponse {
  embedding: number[];
}

export interface FaceCompareResponse {
  score: number;
}

export interface FaceEnrollmentCaptureResponse extends FaceEmbeddingResponse {
  metrics?: Record<string, unknown>;
}

@Injectable()
export class FaceClientService {
  private readonly logger = new Logger(FaceClientService.name);

  constructor(private readonly config: ConfigService) {}

  private get baseUrl(): string {
    return (this.config.get<string>('FACE_SERVICE_URL') || 'http://127.0.0.1:8001').replace(/\/+$/, '');
  }

  private async postJson<T>(path: string, body: unknown): Promise<T> {
    const url = `${this.baseUrl}${path}`;
    try {
      const response = await fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body),
      });
      const text = await response.text();
      let parsed: unknown = {};
      if (text) {
        try {
          parsed = JSON.parse(text);
        } catch {
          parsed = { detail: text };
        }
      }
      if (!response.ok) {
        const detail =
          typeof parsed === 'object' && parsed !== null && 'detail' in parsed
            ? String((parsed as { detail: unknown }).detail)
            : `Face service error (${response.status})`;
        throw new ServiceUnavailableException(detail);
      }
      return parsed as T;
    } catch (error: any) {
      if (error instanceof ServiceUnavailableException) throw error;
      this.logger.error(`No se pudo contactar face-service en ${url}: ${error?.message || error}`);
      throw new ServiceUnavailableException('Servicio de reconocimiento facial no disponible');
    }
  }

  async health(): Promise<{ ok: boolean }> {
    const response = await fetch(`${this.baseUrl}/health`);
    if (!response.ok) {
      throw new ServiceUnavailableException('Face service no responde en /health');
    }
    return response.json() as Promise<{ ok: boolean }>;
  }

  generateEmbedding(imageBase64: string): Promise<FaceEmbeddingResponse> {
    return this.postJson<FaceEmbeddingResponse>('/generate-embedding', { imageBase64 });
  }

  enrollmentCapture(imageBase64: string): Promise<FaceEnrollmentCaptureResponse> {
    return this.postJson<FaceEnrollmentCaptureResponse>('/enrollment-capture', { imageBase64 });
  }

  compareEmbeddings(embedding1: number[], embedding2: number[]): Promise<FaceCompareResponse> {
    return this.postJson<FaceCompareResponse>('/compare', { embedding1, embedding2 });
  }

  detectFace(imageBase64: string): Promise<{ hasFace: boolean; count: number }> {
    return this.postJson<{ hasFace: boolean; count: number }>('/detect-face', { imageBase64 });
  }
}
