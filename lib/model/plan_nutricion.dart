class PlanNutricion {
  final double peso;
  final double altura;
  final int edad;
  final String genero;
  final String objetivo;
  final double calorias;

  PlanNutricion({
    required this.peso,
    required this.altura,
    required this.edad,
    required this.genero,
    required this.objetivo,
    required this.calorias,
  });

  Map<String, dynamic> toMap() {
    return {
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
      peso: map['peso'],
      altura: map['altura'],
      edad: map['edad'],
      genero: map['genero'],
      objetivo: map['objetivo'],
      calorias: map['calorias'],
    );
  }
}