import { Component, inject, computed, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, RouterModule } from '@angular/router';
import { FormControl, ReactiveFormsModule } from '@angular/forms';
import { toSignal } from '@angular/core/rxjs-interop';

import { LayoutService } from '../../services/layout.service';
import { PermissionsService } from '../../services/seguridad/permissions.service';
import { AuthService } from '../../services/auth.service';
import { AlertService } from '../../services/ui/alert.service';

@Component({
  selector: 'app-sidebar',
  standalone: true,
  imports: [CommonModule, RouterModule, ReactiveFormsModule],
  templateUrl: './sidebar.html',
  styleUrls: ['./sidebar.scss'],
  host: {
    '[class.closed]': '!isSidebarOpen()'
  }
})
export class Sidebar implements OnInit {
  layoutService = inject(LayoutService);
  perms = inject(PermissionsService);
  private authService = inject(AuthService);
  private alert = inject(AlertService);
  private router = inject(Router);

  searchControl = new FormControl('');
  searchTerm = toSignal(this.searchControl.valueChanges, { initialValue: '' });
  isSidebarOpen = this.layoutService.sidebarOpen;

  usuarioActual: any = null;

  private rawMenu: any[] = [
    {
      label: 'Dashboard', icon: 'bi-speedometer2',
      route: '/dashboard', type: 'link', permiso: 'ver_dashboard'
    },

    { label: 'ADMINISTRACIÓN', type: 'header' },

    {
      label: 'Usuarios', icon: 'bi-people-fill',
      route: '/admin/usuarios', type: 'link', permiso: 'ver_usuario'
    },
    {
      label: 'Permisos', icon: 'bi-shield-lock-fill',
      route: '/admin/seguridad/permisos', type: 'link', permiso: 'ver_seguridad'
    },

    // MÓDULO: COMUNEROS (pendiente de construir)
  ];

  ngOnInit() {
    const userStr = localStorage.getItem('usuario');
    if (userStr) {
      try {
        this.usuarioActual = JSON.parse(userStr);
      } catch {
        // silencioso: si localStorage tiene datos corruptos, sidebar carga sin usuario
      }
    }
  }

  filteredMenu = computed(() => {
    const text = (this.searchTerm() || '').toLowerCase();
    const isSearching = text.length > 0;
    const permsLoaded = this.perms.permissionsSignal().length > 0;

    const result = this.rawMenu.map(item => {
      if (permsLoaded && item.type !== 'header' && item.permiso) {
        const tienePermiso = Array.isArray(item.permiso)
          ? item.permiso.some((p: string) => this.perms.hasPermission(p))
          : this.perms.hasPermission(item.permiso as string);
        if (!tienePermiso) return null;
      }

      if (!isSearching) {
        const cleanItem = JSON.parse(JSON.stringify(item));
        if (cleanItem.type === 'dropdown' && cleanItem.children) {
          cleanItem.children = cleanItem.children.filter((sub: any) =>
            sub.type === 'subheader' || !permsLoaded || !sub.permiso || this.perms.hasPermission(sub.permiso)
          );
          cleanItem.children = this.cleanOrphanSubheaders(cleanItem.children);
          if (cleanItem.children.filter((s: any) => s.type !== 'subheader').length === 0) return null;
          cleanItem.active = this.hasActiveChild(cleanItem);
        }
        return cleanItem;
      }

      if (item.type === 'header') return item;
      if (item.type === 'link') return item.label.toLowerCase().includes(text) ? item : null;

      if (item.type === 'dropdown') {
        const matchingChildren = item.children?.filter((sub: any) =>
          sub.type !== 'subheader' && sub.label.toLowerCase().includes(text) && (!sub.permiso || this.perms.hasPermission(sub.permiso))
        );
        if (matchingChildren && matchingChildren.length > 0) return { ...item, children: matchingChildren, active: true };
        else if (item.label.toLowerCase().includes(text)) {
          const permitidos = item.children?.filter((sub: any) => sub.type !== 'subheader' && (!sub.permiso || this.perms.hasPermission(sub.permiso)));
          if (permitidos && permitidos.length > 0) return { ...item, children: permitidos, active: true };
          return null;
        }
      }
      return null;
    }).filter(x => x !== null);

    return this.cleanEmptyHeaders(result);
  });

  toggleSubmenu(item: any) { item.active = !item.active; }

  isChildActive(item: any): boolean {
    if (!item.children) return false;
    return item.children.some((sub: any) => sub.route && this.router.isActive(sub.route, false));
  }

  checkMobileClose() {
    if (window.innerWidth < 992) {
      this.layoutService.sidebarOpen.set(false);
    }
  }

  private hasActiveChild(item: any): boolean {
    if (!item.children) return false;
    return item.children.some((sub: any) => sub.route && this.router.isActive(sub.route, false));
  }

  private cleanOrphanSubheaders(children: any[]): any[] {
    return children.filter((child, index, arr) => {
      if (child.type !== 'subheader') return true;
      for (let i = index + 1; i < arr.length; i++) {
        if (arr[i].type !== 'subheader') return true;
      }
      return false;
    });
  }

  private cleanEmptyHeaders(menu: any[]) {
    return menu.filter((item, index, arr) => {
      if (item.type === 'header') {
        const next = arr[index + 1];
        if (!next || next.type === 'header') return false;
      }
      return true;
    });
  }

  logout() {
    this.alert.confirmAction('¿Cerrar Sesión?', 'Saldrás del sistema.', 'Sí, salir')
      .then((ok) => { if (ok) this.authService.logout(); });
  }
}
