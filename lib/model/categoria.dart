class Categoria {
  final int? id;
  final int idUsuario;
  final String nombre;

  Categoria({this.id, required this.idUsuario, required this.nombre});

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'id_usuario': idUsuario,
    'nombre': nombre,
  };

  factory Categoria.fromMap(Map<String, dynamic> map) => Categoria(
    id: map['id'],
    idUsuario: map['id_usuario'],
    nombre: map['nombre'],
  );
}
