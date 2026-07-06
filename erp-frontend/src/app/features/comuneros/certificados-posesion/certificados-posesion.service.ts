import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { environment } from 'src/environments/environment';
import { Observable } from 'rxjs';

@Injectable({ providedIn: 'root' })
export class CertificadosPosesionService {
  private http = inject(HttpClient);
  private apiUrl = `${environment.apiUrlGestion}/comuneros/certificados-posesion`;

  findAll(page: number, limit: number, search: string): Observable<any> {
    let params = new HttpParams().set('page', page).set('limit', limit);
    if (search) params = params.set('search', search);
    return this.http.get(this.apiUrl, { params });
  }

  findOne(id: number): Observable<any> {
    return this.http.get(`${this.apiUrl}/${id}`);
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

  exportarPdf(idComunero: number, idParcela: number, fechaEmision?: string | null): Observable<Blob> {
    let params = new HttpParams()
      .set('id_comunero', idComunero)
      .set('id_parcela', idParcela);
    if (fechaEmision) params = params.set('fecha_emision', fechaEmision);
    return this.http.get(`${this.apiUrl}/pdf`, { params, responseType: 'blob' });
  }
}
