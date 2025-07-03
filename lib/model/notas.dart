class NotaDia {
  final int? id;
  final int idUsuario;
  final String texto;
  final DateTime fecha;

  NotaDia({
    this.id,
    required this.idUsuario,
    required this.texto,
    required this.fecha,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'id_usuario': idUsuario,
        'texto': texto,
        'fecha': fecha.toIso8601String(),
      };

  factory NotaDia.fromMap(Map<String, dynamic> map) => NotaDia(
        id: map['id'],
        idUsuario: map['id_usuario'],
        texto: map['texto'],
        fecha: DateTime.parse(map['fecha']),
      );
}