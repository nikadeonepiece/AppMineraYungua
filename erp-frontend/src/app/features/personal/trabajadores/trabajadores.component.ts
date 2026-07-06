import { Component, inject, OnInit, TemplateRef, ChangeDetectionStrategy, signal, DestroyRef } from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { NgbModalModule } from '@ng-bootstrap/ng-bootstrap';
import { NgSelectModule } from '@ng-select/ng-select';
import { Subject, forkJoin } from 'rxjs';
import { debounceTime, distinctUntilChanged, switchMap } from 'rxjs/operators';

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
import { environment } from 'src/environments/environment';
import { LayoutService } from 'src/app/core/services/layout.service';

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
  private layout = inject(LayoutService);
  public perms = inject(PermissionsService);
  private destroyRef = inject(DestroyRef);

  public crud = useCrud<any>(this.service as any, { itemName: 'Trabajador' });

  areas = signal<any[]>([]);
  cargos = signal<any[]>([]);
  regimenes = signal<any[]>([]);
  comuneros = signal<any[]>([]);
  buscandoComunero = signal(false);
  fotoPreview = signal<string | null>(null);
  firmaPreview = signal<string | null>(null);
  fotoPendiente = signal(false);
  firmaPendiente = signal(false);
  private fotoFile: File | null = null;
  private firmaFile: File | null = null;
  private fotoGuardadaUrl: string | null = null;
  private firmaGuardadaUrl: string | null = null;
  private buscarComunero$ = new Subject<string>();

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
    id_comunero: [null],
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

    this.buscarComunero$
      .pipe(
        debounceTime(300),
        distinctUntilChanged(),
        switchMap((term) => {
          this.buscandoComunero.set(true);
          return this.service.buscarComuneros(term, this.crud.editingId() || undefined);
        }),
        takeUntilDestroyed(this.destroyRef),
      )
      .subscribe({
        next: (res: any) => {
          this.buscandoComunero.set(false);
          this.comuneros.set(res.data || res || []);
        },
        error: () => this.buscandoComunero.set(false),
      });
  }

  onSearch(term: string) { this.crud.searchControl.setValue(term); }

  assetUrl(path: string | null | undefined): string | null {
    if (!path) return null;
    const rel = String(path).replace(/^uploads\//, '');
    return `${environment.uploadsUrl}${rel}`;
  }

  private resetArchivos() {
    this.fotoFile = null;
    this.firmaFile = null;
    this.fotoPendiente.set(false);
    this.firmaPendiente.set(false);
    this.fotoGuardadaUrl = null;
    this.firmaGuardadaUrl = null;
    this.fotoPreview.set(null);
    this.firmaPreview.set(null);
  }

  onFotoSeleccionada(event: Event) {
    const input = event.target as HTMLInputElement;
    const file = input.files?.[0];
    if (!file) return;
    if (!file.type.startsWith('image/')) {
      this.alert.error('La foto debe ser una imagen (JPG, PNG o WEBP).');
      input.value = '';
      return;
    }
    this.fotoFile = file;
    this.fotoPendiente.set(true);
    this.fotoPreview.set(URL.createObjectURL(file));
  }

  onFirmaSeleccionada(event: Event) {
    const input = event.target as HTMLInputElement;
    const file = input.files?.[0];
    if (!file) return;
    if (!file.type.startsWith('image/')) {
      this.alert.error('La firma debe ser una imagen (JPG, PNG o WEBP).');
      input.value = '';
      return;
    }
    this.firmaFile = file;
    this.firmaPendiente.set(true);
    this.firmaPreview.set(URL.createObjectURL(file));
  }

  quitarFoto() {
    this.fotoFile = null;
    this.fotoPendiente.set(false);
    this.fotoPreview.set(this.fotoGuardadaUrl);
  }

  quitarFirma() {
    this.firmaFile = null;
    this.firmaPendiente.set(false);
    this.firmaPreview.set(this.firmaGuardadaUrl);
  }

  onBuscarComunero(term: string) { this.buscarComunero$.next(term); }

  onComuneroSeleccionado(comunero: any | null) {
    if (comunero) {
      const partes = String(comunero.apellidos_nombres || '').trim().split(/\s+/).filter(Boolean);
      const apellidos = partes.slice(0, 2).join(' ');
      const nombres = partes.slice(2).join(' ');
      this.form.patchValue({
        dni: comunero.dni || this.form.get('dni')!.value,
        apellidos: apellidos || this.form.get('apellidos')!.value,
        nombres: nombres || this.form.get('nombres')!.value,
      });
      if (comunero.dni) this.form.get('dni')!.disable();
    } else {
      this.form.get('dni')!.enable();
    }
  }

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
          this.form.get('dni')!.enable();
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
            id_comunero: data.id_comunero,
            centro_trabajo: data.centro_trabajo,
            observaciones: data.observaciones,
            consentimiento_biometrico: !!data.consentimiento_biometrico,
          });
          this.resetArchivos();
          this.fotoGuardadaUrl = this.assetUrl(data.foto);
          this.firmaGuardadaUrl = this.assetUrl(data.firma);
          this.fotoPreview.set(this.fotoGuardadaUrl);
          this.firmaPreview.set(this.firmaGuardadaUrl);
          this.comuneros.set([]);
          if (data.id_comunero) {
            this.form.get('dni')!.disable();
            this.service.buscarComuneros('', data.id_personal, data.id_comunero).subscribe({
              next: (res: any) => this.comuneros.set(res.data || res || []),
            });
          }
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
      this.form.get('dni')!.enable();
      this.comuneros.set([]);
      this.resetArchivos();
      this.crud.openModal(modalTemplate, { centered: true, backdrop: 'static', size: 'lg' });
    }
  }

  guardar() {
    if (this.form.invalid) { this.form.markAllAsTouched(); return; }

    const data = { ...this.form.getRawValue() };
    Object.keys(data).forEach((key) => {
      if (data[key] === '' || data[key] === null) delete data[key];
    });

    const id = this.crud.editingId();
    const puedeSubirArchivos = this.perms.hasPermission('editar_personal');
    const tieneArchivos = !!(this.fotoFile || this.firmaFile);

    if (tieneArchivos && !puedeSubirArchivos) {
      this.alert.error('No tiene permiso para subir foto o firma del trabajador.');
      return;
    }

    this.layout.showLoader();
    this.crud.tableLoading.set(true);

    const req$ = id ? this.service.update(id, data) : this.service.create(data);

    req$.pipe(takeUntilDestroyed(this.destroyRef)).subscribe({
      next: (res: any) => {
        const row = res.data?.data || res.data;
        const personalId = id || row?.id_personal;
        if (!personalId) {
          this.finalizarGuardado();
          return;
        }
        if (!tieneArchivos) {
          this.finalizarGuardado();
          return;
        }

        const uploads = [];
        if (this.fotoFile) uploads.push(this.service.uploadFoto(personalId, this.fotoFile));
        if (this.firmaFile) uploads.push(this.service.uploadFirma(personalId, this.firmaFile));

        forkJoin(uploads).pipe(takeUntilDestroyed(this.destroyRef)).subscribe({
          next: () => this.finalizarGuardado(),
          error: (err: any) => {
            this.layout.hideLoader();
            this.crud.tableLoading.set(false);
            const msg = err.error?.mensaje || err.error?.message || 'Datos guardados, pero falló la subida de archivos.';
            this.alert.error(Array.isArray(msg) ? msg[0] : msg);
            this.crud.closeModal();
            this.crud.refresh();
          },
        });
      },
      error: (err: any) => {
        this.layout.hideLoader();
        this.crud.tableLoading.set(false);
        const msg = err.error?.mensaje || err.error?.message || 'Error al procesar';
        this.alert.error(Array.isArray(msg) ? msg[0] : msg);
      },
    });
  }

  private finalizarGuardado() {
    this.layout.hideLoader();
    this.crud.tableLoading.set(false);
    this.crud.closeModal();
    this.alert.success('Trabajador guardado correctamente');
    if (!this.crud.editingId()) {
      this.crud.page.set(1);
      if (this.crud.searchControl.value) this.crud.searchControl.setValue('', { emitEvent: false });
    }
    this.crud.refresh();
  }

  eliminar(item: any) {
    this.crud.deleteItem(item.id_personal, '¿Eliminar trabajador?', 'Se perderá el registro.');
  }
}
