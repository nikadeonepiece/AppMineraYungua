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
import { CargosService } from './cargos.service';
import { AreasService } from '../areas/areas.service';

@Component({
  selector: 'app-cargos',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, TableProComponent, FormErrorComponent, NgbModalModule, NgSelectModule],
  templateUrl: './cargos.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class CargosComponent implements OnInit {
  private fb = inject(FormBuilder);
  private service = inject(CargosService);
  private areasService = inject(AreasService);
  private alert = inject(AlertService);
  public perms = inject(PermissionsService);

  public crud = useCrud<any>(this.service as any, { itemName: 'Cargo' });

  areas = signal<any[]>([]);

  form: FormGroup = this.fb.group({
    id_area: [null, Validators.required],
    nombre: ['', Validators.required],
    requiere_brevete: [false],
  });

  ngOnInit() {
    this.areasService.findAll(1, 200, '').subscribe({
      next: (res: any) => this.areas.set(res.data?.data || res.data || []),
    });
  }

  onSearch(term: string) { this.crud.searchControl.setValue(term); }

  abrirModal(modalTemplate: TemplateRef<any>, item?: any) {
    if (document.activeElement instanceof HTMLElement) document.activeElement.blur();
    this.crud.setupModal(item?.id_cargo ?? null);
    this.form.reset({ requiere_brevete: false });
    if (item) {
      this.form.patchValue({
        id_area: item.id_area,
        nombre: item.nombre,
        requiere_brevete: !!item.requiere_brevete,
      });
    }
    this.crud.openModal(modalTemplate, { centered: true, backdrop: 'static' });
  }

  guardar() {
    if (this.form.invalid) { this.form.markAllAsTouched(); return; }
    this.crud.save(this.form.getRawValue());
  }

  eliminar(item: any) {
    this.crud.deleteItem(item.id_cargo, '¿Eliminar cargo?', 'Se perderá el registro si no tiene personal activo asignado.');
  }
}
