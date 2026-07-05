import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { environment } from 'src/environments/environment';
import { Observable } from 'rxjs';

@Injectable({ providedIn: 'root' })
export class AsambleasService {
  private http = inject(HttpClient);
  private apiUrl = `${environment.apiUrlGestion}/comuneros/asambleas`;

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

  findAsistencia(idAsamblea: number): Observable<any> {
    return this.http.get(`${this.apiUrl}/${idAsamblea}/asistencia`);
  }

  findComuneros(idAsamblea: number): Observable<any> {
    return this.http.get(`${this.apiUrl}/${idAsamblea}/comuneros`);
  }

  marcarAsistencia(idAsamblea: number, data: any): Observable<any> {
    return this.http.post(`${this.apiUrl}/${idAsamblea}/asistencia`, data);
  }

  quitarAsistencia(idAsamblea: number, idAsistencia: number): Observable<any> {
    return this.http.delete(`${this.apiUrl}/${idAsamblea}/asistencia/${idAsistencia}`);
  }
}
