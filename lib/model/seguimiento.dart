class Seguimiento {
  final int? id;
  final int idUsuario;
  final int? idEntrenamiento;
  final String fechaEntrenamiento;
  final String tipoRecord;
  final double valorRecord;

  Seguimiento({
    this.id,
    required this.idUsuario,
    this.idEntrenamiento,
    required this.fechaEntrenamiento,
    required this.tipoRecord,
    required this.valorRecord,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_usuario': idUsuario,
      'id_entrenamiento': idEntrenamiento,
      'fecha_entrenamiento': fechaEntrenamiento,
      'tipo_record': tipoRecord,
      'valor_record': valorRecord,
    };
  }

  factory Seguimiento.fromMap(Map<String, dynamic> map) {
    return Seguimiento(
      id: map['id'],
      idUsuario: map['id_usuario'],
      idEntrenamiento: map['id_entrenamiento'],
      fechaEntrenamiento: map['fecha_entrenamiento'],
      tipoRecord: map['tipo_record'],
      valorRecord: map['valor_record']?.toDouble() ?? 0,
    );
  }
}
