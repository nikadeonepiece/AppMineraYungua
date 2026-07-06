import { Component, ChangeDetectionStrategy, signal, inject, computed, effect } from '@angular/core';
import { ErpTabsComponent, ErpTab } from 'src/app/shared/components/erp-tabs/erp-tabs.component';
import { PermissionsService } from 'src/app/core/services/seguridad/permissions.service';
import { ComunidadCampesinaComponent } from './comunidad-campesina/comunidad-campesina.component';
import { CaseriosComponent } from './caserios/caserios.component';
import { ComunerosComponent } from './comuneros/comuneros.component';
import { ParcelasComponent } from './parcelas/parcelas.component';
import { CertificadosPosesionComponent } from './certificados-posesion/certificados-posesion.component';
import { FotocheckComponent } from './fotocheck/fotocheck.component';

type ComunerosTab = ErpTab & { permiso: string };

@Component({
  selector: 'app-comuneros-page',
  standalone: true,
  imports: [
    ErpTabsComponent, ComunidadCampesinaComponent, CaseriosComponent, ComunerosComponent,
    ParcelasComponent, CertificadosPosesionComponent, FotocheckComponent,
  ],
  template: `
    <div class="container-fluid p-3 p-md-4 form-wrapper mx-auto" style="max-width: var(--erp-max-width);">
      <app-erp-tabs [tabs]="tabs()" [activeTab]="tabActivo()" (tabChange)="tabActivo.set($event)"></app-erp-tabs>

      <div class="card-pro table-pro-container mb-3 p-0 p-md-3 animate__animated animate__fadeInUp">
        @switch (tabActivo()) {
          @case ('comunidad-campesina') { <app-comunidad-campesina /> }
          @case ('caserios') { <app-caserios /> }
          @case ('comuneros') { <app-comuneros /> }
          @case ('parcelas') { <app-parcelas /> }
          @case ('certificados-posesion') { <app-certificados-posesion /> }
          @case ('fotocheck') { <app-fotocheck /> }
        }
      </div>
    </div>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ComunerosPageComponent {
  private perms = inject(PermissionsService);

  tabActivo = signal<string>('comunidad-campesina');

  private readonly allTabs: ComunerosTab[] = [
    { id: 'comunidad-campesina', label: 'Comunidades Campesinas', icon: 'bi-house-heart-fill', permiso: 'ver_comunero' },
    { id: 'caserios', label: 'Caseríos', icon: 'bi-signpost-split-fill', permiso: 'ver_comunero' },
    { id: 'comuneros', label: 'Comuneros', icon: 'bi-person-badge-fill', permiso: 'ver_comunero' },
    { id: 'parcelas', label: 'Parcelas', icon: 'bi-map-fill', permiso: 'ver_comunero' },
    { id: 'certificados-posesion', label: 'Certificados de Posesión', icon: 'bi-file-earmark-check-fill', permiso: 'ver_certificado_posesion' },
    { id: 'fotocheck', label: 'Generar Fotocheck', icon: 'bi-person-vcard-fill', permiso: 'ver_fotocheck' },
  ];

  tabs = computed(() =>
    this.allTabs.filter((tab) => this.perms.hasPermission(tab.permiso)),
  );

  constructor() {
    effect(() => {
      const visible = this.tabs();
      if (visible.length === 0) return;
      if (!visible.some((tab) => tab.id === this.tabActivo())) {
        this.tabActivo.set(visible[0].id);
      }
    });
  }
}
