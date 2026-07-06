import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { environment } from 'src/environments/environment';
import { Observable } from 'rxjs';

@Injectable({ providedIn: 'root' })
export class FotocheckService {
  private http = inject(HttpClient);
  private apiUrl = `${environment.apiUrlGestion}/comuneros/fotocheck`;

  findComuneros(idCaserio: number, page: number, limit: number, search: string): Observable<any> {
    let params = new HttpParams()
      .set('id_caserio', idCaserio)
      .set('page', page)
      .set('limit', limit);
    if (search) params = params.set('search', search);
    return this.http.get(`${this.apiUrl}/comuneros`, { params });
  }

  exportarPdf(idCaserio: number, ids?: number[]): Observable<Blob> {
    let params = new HttpParams().set('id_caserio', idCaserio);
    if (ids?.length) params = params.set('ids', ids.join(','));
    return this.http.get(`${this.apiUrl}/pdf`, { params, responseType: 'blob' });
  }
}
