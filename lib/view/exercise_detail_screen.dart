import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//import 'package:myapp/view/home_screen.dart'; // importa la clase DatosEntrenamiento si está en otro archivo
import 'package:myapp/model/datos_entrenamiento.dart';
//import 'package:myapp/database/db_helper.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final DatosEntrenamiento entrenamiento;

  const ExerciseDetailScreen({super.key, required this.entrenamiento});

  @override
  Widget build(BuildContext context) {
    final fechaFormateada = DateFormat(
      'dd/MM/yyyy',
    ).format(entrenamiento.fecha);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Entrenamiento'),
        backgroundColor: Colors.deepPurple.shade400,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entrenamiento.titulo,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              fechaFormateada,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 20),
            Text(
              entrenamiento.descripcion,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
