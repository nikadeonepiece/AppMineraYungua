import { Component, inject, TemplateRef, ChangeDetectionStrategy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { NgbModalModule } from '@ng-bootstrap/ng-bootstrap';

import { useCrud } from 'src/app/core/utils/crud.util';
import { TableProComponent } from 'src/app/shared/components/table-pro/table-pro.component';
import { FormErrorComponent } from 'src/app/shared/components/form-error/form-error.component';
import { PermissionsService } from 'src/app/core/services/seguridad/permissions.service';
import { AlertService } from 'src/app/core/services/ui/alert.service';
import { TurnosService } from './turnos.service';

@Component({
  selector: 'app-turnos',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, TableProComponent, FormErrorComponent, NgbModalModule],
  templateUrl: './turnos.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class TurnosComponent {
  private fb = inject(FormBuilder);
  private service = inject(TurnosService);
  private alert = inject(AlertService);
  public perms = inject(PermissionsService);

  public crud = useCrud<any>(this.service as any, { itemName: 'Turno de trabajo' });

  form: FormGroup = this.fb.group({
    nombre_turno: ['', Validators.required],
    descripcion: [''],
    hora_inicio: [''],
    hora_fin: [''],
  });

  onSearch(term: string) { this.crud.searchControl.setValue(term); }

  abrirModal(modalTemplate: TemplateRef<any>, item?: any) {
    if (document.activeElement instanceof HTMLElement) document.activeElement.blur();
    this.crud.setupModal(item?.id_turno ?? null);
    this.form.reset();
    if (item) {
      this.form.patchValue({
        nombre_turno: item.nombre_turno,
        descripcion: item.descripcion,
        hora_inicio: item.hora_inicio,
        hora_fin: item.hora_fin,
      });
    }
    this.crud.openModal(modalTemplate, { centered: true, backdrop: 'static' });
  }

  guardar() {
    if (this.form.invalid) { this.form.markAllAsTouched(); return; }
    const data = { ...this.form.getRawValue() };
    if (!data.hora_inicio) delete data.hora_inicio;
    if (!data.hora_fin) delete data.hora_fin;
    if (!data.descripcion) delete data.descripcion;
    this.crud.save(data);
  }

  eliminar(item: any) {
    this.crud.deleteItem(item.id_turno, '¿Eliminar turno?', 'Se perderá el registro.');
  }
}
