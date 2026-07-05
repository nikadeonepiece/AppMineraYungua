import { Module } from '@nestjs/common';
import { DatabaseModule } from '@app/database';
import { SecurityModule } from '@app/security';
import { AuditoriaModule } from '@app/common';
import { AuthModule as SharedAuthModule } from '@app/auth';

import { ApiController } from './api.controller';
import { ApiService } from './api.service';

// --- Módulos Core (base sólida y reutilizable) ---
import { SeguridadModule } from './core/seguridad/seguridad.module';
import { UsuariosModule } from './core/usuarios/usuarios.module';
import { MailModule } from './core/mail/mail.module';
import { AuthModule as LocalAuthModule } from './core/auth/auth.module';

// --- Módulos ERP ---
import { DashboardModule } from './erp/dashboard/dashboard.module';

@Module({
  imports: [
    DatabaseModule,
    SharedAuthModule,
    SecurityModule,
    AuditoriaModule,
    LocalAuthModule,
    UsuariosModule,
    SeguridadModule,
    MailModule,
    DashboardModule,
  ],
  controllers: [ApiController],
  providers: [ApiService],
})
export class ApiModule { }