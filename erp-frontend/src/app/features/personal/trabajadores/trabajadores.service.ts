import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { environment } from 'src/environments/environment';
import { Observable } from 'rxjs';

@Injectable({ providedIn: 'root' })
export class TrabajadoresService {
  private http = inject(HttpClient);
  private apiUrl = `${environment.apiUrlGestion}/personal`;

  findAll(page: number, limit: number, search: string): Observable<any> {
    let params = new HttpParams().set('page', page).set('limit', limit);
    if (search) params = params.set('search', search);
    return this.http.get(this.apiUrl, { params });
  }

  findOne(id: number): Observable<any> {
    return this.http.get(`${this.apiUrl}/${id}`);
  }

  buscarComuneros(search: string, idPersonalActual?: number, idComuneroActual?: number): Observable<any> {
    let params = new HttpParams().set('search', search || '');
    if (idPersonalActual) params = params.set('id_personal_actual', idPersonalActual);
    if (idComuneroActual) params = params.set('id_comunero_actual', idComuneroActual);
    return this.http.get(`${this.apiUrl}/buscar-comunero`, { params });
  }

  create(data: any): Observable<any> {
    return this.http.post(this.apiUrl, data);
  }

  update(id: number, data: any): Observable<any> {
    return this.http.put(`${this.apiUrl}/${id}`, data);
  }

  delete(id: number): Observable<any> {
    return this.http.delete(`${this.apiUrl}/${id}`);
  }

  uploadFoto(id: number, file: File): Observable<any> {
    const form = new FormData();
    form.append('foto', file);
    return this.http.post(`${this.apiUrl}/${id}/foto`, form);
  }

  uploadFirma(id: number, file: File): Observable<any> {
    const form = new FormData();
    form.append('firma', file);
    return this.http.post(`${this.apiUrl}/${id}/firma`, form);
  }
}
