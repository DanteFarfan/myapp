class PlanNutricion {
  final int? id; // Nuevo: id del plan (opcional)
  final int idUsuario; // Nuevo: id del usuario asociado
  final double peso;
  final double altura;
  final int edad;
  final String genero;
  final String objetivo;
  final double calorias;

  PlanNutricion({
    this.id,
    required this.idUsuario,
    required this.peso,
    required this.altura,
    required this.edad,
    required this.genero,
    required this.objetivo,
    required this.calorias,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'id_usuario': idUsuario,
      'peso': peso,
      'altura': altura,
      'edad': edad,
      'genero': genero,
      'objetivo': objetivo,
      'calorias': calorias,
    };
  }

  factory PlanNutricion.fromMap(Map<String, dynamic> map) {
    return PlanNutricion(
      id: map['id'],
      idUsuario: map['id_usuario'],
      peso: (map['peso'] as num).toDouble(),
      altura: (map['altura'] as num).toDouble(),
      edad: map['edad'],
      genero: map['genero'],
      objetivo: map['objetivo'],
      calorias: (map['calorias'] as num).toDouble(),
    );
  }
}