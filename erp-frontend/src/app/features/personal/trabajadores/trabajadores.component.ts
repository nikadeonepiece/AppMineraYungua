import { Component, inject, OnInit, TemplateRef, ChangeDetectionStrategy, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { NgbModalModule } from '@ng-bootstrap/ng-bootstrap';
import { NgSelectModule } from '@ng-select/ng-select';

import { useCrud } from 'src/app/core/utils/crud.util';
import { TableProComponent } from 'src/app/shared/components/table-pro/table-pro.component';
import { FormErrorComponent } from 'src/app/shared/components/form-error/form-error.component';
import { SingleDatePickerComponent } from 'src/app/shared/components/single-date-picker/single-date-picker.component';
import { PermissionsService } from 'src/app/core/services/seguridad/permissions.service';
import { AlertService } from 'src/app/core/services/ui/alert.service';
import { TrabajadoresService } from './trabajadores.service';
import { AreasService } from '../areas/areas.service';
import { CargosService } from '../cargos/cargos.service';
import { RegimenesService } from '../regimenes/regimenes.service';

@Component({
  selector: 'app-trabajadores',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    TableProComponent,
    FormErrorComponent,
    SingleDatePickerComponent,
    NgbModalModule,
    NgSelectModule,
  ],
  templateUrl: './trabajadores.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class TrabajadoresComponent implements OnInit {
  private fb = inject(FormBuilder);
  private service = inject(TrabajadoresService);
  private areasService = inject(AreasService);
  private cargosService = inject(CargosService);
  private regimenesService = inject(RegimenesService);
  private alert = inject(AlertService);
  public perms = inject(PermissionsService);

  public crud = useCrud<any>(this.service as any, { itemName: 'Trabajador' });

  areas = signal<any[]>([]);
  cargos = signal<any[]>([]);
  regimenes = signal<any[]>([]);

  form: FormGroup = this.fb.group({
    dni: ['', [Validators.required, Validators.pattern(/^\d{8}$/)]],
    codigo_personal: [''],
    nombres: ['', Validators.required],
    apellidos: ['', Validators.required],
    telefono: [''],
    correo: ['', Validators.email],
    fecha_nacimiento: [null],
    sexo: [null],
    fecha_ingreso: [null],
    id_area: [null],
    id_cargo: [null],
    id_regimen: [null],
    centro_trabajo: [''],
    observaciones: [''],
    consentimiento_biometrico: [false],
  });

  ngOnInit() {
    this.areasService.findAll(1, 200, '').subscribe({
      next: (res: any) => this.areas.set(res.data?.data || res.data || []),
    });
    this.cargosService.findAll(1, 200, '').subscribe({
      next: (res: any) => this.cargos.set(res.data?.data || res.data || []),
    });
    this.regimenesService.findAll(1, 200, '').subscribe({
      next: (res: any) => this.regimenes.set(res.data?.data || res.data || []),
    });
  }

  onSearch(term: string) { this.crud.searchControl.setValue(term); }

  abrirModal(modalTemplate: TemplateRef<any>, item?: any) {
    if (document.activeElement instanceof HTMLElement) document.activeElement.blur();

    if (item) {
      this.alert.showLoading('Cargando trabajador...');
      this.service.findOne(item.id_personal).subscribe({
        next: (res: any) => {
          this.alert.closeLoading();
          const data = res.data?.data || res.data;
          this.crud.setupModal(data.id_personal);
          this.form.reset();
          this.form.patchValue({
            dni: data.dni,
            codigo_personal: data.codigo_personal,
            nombres: data.nombres,
            apellidos: data.apellidos,
            telefono: data.telefono,
            correo: data.correo,
            fecha_nacimiento: data.fecha_nacimiento,
            sexo: data.sexo,
            fecha_ingreso: data.fecha_ingreso,
            id_area: data.id_area,
            id_cargo: data.id_cargo,
            id_regimen: data.id_regimen,
            centro_trabajo: data.centro_trabajo,
            observaciones: data.observaciones,
            consentimiento_biometrico: !!data.consentimiento_biometrico,
          });
          this.crud.openModal(modalTemplate, { centered: true, backdrop: 'static', size: 'lg' });
        },
        error: () => {
          this.alert.closeLoading();
          this.alert.error('No se pudo cargar el trabajador.');
        },
      });
    } else {
      this.crud.setupModal(null);
      this.form.reset({ consentimiento_biometrico: false });
      this.crud.openModal(modalTemplate, { centered: true, backdrop: 'static', size: 'lg' });
    }
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
    this.crud.deleteItem(item.id_personal, '¿Eliminar trabajador?', 'Se perderá el registro.');
  }
}
