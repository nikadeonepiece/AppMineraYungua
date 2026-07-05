import { Component, inject, OnInit, TemplateRef, ChangeDetectionStrategy, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { NgbModalModule } from '@ng-bootstrap/ng-bootstrap';
import { NgSelectModule } from '@ng-select/ng-select';

import { useCrud } from 'src/app/core/utils/crud.util';
import { TableProComponent } from 'src/app/shared/components/table-pro/table-pro.component';
import { FormErrorComponent } from 'src/app/shared/components/form-error/form-error.component';
import { PermissionsService } from 'src/app/core/services/seguridad/permissions.service';
import { AlertService } from 'src/app/core/services/ui/alert.service';
import { StatusBadgeComponent } from 'src/app/shared/components/status-badge/status-badge.component';
import { ComunerosService } from './comuneros.service';
import { CaseriosService } from '../caserios/caserios.service';

@Component({
  selector: 'app-comuneros',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, TableProComponent, FormErrorComponent, NgbModalModule, NgSelectModule, StatusBadgeComponent],
  templateUrl: './comuneros.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ComunerosComponent implements OnInit {
  private fb = inject(FormBuilder);
  private service = inject(ComunerosService);
  private caseriosService = inject(CaseriosService);
  private alert = inject(AlertService);
  public perms = inject(PermissionsService);

  public crud = useCrud<any>(this.service as any, { itemName: 'Comunero' });

  caserios = signal<any[]>([]);
  caseriosVinculados = signal<any[]>([]);
  guardandoVinculo = signal(false);

  form: FormGroup = this.fb.group({
    dni: ['', [Validators.required, Validators.pattern(/^\d{8}$/)]],
    apellidos_nombres: ['', Validators.required],
    consentimiento_biometrico: [false],
  });

  vinculoForm: FormGroup = this.fb.group({
    id_caserio: [null, Validators.required],
  });

  ngOnInit() {
    this.caseriosService.findAll(1, 200, '').subscribe({
      next: (res: any) => this.caserios.set(res.data?.data || res.data || []),
    });
  }

  onSearch(term: string) { this.crud.searchControl.setValue(term); }

  abrirModal(modalTemplate: TemplateRef<any>, item?: any) {
    if (document.activeElement instanceof HTMLElement) document.activeElement.blur();
    this.crud.setupModal(item?.id_comunero ?? null);
    this.form.reset({ consentimiento_biometrico: false });
    this.vinculoForm.reset();
    this.caseriosVinculados.set([]);

    if (item) {
      this.form.patchValue({
        dni: item.dni,
        apellidos_nombres: item.apellidos_nombres,
        consentimiento_biometrico: !!item.consentimiento_biometrico,
      });
      this.cargarCaseriosVinculados(item.id_comunero);
    }
    this.crud.openModal(modalTemplate, { centered: true, backdrop: 'static', size: 'lg' });
  }

  cargarCaseriosVinculados(idComunero: number) {
    this.service.findCaserios(idComunero).subscribe({
      next: (res: any) => this.caseriosVinculados.set(res.data || res || []),
    });
  }

  guardar() {
    if (this.form.invalid) { this.form.markAllAsTouched(); return; }
    this.crud.save(this.form.getRawValue());
  }

  vincularCaserio() {
    if (this.vinculoForm.invalid) { this.vinculoForm.markAllAsTouched(); return; }
    const idComunero = this.crud.editingId();
    if (!idComunero) return;

    this.guardandoVinculo.set(true);
    this.service.addCaserio(idComunero, this.vinculoForm.getRawValue()).subscribe({
      next: () => {
        this.guardandoVinculo.set(false);
        this.vinculoForm.reset();
        this.cargarCaseriosVinculados(idComunero);
      },
      error: () => this.guardandoVinculo.set(false),
    });
  }

  async desvincularCaserio(vinculo: any) {
    const idComunero = this.crud.editingId();
    if (!idComunero) return;
    if (!await this.alert.confirmDelete('¿Eliminar vínculo?', 'Se perderá la vinculación con este caserío.')) return;

    this.service.removeCaserio(idComunero, vinculo.id_comunero_caserio).subscribe({
      next: () => {
        this.alert.success('Vínculo eliminado correctamente');
        this.cargarCaseriosVinculados(idComunero);
      },
    });
  }

  eliminar(item: any) {
    this.crud.deleteItem(
      item.id_comunero,
      '¿Eliminar comunero?',
      'Se perderá el registro si no tiene vínculos activos (trabajador, caserío, parcela o certificado).',
    );
  }
}
