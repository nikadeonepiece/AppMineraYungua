class EmpleadoBiometriaEntity {
  EmpleadoBiometriaEntity({
    required this.id,
    required this.empleadoId,
    required this.embedding,
    required this.activo,
    required this.updatedAt,
  });

  final int id;
  final int empleadoId;
  final List<double> embedding;
  final bool activo;
  final DateTime updatedAt;
}
