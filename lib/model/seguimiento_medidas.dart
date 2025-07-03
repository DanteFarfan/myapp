class Medida {
  final int? id;
  final int idUsuario;
  final String nombre;
  final String descripcion;
  final double valor;
  final String unidad; // 'kg' o 'cm'
  final DateTime fecha;

  Medida({
    this.id,
    required this.idUsuario,
    required this.nombre,
    required this.descripcion,
    required this.valor,
    required this.unidad,
    required this.fecha,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'id_usuario': idUsuario,
    'nombre': nombre,
    'descripcion': descripcion,
    'valor': valor,
    'unidad': unidad,
    'fecha': fecha.toIso8601String(),
  };

  factory Medida.fromMap(Map<String, dynamic> map) => Medida(
    id: map['id'],
    idUsuario: map['id_usuario'],
    nombre: map['nombre'],
    descripcion: map['descripcion'],
    valor: (map['valor'] as num).toDouble(),
    unidad: map['unidad'],
    fecha: DateTime.parse(map['fecha']),
  );
}
