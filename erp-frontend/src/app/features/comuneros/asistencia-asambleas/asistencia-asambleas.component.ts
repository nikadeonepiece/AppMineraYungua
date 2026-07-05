import { Component, inject, OnInit, TemplateRef, ChangeDetectionStrategy, signal, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { NgbModal, NgbModalModule } from '@ng-bootstrap/ng-bootstrap';
import { NgSelectModule } from '@ng-select/ng-select';
import { startWith } from 'rxjs';
import { toSignal } from '@angular/core/rxjs-interop';

import { useCrud } from 'src/app/core/utils/crud.util';
import { TableProComponent } from 'src/app/shared/components/table-pro/table-pro.component';
import { StatusBadgeComponent } from 'src/app/shared/components/status-badge/status-badge.component';
import { PermissionsService } from 'src/app/core/services/seguridad/permissions.service';
import { AlertService } from 'src/app/core/services/ui/alert.service';
import { AsambleasService } from '../asambleas/asambleas.service';
import { ComunerosService } from '../comuneros/comuneros.service';

@Component({
  selector: 'app-asistencia-asambleas',
  standalone: true,
  imports: [
    CommonModule, ReactiveFormsModule, TableProComponent, StatusBadgeComponent, NgbModalModule, NgSelectModule,
  ],
  templateUrl: './asistencia-asambleas.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class AsistenciaAsambleasComponent implements OnInit {
  private fb = inject(FormBuilder);
  private service = inject(AsambleasService);
  private comunerosService = inject(ComunerosService);
  private modalService = inject(NgbModal);
  private alert = inject(AlertService);
  public perms = inject(PermissionsService);

  public crud = useCrud<any>(this.service as any, { itemName: 'Asamblea' });

  comuneros = signal<any[]>([]);
  comunerosElegibles = signal<any[]>([]);
  mostrarTodos = signal(false);
  asambleaActiva = signal<any | null>(null);
  asistencia = signal<any[]>([]);
  guardandoAsistencia = signal(false);
  private modalRef: any = null;

  asistenciaForm: FormGroup = this.fb.group({
    id_comunero: [null, Validators.required],
    firmo: [true],
    metodo: ['MANUAL'],
    observaciones: [''],
  });

  private idComuneroSeleccionado = toSignal(
    this.asistenciaForm.get('id_comunero')!.valueChanges.pipe(startWith(this.asistenciaForm.get('id_comunero')!.value)),
    { initialValue: null },
  );

  opcionesComunero = computed(() => this.mostrarTodos() ? this.comuneros() : this.comunerosElegibles());

  comuneroFueraDeAlcance = computed(() => {
    const idComunero = this.idComuneroSeleccionado();
    if (!idComunero) return false;
    return !this.comunerosElegibles().some((c) => Number(c.id_comunero) === Number(idComunero));
  });

  ngOnInit() {
    this.comunerosService.findAll(1, 500, '').subscribe({
      next: (res: any) => this.comuneros.set(res.data?.data || res.data || []),
    });
  }

  onSearch(term: string) { this.crud.searchControl.setValue(term); }

  abrirModalAsistencia(modalTemplate: TemplateRef<any>, item: any) {
    if (document.activeElement instanceof HTMLElement) document.activeElement.blur();
    this.asambleaActiva.set(item);
    this.mostrarTodos.set(false);
    this.asistenciaForm.reset({ firmo: true, metodo: 'MANUAL' });
    this.asistencia.set([]);
    this.comunerosElegibles.set([]);
    this.cargarAsistencia(item.id_asamblea);
    this.cargarComunerosElegibles(item.id_asamblea);
    this.modalRef = this.modalService.open(modalTemplate, { centered: true, backdrop: 'static', size: 'lg' });
  }

  cargarAsistencia(idAsamblea: number) {
    this.service.findAsistencia(idAsamblea).subscribe({
      next: (res: any) => this.asistencia.set(res.data || res || []),
    });
  }

  cargarComunerosElegibles(idAsamblea: number) {
    this.service.findComuneros(idAsamblea).subscribe({
      next: (res: any) => this.comunerosElegibles.set(res.data || res || []),
    });
  }

  marcarAsistencia() {
    if (this.asistenciaForm.invalid) { this.asistenciaForm.markAllAsTouched(); return; }
    const idAsamblea = this.asambleaActiva()?.id_asamblea;
    if (!idAsamblea) return;

    this.guardandoAsistencia.set(true);
    this.service.marcarAsistencia(idAsamblea, this.asistenciaForm.getRawValue()).subscribe({
      next: () => {
        this.guardandoAsistencia.set(false);
        this.asistenciaForm.reset({ firmo: true, metodo: 'MANUAL' });
        this.cargarAsistencia(idAsamblea);
      },
      error: () => this.guardandoAsistencia.set(false),
    });
  }

  async quitarAsistencia(registro: any) {
    const idAsamblea = this.asambleaActiva()?.id_asamblea;
    if (!idAsamblea) return;
    if (!await this.alert.confirmDelete('¿Quitar asistencia?', 'Se eliminará el registro de asistencia de este comunero.')) return;

    this.service.quitarAsistencia(idAsamblea, registro.id_asistencia).subscribe({
      next: () => {
        this.alert.success('Asistencia eliminada correctamente');
        this.cargarAsistencia(idAsamblea);
      },
    });
  }
}
