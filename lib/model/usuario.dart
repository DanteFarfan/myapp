class Usuario {
  final int id;
  final String username;
  final String password;
  final String correoElectronico;
  final String fechaRegistro;
  final String fechaNacimiento;
  final double peso;
  final int edad;
  final bool activo;

  Usuario({
    required this.id,
    required this.username,
    required this.password,
    required this.correoElectronico,
    required this.fechaRegistro,
    required this.fechaNacimiento,
    required this.peso,
    required this.edad,
    required this.activo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'correo_electronico': correoElectronico,
      'fecha_registro': fechaRegistro,
      'fecha_nacimiento': fechaNacimiento,
      'peso': peso,
      'edad': edad,
      'activo': activo ? 1 : 0,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      correoElectronico: map['correo_electronico'],
      fechaRegistro: map['fecha_registro'],
      fechaNacimiento: map['fecha_nacimiento'],
      peso: (map['peso'] as num).toDouble(),
      edad: map['edad'],
      activo: map['activo'] == 1,
    );
  }
}
