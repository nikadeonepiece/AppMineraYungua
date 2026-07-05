import { Routes } from '@angular/router';
import { authGuard } from './core/guards/auth-guard';
import { permissionGuard } from './core/guards/permission.guard';
import { AdminLayout } from './core/layouts/admin-layout/admin-layout';

export const routes: Routes = [

  // ==========================================
  // AUTENTICACIÓN — Login del ERP (sin layout)
  // ==========================================
  {
    path: 'auth/login',
    loadComponent: () => import('./features/auth/login/login').then(m => m.Login)
  },

  // ==========================================
  // ZONA PRIVADA — App Minera Yungua (requiere login)
  // ==========================================
  {
    path: '',
    component: AdminLayout,
    canActivate: [authGuard],
    children: [
      { path: '', redirectTo: 'dashboard', pathMatch: 'full' },

      { path: 'dashboard', loadComponent: () => import('./features/dashboard/dashboard.component').then(m => m.DashboardComponent), canActivate: [permissionGuard], data: { permiso: 'ver_dashboard' } },
      { path: 'admin/seguridad/permisos', loadComponent: () => import('./features/permisos/permisos.component').then(m => m.PermisosComponent), canActivate: [permissionGuard], data: { permiso: 'ver_seguridad' } },
      { path: 'admin/usuarios', loadComponent: () => import('./features/usuarios/usuarios.component').then(m => m.UsuariosComponent), canActivate: [permissionGuard], data: { permiso: 'ver_usuario' } },
      { path: 'personal', loadComponent: () => import('./features/personal/personal-page.component').then(m => m.PersonalPageComponent), canActivate: [permissionGuard], data: { permiso: 'ver_personal' } },
      { path: 'comuneros', loadComponent: () => import('./features/comuneros/comuneros-page.component').then(m => m.ComunerosPageComponent), canActivate: [permissionGuard], data: { permiso: 'ver_comunero' } },
      { path: 'comuneros/asambleas', loadComponent: () => import('./features/comuneros/asambleas/asambleas.component').then(m => m.AsambleasComponent), canActivate: [permissionGuard], data: { permiso: 'ver_asamblea' } },
      { path: 'comuneros/asistencia-asambleas', loadComponent: () => import('./features/comuneros/asistencia-asambleas/asistencia-asambleas.component').then(m => m.AsistenciaAsambleasComponent), canActivate: [permissionGuard], data: { permiso: 'ver_asamblea' } },

    ]
  },

  { path: '**', redirectTo: '' }
];