import { Component, inject, TemplateRef, ChangeDetectionStrategy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { NgbModalModule } from '@ng-bootstrap/ng-bootstrap';

import { useCrud } from 'src/app/core/utils/crud.util';
import { TableProComponent } from 'src/app/shared/components/table-pro/table-pro.component';
import { FormErrorComponent } from 'src/app/shared/components/form-error/form-error.component';
import { PermissionsService } from 'src/app/core/services/seguridad/permissions.service';
import { AlertService } from 'src/app/core/services/ui/alert.service';
import { ComunidadCampesinaService } from './comunidad-campesina.service';

@Component({
  selector: 'app-comunidad-campesina',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, TableProComponent, FormErrorComponent, NgbModalModule],
  templateUrl: './comunidad-campesina.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ComunidadCampesinaComponent {
  private fb = inject(FormBuilder);
  private service = inject(ComunidadCampesinaService);
  private alert = inject(AlertService);
  public perms = inject(PermissionsService);

  public crud = useCrud<any>(this.service as any, { itemName: 'Comunidad campesina' });

  form: FormGroup = this.fb.group({
    nombre: ['', Validators.required],
    distrito: [''],
    provincia: [''],
    departamento: [''],
    numero_partida_registral: [''],
    oficina_registral: [''],
  });

  onSearch(term: string) { this.crud.searchControl.setValue(term); }

  abrirModal(modalTemplate: TemplateRef<any>, item?: any) {
    if (document.activeElement instanceof HTMLElement) document.activeElement.blur();
    this.crud.setupModal(item?.id_comunidad_campesina ?? null);
    this.form.reset();
    if (item) {
      this.form.patchValue({
        nombre: item.nombre,
        distrito: item.distrito,
        provincia: item.provincia,
        departamento: item.departamento,
        numero_partida_registral: item.numero_partida_registral,
        oficina_registral: item.oficina_registral,
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
      item.id_comunidad_campesina,
      '¿Eliminar comunidad campesina?',
      'Se perderá el registro si no tiene caseríos activos asociados.',
    );
  }
}
