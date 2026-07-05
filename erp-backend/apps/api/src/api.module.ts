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
import { AreaModule } from './erp/personal/area/area.module';
import { CargoModule } from './erp/personal/cargo/cargo.module';
import { RegimenLaboralModule } from './erp/personal/regimen-laboral/regimen-laboral.module';
import { TurnoTrabajoModule } from './erp/personal/turno-trabajo/turno-trabajo.module';
import { PersonalModule } from './erp/personal/personal/personal.module';
import { MarcacionAsistenciaModule } from './erp/marcacion-asistencia/marcacion-asistencia.module';

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
    AreaModule,
    CargoModule,
    RegimenLaboralModule,
    TurnoTrabajoModule,
    PersonalModule,
    MarcacionAsistenciaModule,
  ],
  controllers: [ApiController],
  providers: [ApiService],
})
export class ApiModule { }