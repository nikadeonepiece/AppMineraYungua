import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from 'src/environments/environment';

@Injectable({
  providedIn: 'root'
})
export class PermisosService {
  private http = inject(HttpClient);

  private apiUrl = `${environment.apiUrlGestion}/seguridad`;

  constructor() {}

  getRoles(): Observable<any> {
    return this.http.get<any>(`${this.apiUrl}/roles`);
  }

  getMatriz(): Observable<any> {
    return this.http.get<any>(`${this.apiUrl}/matriz`);
  }

  getPermisosRol(idRol: number): Observable<any> {
    return this.http.get<any>(`${this.apiUrl}/roles/${idRol}/permisos-ids`);
  }

  savePermisos(idRol: number, accionesIds: number[]): Observable<any> {
    return this.http.post<any>(`${this.apiUrl}/roles/${idRol}/permisos`, { accionesIds });
  }
}
