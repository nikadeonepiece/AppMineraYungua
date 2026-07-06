import {
  Component, inject, OnInit, AfterViewInit, ChangeDetectionStrategy,
  ChangeDetectorRef, signal, computed, DestroyRef,
} from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule } from '@angular/forms';
import { NgSelectModule } from '@ng-select/ng-select';
import { NgbPaginationModule } from '@ng-bootstrap/ng-bootstrap';
import { debounceTime, distinctUntilChanged, Subject } from 'rxjs';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { saveAs } from 'file-saver';

import { PermissionsService } from 'src/app/core/services/seguridad/permissions.service';
import { AlertService } from 'src/app/core/services/ui/alert.service';
import { CaseriosService } from '../caserios/caserios.service';
import { FotocheckService } from './fotocheck.service';

@Component({
  selector: 'app-fotocheck',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, NgSelectModule, NgbPaginationModule],
  templateUrl: './fotocheck.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class FotocheckComponent implements OnInit, AfterViewInit {
  private fb = inject(FormBuilder);
  private caseriosService = inject(CaseriosService);
  private fotocheckService = inject(FotocheckService);
  private alert = inject(AlertService);
  private cdr = inject(ChangeDetectorRef);
  private destroyRef = inject(DestroyRef);
  public perms = inject(PermissionsService);

  caserios = signal<any[]>([]);
  comuneros = signal<any[]>([]);
  comunerosLista = signal<any[]>([]);
  meta = signal({ total: 0, page: 1, limit: 20 });
  loading = signal(false);
  loadingLista = signal(false);
  generandoPdf = signal(false);
  listasListas = signal(false);

  private busquedaLista$ = new Subject<string>();

  filtroForm: FormGroup = this.fb.group({
    id_caserio: [null as number | null],
    id_comunero_filtro: [null as number | null],
  });

  /** ng-select filtra en cliente por bindLabel; la búsqueda real es en el servidor (DNI o nombre). */
  sinFiltroLocal = (): boolean => true;

  seleccionados = signal<Set<number>>(new Set());
  idCaserioSeleccionado = signal<number | null>(null);

  caserioActivo = computed(() => {
    const id = this.idCaserioSeleccionado();
    return this.caserios().find((c) => c.id_caserio === id) || null;
  });

  cantidadSeleccionados = computed(() => this.seleccionados().size);
  puedeAgregarMas = computed(() => this.cantidadSeleccionados() < 9);

  haySeleccionEnPagina = computed(() =>
    this.comuneros().some((i) => this.seleccionados().has(i.id_comunero)),
  );

  ngOnInit() {
    this.caseriosService.findAll(1, 300, '').subscribe({
      next: (res: any) => {
        this.caserios.set(res.data?.data || res.data || []);
        this.cdr.markForCheck();
      },
    });

    this.filtroForm.get('id_caserio')?.valueChanges
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe((id) => {
        this.idCaserioSeleccionado.set(id);
        this.filtroForm.patchValue({ id_comunero_filtro: null }, { emitEvent: false });
        this.seleccionados.set(new Set());
        this.comuneros.set([]);
        this.comunerosLista.set([]);
        this.meta.update((m) => ({ ...m, total: 0, page: 1 }));
        if (id) {
          this.cargarComuneros();
          this.cargarComunerosLista('');
        }
        this.cdr.markForCheck();
      });

    this.filtroForm.get('id_comunero_filtro')?.valueChanges
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe((id) => {
        if (!id) return;
        const item = this.comuneros().find((c) => c.id_comunero === id)
          ?? this.comunerosLista().find((c) => c.id_comunero === id);
        if (item) this.toggleSeleccion(item);
        this.filtroForm.patchValue({ id_comunero_filtro: null }, { emitEvent: false });
        this.cdr.markForCheck();
      });

    this.busquedaLista$.pipe(
      debounceTime(300),
      distinctUntilChanged(),
      takeUntilDestroyed(this.destroyRef),
    ).subscribe((term) => {
      if (this.idCaserioSeleccionado()) this.cargarComunerosLista(term);
    });
  }

  ngAfterViewInit() {
    requestAnimationFrame(() => {
      this.listasListas.set(true);
      this.cdr.markForCheck();
    });
  }

  buscarComunero(term: string) {
    if (!term?.trim()) {
      this.cargarComunerosLista('');
      return;
    }
    this.busquedaLista$.next(term);
  }

  cargarComuneros() {
    const idCaserio = this.idCaserioSeleccionado();
    if (!idCaserio) return;

    this.loading.set(true);
    const { page, limit } = this.meta();
    this.fotocheckService.findComuneros(idCaserio, page, limit, '').subscribe({
      next: (res: any) => {
        const payload = res.data ?? res;
        const rows = Array.isArray(payload) ? payload : (payload.data || []);
        const meta = Array.isArray(payload)
          ? { total: rows.length, page, limit }
          : (payload.meta || { total: rows.length, page, limit });
        this.comuneros.set(rows);
        this.meta.set(meta);
        this.loading.set(false);
        this.cdr.markForCheck();
      },
      error: () => {
        this.comuneros.set([]);
        this.meta.update((m) => ({ ...m, total: 0 }));
        this.loading.set(false);
        this.cdr.markForCheck();
      },
    });
  }

  cargarComunerosLista(search: string) {
    const idCaserio = this.idCaserioSeleccionado();
    if (!idCaserio) return;

    this.loadingLista.set(true);
    this.fotocheckService.findComuneros(idCaserio, 1, 50, search).subscribe({
      next: (res: any) => {
        const payload = res.data ?? res;
        const rows = Array.isArray(payload) ? payload : (payload.data || []);
        this.comunerosLista.set(rows);
        this.loadingLista.set(false);
        this.cdr.markForCheck();
      },
      error: () => {
        this.comunerosLista.set([]);
        this.loadingLista.set(false);
        this.cdr.markForCheck();
      },
    });
  }

  cambiarPagina(page: number) {
    this.meta.update((m) => ({ ...m, page }));
    this.cargarComuneros();
  }

  estaSeleccionado(id: number): boolean {
    return this.seleccionados().has(id);
  }

  toggleSeleccion(item: any) {
    const id = Number(item.id_comunero);
    const next = new Set(this.seleccionados());
    if (next.has(id)) {
      next.delete(id);
    } else {
      if (next.size >= 9) {
        this.alert.error('Solo puede seleccionar hasta 9 comuneros por hoja.');
        return;
      }
      next.add(id);
    }
    this.seleccionados.set(next);
  }

  limpiarSeleccion() {
    this.seleccionados.set(new Set());
  }

  toggleSeleccionarPagina() {
    const items = this.comuneros();
    const next = new Set(this.seleccionados());
    const hayEnPagina = items.some((i) => next.has(i.id_comunero));

    if (hayEnPagina) {
      items.forEach((i) => next.delete(i.id_comunero));
    } else {
      for (const item of items) {
        if (next.size >= 9) {
          this.alert.error('Solo puede seleccionar hasta 9 comuneros por hoja.');
          break;
        }
        next.add(item.id_comunero);
      }
    }
    this.seleccionados.set(next);
  }

  private async extraerMensajeError(err: any, fallback: string): Promise<string> {
    const blob = err?.error;
    if (blob instanceof Blob) {
      try {
        const json = JSON.parse(await blob.text());
        if (Array.isArray(json?.message)) return json.message.join(', ');
        return json?.message || fallback;
      } catch {
        return fallback;
      }
    }
    if (typeof err?.error?.message === 'string') return err.error.message;
    return fallback;
  }

  private descargarBlob(blob: Blob, nombre: string, abrirPreview = false) {
    if (abrirPreview) {
      const url = URL.createObjectURL(blob);
      window.open(url, '_blank');
      setTimeout(() => URL.revokeObjectURL(url), 60_000);
      return;
    }
    saveAs(blob, nombre);
  }

  generarPdfSeleccion(preview = false) {
    const idCaserio = this.idCaserioSeleccionado();
    const ids = [...this.seleccionados()];
    if (!idCaserio) {
      this.alert.error('Seleccione un caserío.');
      return;
    }
    if (ids.length === 0) {
      this.alert.error('Seleccione entre 1 y 9 comuneros.');
      return;
    }

    this.generandoPdf.set(true);
    this.fotocheckService.exportarPdf(idCaserio, ids).subscribe({
      next: (blob) => {
        const slug = (this.caserioActivo()?.nombre || 'caserio').replace(/[^a-zA-Z0-9_\-.]/g, '_');
        this.descargarBlob(blob, `Fotocheck_${slug}_seleccion.pdf`, preview);
        this.generandoPdf.set(false);
        this.cdr.markForCheck();
      },
      error: async (err) => {
        this.generandoPdf.set(false);
        const msg = await this.extraerMensajeError(err, 'No se pudo generar el PDF de fotocheck.');
        this.alert.error(msg);
        this.cdr.markForCheck();
      },
    });
  }

  async generarPdfCaserioCompleto(preview = false) {
    const idCaserio = this.idCaserioSeleccionado();
    if (!idCaserio) {
      this.alert.error('Seleccione un caserío.');
      return;
    }

    const total = this.meta().total;
    if (total > 9 && !preview) {
      const ok = await this.alert.confirmAction(
        'Generar fotocheck del caserío completo',
        `Se generará un PDF con ${total} comuneros (${Math.ceil(total / 9)} hojas). Puede tardar varios minutos. ¿Continuar?`,
        'Sí, generar',
      );
      if (!ok) return;
    }

    this.generandoPdf.set(true);
    this.fotocheckService.exportarPdf(idCaserio).subscribe({
      next: (blob) => {
        const slug = (this.caserioActivo()?.nombre || 'caserio').replace(/[^a-zA-Z0-9_\-.]/g, '_');
        this.descargarBlob(blob, `Fotocheck_${slug}_completo.pdf`, preview);
        this.generandoPdf.set(false);
        this.cdr.markForCheck();
      },
      error: async (err) => {
        this.generandoPdf.set(false);
        const msg = await this.extraerMensajeError(err, 'No se pudo generar el PDF del caserío.');
        this.alert.error(msg);
        this.cdr.markForCheck();
      },
    });
  }
}
