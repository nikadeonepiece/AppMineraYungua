import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { environment } from 'src/environments/environment';
import { Observable } from 'rxjs';

@Injectable({ providedIn: 'root' })
export class DashboardService {
  private http = inject(HttpClient);
  private apiUrl = `${environment.apiUrlGestion}/dashboard`;

  resumenComuneros(): Observable<any> {
    return this.http.get(`${this.apiUrl}/resumen-comuneros`);
  }
}
