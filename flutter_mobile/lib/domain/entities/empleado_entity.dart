class EmpleadoEntity {
  EmpleadoEntity({
    required this.id,
    required this.dni,
    required this.codigoEmpleado,
    required this.nombres,
    required this.apellidos,
    required this.area,
    required this.cargo,
    required this.activo,
    required this.updatedAt,
  });

  final int id;
  final String dni;
  final String codigoEmpleado;
  final String nombres;
  final String apellidos;
  final String area;
  final String cargo;
  final bool activo;
  final DateTime updatedAt;
}
