import { Component, ChangeDetectionStrategy, signal } from '@angular/core';
import { ErpTabsComponent, ErpTab } from 'src/app/shared/components/erp-tabs/erp-tabs.component';
import { TrabajadoresComponent } from './trabajadores/trabajadores.component';
import { AreasComponent } from './areas/areas.component';
import { CargosComponent } from './cargos/cargos.component';
import { RegimenesComponent } from './regimenes/regimenes.component';
import { TurnosComponent } from './turnos/turnos.component';

@Component({
  selector: 'app-personal-page',
  standalone: true,
  imports: [ErpTabsComponent, TrabajadoresComponent, AreasComponent, CargosComponent, RegimenesComponent, TurnosComponent],
  template: `
    <div class="container-fluid p-3 p-md-4 form-wrapper mx-auto" style="max-width: var(--erp-max-width);">
      <app-erp-tabs [tabs]="tabs" [activeTab]="tabActivo()" (tabChange)="tabActivo.set($event)"></app-erp-tabs>

      <div class="card-pro table-pro-container mb-3 p-0 p-md-3 animate__animated animate__fadeInUp">
        @switch (tabActivo()) {
          @case ('trabajadores') { <app-trabajadores /> }
          @case ('areas') { <app-areas /> }
          @case ('cargos') { <app-cargos /> }
          @case ('regimenes') { <app-regimenes /> }
          @case ('turnos') { <app-turnos /> }
        }
      </div>
    </div>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class PersonalPageComponent {
  tabActivo = signal<string>('trabajadores');

  tabs: ErpTab[] = [
    { id: 'trabajadores', label: 'Trabajadores', icon: 'bi-people-fill' },
    { id: 'areas', label: 'Áreas', icon: 'bi-diagram-3-fill' },
    { id: 'cargos', label: 'Cargos', icon: 'bi-person-badge-fill' },
    { id: 'regimenes', label: 'Regímenes', icon: 'bi-arrow-repeat' },
    { id: 'turnos', label: 'Turnos', icon: 'bi-clock-fill' },
  ];
}
