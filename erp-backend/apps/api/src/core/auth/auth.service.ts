import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { UsuariosService } from '../usuarios/usuarios.service';
import { LoginDto } from './dto/login.dto';
import * as bcrypt from 'bcrypt';

@Injectable()
export class AuthService {
  constructor(
    private readonly usuariosService: UsuariosService,
    private readonly jwtService: JwtService,
  ) {}

  async login(loginDto: LoginDto) {
    const user = await this.usuariosService.findByEmail(loginDto.correo);
    console.log('>>> correo recibido:', loginDto.correo);
    console.log('>>> user de BD:', JSON.stringify(user));

    if (!user || user.estado_registro !== 'ACTIVO') {
      throw new UnauthorizedException('Credenciales incorrectas o usuario inactivo');
    }

    const passwordValida = await bcrypt.compare(loginDto.password, user.password);

    if (!passwordValida) {
      throw new UnauthorizedException('Credenciales incorrectas');
    }

    const payload = {
      sub: user.id_usuario,
      username: user.correo,
      roleId: user.id_rol
    };

    let esPrimeraSesion = false;
    try { esPrimeraSesion = await this.usuariosService.leerYMarcarPrimeraSesion(user.id_usuario); } catch (_) {}

    return {
      mensaje: 'Login exitoso',
      access_token: this.jwtService.sign(payload),
      primera_sesion: esPrimeraSesion,
      usuario: {
        id_usuario: user.id_usuario,
        nombres: user.nombres,
        apellidos: user.apellidos,
        correo: user.correo,
        id_rol: user.id_rol,
        nombre_rol: user.rol
      }
    };
  }
}