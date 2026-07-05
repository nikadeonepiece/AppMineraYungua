import { Injectable } from '@nestjs/common';
import { DataSource } from 'typeorm';
import { InjectDataSource } from '@nestjs/typeorm';

@Injectable()
export class DashboardService {
  constructor(@InjectDataSource('APP_MINERA_YUNGUA_CONN') private dataSource: DataSource) {}

  async resumenComuneros() {
    const [[totales]] = await Promise.all([
      this.dataSource.query(`
        SELECT
          COUNT(*) AS total_comuneros,
          SUM(dni_validado_reniec = 1) AS validados_reniec,
          SUM(dni_validado_reniec = 0) AS pendientes_reniec
        FROM comunero
        WHERE estado_registro = 'ACTIVO'
      `),
    ]);

    const porCaserio = await this.dataSource.query(`
      SELECT c.id_caserio, c.nombre AS caserio, COUNT(DISTINCT cc.id_comunero) AS total_comuneros
      FROM caserio c
      LEFT JOIN comunero_caserio cc ON cc.id_caserio = c.id_caserio AND cc.estado_registro = 'ACTIVO'
      WHERE c.estado_registro = 'ACTIVO'
      GROUP BY c.id_caserio, c.nombre
      ORDER BY total_comuneros DESC
    `);

    const [asambleas] = await this.dataSource.query(`
      SELECT
        COUNT(*) AS total_asambleas,
        SUM(estado = 'PROGRAMADA') AS programadas,
        SUM(estado = 'REALIZADA') AS realizadas,
        SUM(estado = 'CERRADA') AS cerradas
      FROM asamblea
      WHERE estado_registro = 'ACTIVO'
    `);

    const [asistencia] = await this.dataSource.query(`
      SELECT
        COUNT(*) AS total_convocados,
        SUM(firmo = 1) AS total_firmaron
      FROM asistencia_asamblea
      WHERE estado_registro = 'ACTIVO'
    `);

    return {
      success: true,
      data: {
        totales: {
          total_comuneros: Number(totales.total_comuneros) || 0,
          validados_reniec: Number(totales.validados_reniec) || 0,
          pendientes_reniec: Number(totales.pendientes_reniec) || 0,
        },
        por_caserio: porCaserio.map((r: any) => ({
          id_caserio: r.id_caserio,
          caserio: r.caserio,
          total_comuneros: Number(r.total_comuneros) || 0,
        })),
        asambleas: {
          total: Number(asambleas.total_asambleas) || 0,
          programadas: Number(asambleas.programadas) || 0,
          realizadas: Number(asambleas.realizadas) || 0,
          cerradas: Number(asambleas.cerradas) || 0,
        },
        asistencia: {
          total_convocados: Number(asistencia.total_convocados) || 0,
          total_firmaron: Number(asistencia.total_firmaron) || 0,
        },
      },
    };
  }
}
