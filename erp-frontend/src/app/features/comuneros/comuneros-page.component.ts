import { Component, ChangeDetectionStrategy, signal } from '@angular/core';
import { ErpTabsComponent, ErpTab } from 'src/app/shared/components/erp-tabs/erp-tabs.component';
import { ComunidadCampesinaComponent } from './comunidad-campesina/comunidad-campesina.component';
import { CaseriosComponent } from './caserios/caserios.component';
import { ComunerosComponent } from './comuneros/comuneros.component';
import { ParcelasComponent } from './parcelas/parcelas.component';
import { CertificadosPosesionComponent } from './certificados-posesion/certificados-posesion.component';
import { FotocheckComponent } from './fotocheck/fotocheck.component';

@Component({
  selector: 'app-comuneros-page',
  standalone: true,
  imports: [
    ErpTabsComponent, ComunidadCampesinaComponent, CaseriosComponent, ComunerosComponent,
    ParcelasComponent, CertificadosPosesionComponent, FotocheckComponent,
  ],
  template: `
    <div class="container-fluid p-3 p-md-4 form-wrapper mx-auto" style="max-width: var(--erp-max-width);">
      <app-erp-tabs [tabs]="tabs" [activeTab]="tabActivo()" (tabChange)="tabActivo.set($event)"></app-erp-tabs>

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
  tabActivo = signal<string>('comunidad-campesina');

  tabs: ErpTab[] = [
    { id: 'comunidad-campesina', label: 'Comunidades Campesinas', icon: 'bi-house-heart-fill' },
    { id: 'caserios', label: 'Caseríos', icon: 'bi-signpost-split-fill' },
    { id: 'comuneros', label: 'Comuneros', icon: 'bi-person-badge-fill' },
    { id: 'parcelas', label: 'Parcelas', icon: 'bi-map-fill' },
    { id: 'certificados-posesion', label: 'Certificados de Posesión', icon: 'bi-file-earmark-check-fill' },
    { id: 'fotocheck', label: 'Generar Fotocheck', icon: 'bi-person-vcard-fill' },
  ];
}
