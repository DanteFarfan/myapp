class PlantillaEjercicio {
  final int? id;
  final String nombre;
  final bool trackSeries;
  final bool trackReps;
  final bool trackPeso;
  final bool trackDistancia;
  final bool trackTiempo;

  PlantillaEjercicio({
    this.id,
    required this.nombre,
    required this.trackSeries,
    required this.trackReps,
    required this.trackPeso,
    required this.trackDistancia,
    required this.trackTiempo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'track_series': trackSeries ? 1 : 0,
      'track_reps': trackReps ? 1 : 0,
      'track_peso': trackPeso ? 1 : 0,
      'track_distancia': trackDistancia ? 1 : 0,
      'track_tiempo': trackTiempo ? 1 : 0,
    };
  }

  factory PlantillaEjercicio.fromMap(Map<String, dynamic> map) {
    return PlantillaEjercicio(
      id: map['id'],
      nombre: map['nombre'],
      trackSeries: map['track_series'] == 1,
      trackReps: map['track_reps'] == 1,
      trackPeso: map['track_peso'] == 1,
      trackDistancia: map['track_distancia'] == 1,
      trackTiempo: map['track_tiempo'] == 1,
    );
  }

  PlantillaEjercicio copyWith({
    int? id,
    String? nombre,
    bool? trackSeries,
    bool? trackReps,
    bool? trackPeso,
    bool? trackDistancia,
    bool? trackTiempo,
  }) {
    return PlantillaEjercicio(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      trackSeries: trackSeries ?? this.trackSeries,
      trackReps: trackReps ?? this.trackReps,
      trackPeso: trackPeso ?? this.trackPeso,
      trackDistancia: trackDistancia ?? this.trackDistancia,
      trackTiempo: trackTiempo ?? this.trackTiempo,
    );
  }
}
