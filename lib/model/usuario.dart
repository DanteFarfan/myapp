class Usuario {
  final int id;
  final String username;

  Usuario({required this.id, required this.username});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'],
      username: map['username'],
    );
  }
}
