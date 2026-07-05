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
import { CaseriosService } from './caserios.service';
import { ComunidadCampesinaService } from '../comunidad-campesina/comunidad-campesina.service';

@Component({
  selector: 'app-caserios',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, TableProComponent, FormErrorComponent, NgbModalModule, NgSelectModule],
  templateUrl: './caserios.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class CaseriosComponent implements OnInit {
  private fb = inject(FormBuilder);
  private service = inject(CaseriosService);
  private comunidadesService = inject(ComunidadCampesinaService);
  private alert = inject(AlertService);
  public perms = inject(PermissionsService);

  public crud = useCrud<any>(this.service as any, { itemName: 'Caserío' });

  comunidades = signal<any[]>([]);
  caserios = signal<any[]>([]);

  form: FormGroup = this.fb.group({
    nombre: ['', Validators.required],
    id_comunidad_campesina: [null],
    id_caserio_padre: [null],
  });

  ngOnInit() {
    this.comunidadesService.findAll(1, 200, '').subscribe({
      next: (res: any) => this.comunidades.set(res.data?.data || res.data || []),
    });
    this.service.findAll(1, 200, '').subscribe({
      next: (res: any) => this.caserios.set(res.data?.data || res.data || []),
    });
  }

  onSearch(term: string) { this.crud.searchControl.setValue(term); }

  abrirModal(modalTemplate: TemplateRef<any>, item?: any) {
    if (document.activeElement instanceof HTMLElement) document.activeElement.blur();
    this.crud.setupModal(item?.id_caserio ?? null);
    this.form.reset();
    if (item) {
      this.form.patchValue({
        nombre: item.nombre,
        id_comunidad_campesina: item.id_comunidad_campesina,
        id_caserio_padre: item.id_caserio_padre,
      });
    }
    this.crud.openModal(modalTemplate, { centered: true, backdrop: 'static' });
  }

  guardar() {
    if (this.form.invalid) { this.form.markAllAsTouched(); return; }
    const data = { ...this.form.getRawValue() };
    Object.keys(data).forEach((key) => {
      if (data[key] === '' || data[key] === null) delete data[key];
    });
    this.crud.save(data, () => {
      this.service.findAll(1, 200, '').subscribe({
        next: (res: any) => this.caserios.set(res.data?.data || res.data || []),
      });
    });
  }

  eliminar(item: any) {
    this.crud.deleteItem(
      item.id_caserio,
      '¿Eliminar caserío?',
      'Se perderá el registro si no tiene sub-caseríos, comuneros, parcelas o asambleas activas asociadas.',
    );
  }
}
