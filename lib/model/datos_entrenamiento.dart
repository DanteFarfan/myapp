class DatosEntrenamiento {
  final int? id;
  final String titulo;
  final String descripcion;
  final DateTime fecha;
  final int? orden;
  final int? series;
  final int? reps;
  final double? peso;
  final String? tiempo;
  final double? distancia;

  DatosEntrenamiento({
    this.id,
    required this.titulo,
    required this.descripcion,
    required this.fecha,
    this.orden,
    this.series,
    this.reps,
    this.peso,
    this.tiempo,
    this.distancia,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'fecha':
          '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}',
      'orden': orden,
      'series': series,
      'reps': reps,
      'peso': peso,
      'tiempo': tiempo,
      'distancia': distancia,
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
      orden: map['orden'],
      series: map['series'],
      reps: map['reps'],
      peso: map['peso'] != null ? (map['peso'] as num).toDouble() : null,
      tiempo: map['tiempo'],
      distancia:
          map['distancia'] != null
              ? (map['distancia'] as num).toDouble()
              : null,
    );
  }
}
