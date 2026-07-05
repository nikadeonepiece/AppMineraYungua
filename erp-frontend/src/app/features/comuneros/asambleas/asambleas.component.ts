import { Component, inject, OnInit, TemplateRef, ChangeDetectionStrategy, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { NgbModalModule } from '@ng-bootstrap/ng-bootstrap';
import { NgSelectModule } from '@ng-select/ng-select';

import { useCrud } from 'src/app/core/utils/crud.util';
import { TableProComponent } from 'src/app/shared/components/table-pro/table-pro.component';
import { FormErrorComponent } from 'src/app/shared/components/form-error/form-error.component';
import { SingleDatePickerComponent } from 'src/app/shared/components/single-date-picker/single-date-picker.component';
import { StatusBadgeComponent } from 'src/app/shared/components/status-badge/status-badge.component';
import { PermissionsService } from 'src/app/core/services/seguridad/permissions.service';
import { AsambleasService } from './asambleas.service';
import { CaseriosService } from '../caserios/caserios.service';

@Component({
  selector: 'app-asambleas',
  standalone: true,
  imports: [
    CommonModule, ReactiveFormsModule, TableProComponent, FormErrorComponent,
    SingleDatePickerComponent, StatusBadgeComponent, NgbModalModule, NgSelectModule,
  ],
  templateUrl: './asambleas.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class AsambleasComponent implements OnInit {
  private fb = inject(FormBuilder);
  private service = inject(AsambleasService);
  private caseriosService = inject(CaseriosService);
  public perms = inject(PermissionsService);

  public crud = useCrud<any>(this.service as any, { itemName: 'Asamblea' });

  caserios = signal<any[]>([]);

  form: FormGroup = this.fb.group({
    id_caserios: [[], [Validators.required, Validators.minLength(1)]],
    titulo: [''],
    fecha: [null],
    estado: ['PROGRAMADA'],
  });

  ngOnInit() {
    this.caseriosService.findAll(1, 200, '').subscribe({
      next: (res: any) => this.caserios.set(res.data?.data || res.data || []),
    });
  }

  onSearch(term: string) { this.crud.searchControl.setValue(term); }

  abrirModal(modalTemplate: TemplateRef<any>, item?: any) {
    if (document.activeElement instanceof HTMLElement) document.activeElement.blur();
    this.crud.setupModal(item?.id_asamblea ?? null);
    this.form.reset({ estado: 'PROGRAMADA', id_caserios: [] });

    if (item) {
      this.form.patchValue({
        id_caserios: item.id_caserios || [],
        titulo: item.titulo,
        fecha: item.fecha,
        estado: item.estado,
      });
    }
    this.crud.openModal(modalTemplate, { centered: true, backdrop: 'static' });
  }

  guardar() {
    if (this.form.invalid) { this.form.markAllAsTouched(); return; }
    const data = { ...this.form.getRawValue() };
    if (!this.crud.editingId()) delete data.estado;
    Object.keys(data).forEach((key) => {
      if (data[key] === '' || data[key] === null) delete data[key];
    });
    this.crud.save(data);
  }
}
