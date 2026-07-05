import { Component, inject, OnInit, ChangeDetectionStrategy, signal, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { BaseChartDirective } from 'ng2-charts';
import { ChartConfiguration, ChartData } from 'chart.js';
import { AlertService } from 'src/app/core/services/ui/alert.service';
import { LayoutService } from 'src/app/core/services/layout.service';
import { DashboardService } from './dashboard.service';

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

  private porCaserioOrdenado = computed(() =>
    [...this.porCaserio()].sort((a, b) => a.total_comuneros - b.total_comuneros)
  );

  chartType = 'bar' as const;

  chartData = computed<ChartData<'bar'>>(() => {
    const lista = this.porCaserioOrdenado();
    const barColor = this.darkMode() ? '#3987e5' : '#256abf';
    return {
      labels: lista.map((c) => c.caserio),
      datasets: [
        {
          label: 'Comuneros',
          data: lista.map((c) => c.total_comuneros),
          backgroundColor: barColor,
          borderRadius: 4,
          maxBarThickness: 24,
        },
      ],
    };
  });

  chartOptions = computed<ChartConfiguration<'bar'>['options']>(() => {
    const dark = this.darkMode();
    const gridColor = dark ? '#2c2c2a' : '#e1e0d9';
    const tickColor = dark ? '#c3c2b7' : '#52514e';
    const baselineColor = dark ? '#383835' : '#c3c2b7';

    return {
      indexAxis: 'y',
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: { display: false },
        tooltip: {
          callbacks: {
            label: (ctx) => `${ctx.formattedValue} comuneros`,
          },
        },
      },
      scales: {
        x: {
          beginAtZero: true,
          grid: { color: gridColor },
          border: { color: baselineColor },
          ticks: { color: tickColor, precision: 0 },
        },
        y: {
          grid: { display: false },
          border: { color: baselineColor },
          ticks: { color: tickColor, font: { size: 12, weight: 600 } },
        },
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
