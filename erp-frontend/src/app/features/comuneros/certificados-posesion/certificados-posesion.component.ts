import { Component, inject, OnInit, TemplateRef, ChangeDetectionStrategy, signal, DestroyRef } from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { NgbModalModule } from '@ng-bootstrap/ng-bootstrap';
import { NgSelectModule } from '@ng-select/ng-select';
import { saveAs } from 'file-saver';

import { useCrud } from 'src/app/core/utils/crud.util';
import { TableProComponent } from 'src/app/shared/components/table-pro/table-pro.component';
import { FormErrorComponent } from 'src/app/shared/components/form-error/form-error.component';
import { SingleDatePickerComponent } from 'src/app/shared/components/single-date-picker/single-date-picker.component';
import { PermissionsService } from 'src/app/core/services/seguridad/permissions.service';
import { AlertService } from 'src/app/core/services/ui/alert.service';
import { CertificadosPosesionService } from './certificados-posesion.service';
import { ComunerosService } from '../comuneros/comuneros.service';
import { ParcelasService } from '../parcelas/parcelas.service';

@Component({
  selector: 'app-certificados-posesion',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, TableProComponent, FormErrorComponent, SingleDatePickerComponent, NgbModalModule, NgSelectModule],
  templateUrl: './certificados-posesion.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class CertificadosPosesionComponent implements OnInit {
  private fb = inject(FormBuilder);
  private service = inject(CertificadosPosesionService);
  private comunerosService = inject(ComunerosService);
  private parcelasService = inject(ParcelasService);
  private alert = inject(AlertService);
  private destroyRef = inject(DestroyRef);
  public perms = inject(PermissionsService);

  public crud = useCrud<any>(this.service as any, { itemName: 'Certificado de posesión' });

  comuneros = signal<any[]>([]);
  parcelas = signal<any[]>([]);
  parcelasExport = signal<any[]>([]);
  exportandoPdf = signal(false);

  form: FormGroup = this.fb.group({
    id_comunero: [null, Validators.required],
    id_parcela: [null, Validators.required],
    fecha_emision: [null],
  });

  exportForm: FormGroup = this.fb.group({
    id_comunero: [null, Validators.required],
    id_parcela: [null, Validators.required],
    fecha_emision: [null],
  });

  ngOnInit() {
    this.cargarComuneros('');
    this.parcelasService.findAll(1, 500, '').subscribe({
      next: (res: any) => {
        const lista = (res.data?.data || res.data || []).map((p: any) => ({
          ...p,
          etiqueta: `${p.denominacion || 'PARCELA #' + p.id_parcela} — ${p.nombre_comunero}`,
        }));
        this.parcelas.set(lista);
      },
    });

    this.exportForm.get('id_comunero')?.valueChanges
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe((idComunero) => {
        this.exportForm.patchValue({ id_parcela: null }, { emitEvent: false });
        this.cargarParcelasPorComunero(idComunero);
      });
  }

  buscarComunero(term: string) {
    this.cargarComuneros(term || '');
  }

  private cargarComuneros(search: string) {
    this.comunerosService.findAll(1, 50, search).subscribe({
      next: (res: any) => this.comuneros.set(res.data?.data || res.data || []),
    });
  }

  private cargarParcelasPorComunero(idComunero: number | null) {
    if (!idComunero) {
      this.parcelasExport.set([]);
      return;
    }
    this.parcelasService.findAll(1, 200, '', idComunero).subscribe({
      next: (res: any) => {
        const lista = (res.data?.data || res.data || []).map((p: any) => ({
          ...p,
          etiqueta: `${p.denominacion || 'PARCELA #' + p.id_parcela} — ${p.hectareas ?? '—'} ha`,
        }));
        this.parcelasExport.set(lista);
      },
    });
  }

  onSearch(term: string) { this.crud.searchControl.setValue(term); }

  abrirModal(modalTemplate: TemplateRef<any>, item?: any) {
    if (document.activeElement instanceof HTMLElement) document.activeElement.blur();
    this.crud.setupModal(item?.id_certificado ?? null);
    this.form.reset();
    if (item) {
      this.form.patchValue({
        id_comunero: item.id_comunero,
        id_parcela: item.id_parcela,
        fecha_emision: item.fecha_emision,
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
    this.crud.save(data);
  }

  eliminar(item: any) {
    this.crud.deleteItem(item.id_certificado, '¿Eliminar certificado de posesión?', 'Se perderá el registro.');
  }

  exportarPdf(item?: { id_comunero: number; id_parcela: number; fecha_emision?: string | null; dni?: string }) {
    const raw = item
      ? { id_comunero: item.id_comunero, id_parcela: item.id_parcela, fecha_emision: item.fecha_emision }
      : this.exportForm.getRawValue();

    if (!raw.id_comunero || !raw.id_parcela) {
      if (!item) this.exportForm.markAllAsTouched();
      this.alert.error('Seleccione comunero y parcela para exportar el certificado.');
      return;
    }

    this.exportandoPdf.set(true);
    this.service.exportarPdf(raw.id_comunero, raw.id_parcela, raw.fecha_emision).subscribe({
      next: (blob) => {
        const dni = item?.dni ? String(item.dni).replace(/[^a-zA-Z0-9_\-.]/g, '_') : raw.id_comunero;
        saveAs(blob, `Certificado_Posesion_${dni}.pdf`);
        this.exportandoPdf.set(false);
      },
      error: () => {
        this.exportandoPdf.set(false);
        this.alert.error('No se pudo generar el PDF del certificado.');
      },
    });
  }
}
