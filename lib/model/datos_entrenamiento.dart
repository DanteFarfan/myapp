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
  final int? idUsuario;

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
    this.idUsuario,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'fecha': fecha.toIso8601String(), // o .toString() si prefieres
      'orden': orden,
      'series': series,
      'reps': reps,
      'peso': peso,
      'tiempo': tiempo,
      'distancia': distancia,
      'id_usuario': idUsuario,
    };
  }

  factory DatosEntrenamiento.fromMap(Map<String, dynamic> map) {
    // final fechaParts = map['fecha'].split('-');
    return DatosEntrenamiento(
      id: map['id'],
      titulo: map['titulo'],
      descripcion: map['descripcion'],
      fecha: DateTime.parse(map['fecha']),
      orden: map['orden'],
      series: map['series'],
      reps: map['reps'],
      peso: map['peso'] != null ? (map['peso'] as num).toDouble() : null,
      tiempo: map['tiempo'],
      distancia:
          map['distancia'] != null
              ? (map['distancia'] as num).toDouble()
              : null,
      idUsuario: map['id_usuario'],
    );
  }
}
