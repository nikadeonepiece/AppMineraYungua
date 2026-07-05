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
  public perms = inject(PermissionsService);

  public crud = useCrud<any>(this.service as any, { itemName: 'Certificado de posesión' });

  comuneros = signal<any[]>([]);
  parcelas = signal<any[]>([]);

  form: FormGroup = this.fb.group({
    id_comunero: [null, Validators.required],
    id_parcela: [null, Validators.required],
    fecha_emision: [null],
  });

  ngOnInit() {
    this.comunerosService.findAll(1, 500, '').subscribe({
      next: (res: any) => this.comuneros.set(res.data?.data || res.data || []),
    });
    this.parcelasService.findAll(1, 500, '').subscribe({
      next: (res: any) => {
        const lista = (res.data?.data || res.data || []).map((p: any) => ({
          ...p,
          etiqueta: `${p.denominacion || 'PARCELA #' + p.id_parcela} — ${p.nombre_comunero}`,
        }));
        this.parcelas.set(lista);
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
}
