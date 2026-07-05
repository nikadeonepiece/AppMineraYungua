import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { Sidebar } from '../sidebar/sidebar';
import { SettingsPanel } from '../settings-panel/settings-panel';
import { ToastComponent } from '../../components/toast/toast';
import { LayoutService } from '../../services/layout.service';
import { PermissionsService } from '../../services/seguridad/permissions.service';

@Component({
  selector: 'app-admin-layout',
  standalone: true,
  imports: [CommonModule, RouterModule, Sidebar, SettingsPanel, ToastComponent],
  templateUrl: './admin-layout.html',
  styleUrls: ['./admin-layout.scss']
})
export class AdminLayout implements OnInit {
  public layoutService = inject(LayoutService);
  private permissionsService = inject(PermissionsService);

  ngOnInit() {
    this.layoutService.showLoader();

    if (this.permissionsService.permissionsSignal().length > 0) {
      this.layoutService.hideLoader();
      return;
    }

    this.permissionsService.loadPermissions().subscribe({
      next:  () => this.layoutService.hideLoader(),
      error: () => this.layoutService.hideLoader(),
    });
  }
}