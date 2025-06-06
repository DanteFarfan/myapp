class Usuario {
  final int id;
  String nombre;
  String password;
  String correo;
  String
  fechaRegistro; // Guarda fecha en formato String, por ejemplo "2025-06-05"
  String fechaNacimiento; // Igual, en formato String
  double peso;
  int edad;

  Usuario({
    required this.id,
    required this.nombre,
    required this.password,
    required this.correo,
    required this.fechaRegistro,
    required this.fechaNacimiento,
    required this.peso,
    required this.edad,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'password': password,
      'correo': correo,
      'fecha_registro': fechaRegistro,
      'fecha_nacimiento': fechaNacimiento,
      'peso': peso,
      'edad': edad,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'],
      nombre: map['nombre'] ?? '',
      password: map['password'] ?? '',
      correo: map['correo'] ?? '',
      fechaRegistro: map['fecha_registro'] ?? '',
      fechaNacimiento: map['fecha_nacimiento'] ?? '',
      peso:
          (map['peso'] is int)
              ? (map['peso'] as int).toDouble()
              : (map['peso'] ?? 0.0),
      edad: map['edad'] ?? 0,
    );
  }
}
