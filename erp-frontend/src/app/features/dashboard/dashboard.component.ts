import { Component, inject, OnInit, ChangeDetectionStrategy, signal, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { BaseChartDirective } from 'ng2-charts';
import { ChartConfiguration, ChartData, Plugin } from 'chart.js';
import { AlertService } from 'src/app/core/services/ui/alert.service';
import { LayoutService } from 'src/app/core/services/layout.service';
import { DashboardService } from './dashboard.service';

// Paleta categórica de 8 slots, orden fijo (no se reordena ni se genera un 9no color).
const CATEGORICAL_LIGHT = ['#2a78d6', '#1baf7a', '#eda100', '#008300', '#4a3aa7', '#e34948', '#e87ba4', '#eb6834'];
const CATEGORICAL_DARK = ['#3987e5', '#199e70', '#c98500', '#008300', '#9085e9', '#e66767', '#d55181', '#d95926'];

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule, BaseChartDirective],
  templateUrl: './dashboard.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class DashboardComponent implements OnInit {
  private service = inject(DashboardService);
  private alert = inject(AlertService);
  private layout = inject(LayoutService);

  loading = signal<boolean>(true);
  porCaserio = signal<{ id_caserio: number; caserio: string; total_comuneros: number }[]>([]);

  darkMode = this.layout.darkMode;

  totalGeneral = computed(() =>
    this.porCaserio().reduce((sum, c) => sum + c.total_comuneros, 0)
  );

  private porCaserioDescendente = computed(() =>
    [...this.porCaserio()].sort((a, b) => b.total_comuneros - a.total_comuneros)
  );

  // Top 7 + "Otros" agrupado — nunca más de 8 colores categóricos.
  private dataDona = computed(() => {
    const lista = this.porCaserioDescendente();
    const top = lista.slice(0, 7);
    const resto = lista.slice(7);
    const otros = resto.reduce((sum, c) => sum + c.total_comuneros, 0);
    return otros > 0 ? [...top, { id_caserio: -1, caserio: 'Otros', total_comuneros: otros }] : top;
  });

  chartTypeDona = 'doughnut' as const;

  chartDataDona = computed<ChartData<'doughnut'>>(() => {
    const lista = this.dataDona();
    const colores = this.darkMode() ? CATEGORICAL_DARK : CATEGORICAL_LIGHT;
    return {
      labels: lista.map((c) => c.caserio),
      datasets: [
        {
          data: lista.map((c) => c.total_comuneros),
          backgroundColor: lista.map((_, i) => colores[i % colores.length]),
          borderWidth: 2,
          borderColor: this.darkMode() ? '#1a1a19' : '#fcfcfb',
          hoverOffset: 10,
        },
      ],
    };
  });

  chartOptionsDona = computed<ChartConfiguration<'doughnut'>['options']>(() => {
    const dark = this.darkMode();
    const tickColor = dark ? '#c3c2b7' : '#52514e';
    const total = this.totalGeneral();

    return {
      responsive: true,
      maintainAspectRatio: false,
      cutout: '68%',
      plugins: {
        legend: {
          position: 'bottom',
          labels: {
            color: tickColor,
            boxWidth: 10,
            boxHeight: 10,
            padding: 16,
            font: { size: 12 },
            generateLabels: (chart) => {
              const data = chart.data.datasets[0].data as number[];
              const colors = chart.data.datasets[0].backgroundColor as string[];
              return (chart.data.labels as string[]).map((label, i) => {
                const pct = total > 0 ? Math.round((data[i] / total) * 100) : 0;
                return {
                  text: `${label}  ${pct}%`,
                  fillStyle: colors[i],
                  strokeStyle: colors[i],
                  fontColor: tickColor,
                  index: i,
                };
              });
            },
          },
        },
        tooltip: {
          callbacks: {
            label: (ctx) => {
              const valor = ctx.parsed as number;
              const pct = total > 0 ? Math.round((valor / total) * 100) : 0;
              return `${ctx.label}: ${valor} comuneros (${pct}%)`;
            },
          },
        },
      },
    };
  });

  // Plugin propio: número total al centro de la dona (el "hero number" del gráfico).
  centerTextPlugin = computed<Plugin<'doughnut'>>(() => {
    const dark = this.darkMode();
    const primaryColor = dark ? '#ffffff' : '#0b0b0b';
    const secondaryColor = dark ? '#c3c2b7' : '#52514e';
    const total = this.totalGeneral();

    return {
      id: 'centerText',
      afterDraw: (chart) => {
        const { ctx, chartArea } = chart;
        if (!chartArea) return;
        const centerX = (chartArea.left + chartArea.right) / 2;
        const centerY = (chartArea.top + chartArea.bottom) / 2;

        ctx.save();
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';

        ctx.font = '700 28px system-ui, -apple-system, "Segoe UI", sans-serif';
        ctx.fillStyle = primaryColor;
        ctx.fillText(total.toLocaleString('es-PE'), centerX, centerY - 10);

        ctx.font = '600 12px system-ui, -apple-system, "Segoe UI", sans-serif';
        ctx.fillStyle = secondaryColor;
        ctx.fillText('COMUNEROS', centerX, centerY + 14);

        ctx.restore();
      },
    };
  });

  ngOnInit() {
    this.service.resumenComuneros().subscribe({
      next: (res: any) => {
        const data = res.data?.data || res.data;
        this.porCaserio.set(data.por_caserio || []);
        this.loading.set(false);
      },
      error: () => {
        this.loading.set(false);
        this.alert.error('No se pudo cargar el resumen del dashboard.');
      },
    });
  }
}
