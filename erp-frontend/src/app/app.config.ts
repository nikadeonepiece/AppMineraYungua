import { ApplicationConfig, provideAppInitializer, inject, ErrorHandler } from '@angular/core'; 
import { provideRouter } from '@angular/router';
import { provideHttpClient, withFetch, withInterceptors } from '@angular/common/http';
import { firstValueFrom, catchError, of } from 'rxjs';
import { provideCharts, withDefaultRegisterables } from 'ng2-charts';

import { routes } from './app.routes';
import { authInterceptor } from './core/interceptors/auth/auth-interceptor';
import { errorInterceptor } from './core/interceptors/error.interceptor';

// 🔥 Rutas relativas correctas
import { PermissionsService } from './core/services/seguridad/permissions.service';
import { AuthService } from './core/services/auth.service';
import { GlobalErrorHandler } from './core/interceptors/global-error-handler'; 

export const appConfig: ApplicationConfig = {
  providers: [
    provideRouter(routes),
    provideCharts(withDefaultRegisterables()),
    provideHttpClient(
        withFetch(), 
        withInterceptors([authInterceptor, errorInterceptor])
    ),

    // AQUÍ INYECTAMOS EL ATRAPADOR DE ERRORES GLOBAL
    { provide: ErrorHandler, useClass: GlobalErrorHandler },
    
    // LA FORMA MODERNA DE ANGULAR (Reemplaza a APP_INITIALIZER)
    provideAppInitializer(() => {
      const authService = inject(AuthService);
      const permsService = inject(PermissionsService);
      
      // Solo cargamos permisos al inicio si hay un token guardado (sesión activa)
      if (authService.isLoggedIn()) {
        return firstValueFrom(permsService.loadPermissions().pipe(
          catchError(() => {
            // Si el servidor falla al cargar permisos, limpiamos por seguridad
            permsService.clear();
            return of(null);
          })
        ));
      }
      
      // Si no está logueado, dejamos que inicie rápido para mostrar el Login
      return Promise.resolve();
    })
  ]
};