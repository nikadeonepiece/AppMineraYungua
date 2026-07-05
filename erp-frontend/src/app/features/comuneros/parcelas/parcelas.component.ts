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
import { ParcelasService } from './parcelas.service';
import { ComunerosService } from '../comuneros/comuneros.service';
import { CaseriosService } from '../caserios/caserios.service';

@Component({
  selector: 'app-parcelas',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, TableProComponent, FormErrorComponent, NgbModalModule, NgSelectModule],
  templateUrl: './parcelas.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ParcelasComponent implements OnInit {
  private fb = inject(FormBuilder);
  private service = inject(ParcelasService);
  private comunerosService = inject(ComunerosService);
  private caseriosService = inject(CaseriosService);
  private alert = inject(AlertService);
  public perms = inject(PermissionsService);

  public crud = useCrud<any>(this.service as any, { itemName: 'Parcela' });

  comuneros = signal<any[]>([]);
  caserios = signal<any[]>([]);

  form: FormGroup = this.fb.group({
    id_comunero: [null, Validators.required],
    id_caserio: [null, Validators.required],
    denominacion: [''],
    hectareas: [null],
    colindante_este: [''],
    colindante_oeste: [''],
    colindante_norte: [''],
    colindante_sur: [''],
  });

  ngOnInit() {
    this.comunerosService.findAll(1, 500, '').subscribe({
      next: (res: any) => this.comuneros.set(res.data?.data || res.data || []),
    });
    this.caseriosService.findAll(1, 200, '').subscribe({
      next: (res: any) => this.caserios.set(res.data?.data || res.data || []),
    });
  }

  onSearch(term: string) { this.crud.searchControl.setValue(term); }

  abrirModal(modalTemplate: TemplateRef<any>, item?: any) {
    if (document.activeElement instanceof HTMLElement) document.activeElement.blur();
    this.crud.setupModal(item?.id_parcela ?? null);
    this.form.reset();
    if (item) {
      this.form.patchValue({
        id_comunero: item.id_comunero,
        id_caserio: item.id_caserio,
        denominacion: item.denominacion,
        hectareas: item.hectareas,
        colindante_este: item.colindante_este,
        colindante_oeste: item.colindante_oeste,
        colindante_norte: item.colindante_norte,
        colindante_sur: item.colindante_sur,
      });
    }
    this.crud.openModal(modalTemplate, { centered: true, backdrop: 'static', size: 'lg' });
  }

  guardar() {
    if (this.form.invalid) { this.form.markAllAsTouched(); return; }
    const data = { ...this.form.getRawValue() };
    Object.keys(data).forEach((key) => {
      if (data[key] === '' || data[key] === null) delete data[key];
    });
    this.crud.save(data);
  }

  eliminar(item: any) {
    this.crud.deleteItem(
      item.id_parcela,
      '¿Eliminar parcela?',
      'Se perderá el registro si no tiene certificados de posesión activos asociados.',
    );
  }
}
