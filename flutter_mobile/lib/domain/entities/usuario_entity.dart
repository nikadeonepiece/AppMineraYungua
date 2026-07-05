class UsuarioEntity {
  UsuarioEntity({
    required this.id,
    required this.username,
    this.passwordHash = '',
    required this.empleadoId,
    required this.rolId,
    required this.activo,
    required this.updatedAt,
  });

  final int id;
  final String username;
  final String passwordHash;
  final int empleadoId;
  final int rolId;
  final bool activo;
  final DateTime updatedAt;
}
