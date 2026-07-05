import { Component, inject, TemplateRef, ChangeDetectionStrategy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { NgbModalModule } from '@ng-bootstrap/ng-bootstrap';

import { useCrud } from 'src/app/core/utils/crud.util';
import { TableProComponent } from 'src/app/shared/components/table-pro/table-pro.component';
import { FormErrorComponent } from 'src/app/shared/components/form-error/form-error.component';
import { PermissionsService } from 'src/app/core/services/seguridad/permissions.service';
import { AlertService } from 'src/app/core/services/ui/alert.service';
import { AreasService } from './areas.service';

@Component({
  selector: 'app-areas',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, TableProComponent, FormErrorComponent, NgbModalModule],
  templateUrl: './areas.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class AreasComponent {
  private fb = inject(FormBuilder);
  private service = inject(AreasService);
  private alert = inject(AlertService);
  public perms = inject(PermissionsService);

  public crud = useCrud<any>(this.service as any, { itemName: 'Área' });

  form: FormGroup = this.fb.group({
    nombre: ['', Validators.required],
  });

  onSearch(term: string) { this.crud.searchControl.setValue(term); }

  abrirModal(modalTemplate: TemplateRef<any>, item?: any) {
    if (document.activeElement instanceof HTMLElement) document.activeElement.blur();
    this.crud.setupModal(item?.id_area ?? null);
    this.form.reset();
    if (item) this.form.patchValue({ nombre: item.nombre });
    this.crud.openModal(modalTemplate, { centered: true, backdrop: 'static' });
  }

  guardar() {
    if (this.form.invalid) { this.form.markAllAsTouched(); return; }
    this.crud.save(this.form.getRawValue());
  }

  eliminar(item: any) {
    this.crud.deleteItem(item.id_area, '¿Eliminar área?', 'Se perderá el registro si no tiene cargos activos asociados.');
  }
}
