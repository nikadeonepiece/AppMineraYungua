import { Component, OnInit, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { NgSelectModule } from '@ng-select/ng-select';
import { PermisosService } from './permisos.service';
import { LayoutService } from 'src/app/core/services/layout.service';
import { AlertService } from 'src/app/core/services/ui/alert.service';
// Importamos el servicio global de permisos para actualizar el Sidebar reactivamente
import { PermissionsService as GlobalPermissionsService } from 'src/app/core/services/seguridad/permissions.service';

@Component({
  selector: 'app-permisos',
  standalone: true,
  imports: [CommonModule, FormsModule, NgSelectModule],
  templateUrl: './permisos.component.html'
})
export class PermisosComponent implements OnInit {
  private permisosService = inject(PermisosService);
  private globalPerms = inject(GlobalPermissionsService); // Inyectamos el servicio global
  private layout = inject(LayoutService);
  private alert = inject(AlertService);

  roles = signal<any[]>([]);
  modulos = signal<any[]>([]);
  
  // Rol seleccionado
  rolSeleccionado = signal<number | null>(null);
  
  // Array donde guardamos los IDs de las acciones marcadas
  accionesMarcadas = signal<number[]>([]);

  ngOnInit() {
    this.cargarDatosBase();
  }

  cargarDatosBase() {
    this.layout.showLoader();
    
    // 1. Cargar roles asegurando extraer el arreglo correcto
    this.permisosService.getRoles().subscribe({
      next: (res) => {
        const listaRoles = res.data?.data || res.data || [];
        this.roles.set(listaRoles);
      },
      error: () => this.roles.set([])
    });

    // 2. Cargar matriz asegurando extraer el arreglo correcto
    this.permisosService.getMatriz().subscribe({
      next: (res) => {
        const listaModulos = res.data?.data || res.data || [];
        this.modulos.set(listaModulos);
        this.layout.hideLoader();
      },
      error: () => {
        this.modulos.set([]);
        this.layout.hideLoader();
      }
    });
  }

  onRolChange(event: any) {
    const idRol = event ? event.id_rol : null;
    this.rolSeleccionado.set(idRol);
    
    if (!idRol) {
      this.accionesMarcadas.set([]);
      return;
    }
    
    this.layout.showLoader();
    this.permisosService.getPermisosRol(idRol).subscribe({
      next: (res) => {
        const ids = res.data?.data || res.data || [];
        this.accionesMarcadas.set(ids); 
        this.layout.hideLoader();
      },
      error: () => {
        this.accionesMarcadas.set([]);
        this.layout.hideLoader();
      }
    });
  }

  toggleAccion(idAccion: number, isChecked: boolean) {
    const actuales = [...this.accionesMarcadas()];
    if (isChecked) {
      actuales.push(idAccion);
    } else {
      const index = actuales.indexOf(idAccion);
      if (index > -1) actuales.splice(index, 1);
    }
    this.accionesMarcadas.set(actuales);
  }

  isMarcado(idAccion: number): boolean {
    return this.accionesMarcadas().includes(idAccion);
  }

  guardarMatriz() {
    if (!this.rolSeleccionado()) return;
    
    this.layout.showLoader();
    this.permisosService.savePermisos(this.rolSeleccionado()!, this.accionesMarcadas()).subscribe({
      next: (res) => {
        this.layout.hideLoader();
        this.alert.success(res.message);
        
        const user = JSON.parse(localStorage.getItem('usuario') || '{}');
        if (user.id_rol === this.rolSeleccionado()) {
            // 🔥 MAGIA REACTIVA: Actualizamos el menú sin recargar la página
            this.globalPerms.loadPermissions().subscribe();
        }
      },
      error: (err) => {
        this.layout.hideLoader();
        this.alert.error('Error al guardar los permisos');
      }
    });
  }
}