class DatosEntrenamiento {
  final int? id;
  final String titulo;
  final String descripcion;
  final DateTime fecha;
  final int? series;
  final int? reps;
  final double? peso;
  final String? tiempo;
  final double? distancia;
  final int? idUsuario;
  final int? idPlantilla;

  DatosEntrenamiento({
    this.id,
    required this.titulo,
    required this.descripcion,
    required this.fecha,
    this.series,
    this.reps,
    this.peso,
    this.tiempo,
    this.distancia,
    this.idUsuario,
    this.idPlantilla,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'fecha': fecha.toIso8601String(),
      'series': series,
      'reps': reps,
      'peso': peso,
      'tiempo': tiempo,
      'distancia': distancia,
      'id_usuario': idUsuario,
      'id_plantilla': idPlantilla,
    };
  }

  factory DatosEntrenamiento.fromMap(Map<String, dynamic> map) {
    return DatosEntrenamiento(
      id: map['id'],
      titulo: map['titulo'],
      descripcion: map['descripcion'],
      fecha: DateTime.parse(map['fecha']),
      series: map['series'],
      reps: map['reps'],
      peso: map['peso'] != null ? (map['peso'] as num).toDouble() : null,
      tiempo: map['tiempo'],
      distancia:
          map['distancia'] != null
              ? (map['distancia'] as num).toDouble()
              : null,
      idUsuario: map['id_usuario'],
      idPlantilla: map['id_plantilla'],
    );
  }
}
