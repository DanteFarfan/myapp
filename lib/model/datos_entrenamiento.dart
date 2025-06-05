class DatosEntrenamiento {
  final int? id;
  final String titulo;
  final String descripcion;
  final DateTime fecha;

  DatosEntrenamiento({
    this.id,
    required this.titulo,
    required this.descripcion,
    required this.fecha,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'fecha':
          '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}',
    };
  }

  factory DatosEntrenamiento.fromMap(Map<String, dynamic> map) {
    final fechaParts = map['fecha'].split('-');
    return DatosEntrenamiento(
      id: map['id'],
      titulo: map['titulo'],
      descripcion: map['descripcion'],
      fecha: DateTime(
        int.parse(fechaParts[0]),
        int.parse(fechaParts[1]),
        int.parse(fechaParts[2]),
      ),
    );
  }
}
