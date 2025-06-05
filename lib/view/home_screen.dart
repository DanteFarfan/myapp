import 'package:flutter/material.dart';
import 'package:myapp/view/add_exercise.dart';
import 'package:myapp/view/exercise_detail_screen.dart';
import 'package:intl/intl.dart';
import 'package:myapp/database/db_helper.dart';
import 'package:myapp/model/datos_entrenamiento.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<DatosEntrenamiento> entrenamientosDelDia = [];

  @override
  void initState() {
    super.initState();
    cargarEntrenamientosDelDia();
  }

  Future<void> cargarEntrenamientosDelDia() async {
    final hoy = DateTime.now();
    final datos = await DBHelper.getEntrenamientosDelDia(hoy);
    setState(() {
      entrenamientosDelDia = datos;
    });
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Opciones',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.show_chart, color: Colors.deepPurple),
                title: const Text('Seguimiento'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(
                  Icons.restaurant_menu,
                  color: Colors.deepPurple,
                ),
                title: const Text('Plan de nutrición'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(
                  Icons.fitness_center,
                  color: Colors.deepPurple,
                ),
                title: const Text('Plantillas de ejercicio'),
                onTap: () {},
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEntrenamientoTile(DatosEntrenamiento e) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.check_circle, color: Colors.deepPurple),
        title: Text(e.titulo),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(e.descripcion),
            const SizedBox(height: 4),
            Text(
              'Orden: ${e.orden ?? '-'} | Series: ${e.series ?? '-'} | Reps: ${e.reps ?? '-'}',
            ),
            Text(
              'Peso: ${e.peso != null ? '${e.peso} kg' : '-'} | Tiempo: ${e.tiempo ?? '-'} | Distancia: ${e.distancia != null ? '${e.distancia} km' : '-'}',
            ),
          ],
        ),
        isThreeLine: true,
        onTap: () async {
          final resultado = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExerciseDetailScreen(entrenamiento: e),
            ),
          );
          if (resultado == true) {
            await cargarEntrenamientosDelDia();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fechaHoy = DateFormat('dd/MM/yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: const Text(
          'FitMaster',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.black),
            tooltip: 'Iniciar sesión',
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () => _showOptions(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Entrenamientos de hoy ($fechaHoy)',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            entrenamientosDelDia.isEmpty
                ? const Text(
                  'No se registraron entrenamientos hoy.',
                  style: TextStyle(color: Colors.grey),
                )
                : Expanded(
                  child: ListView.builder(
                    itemCount: entrenamientosDelDia.length,
                    itemBuilder: (context, index) {
                      final e = entrenamientosDelDia[index];
                      return _buildEntrenamientoTile(e);
                    },
                  ),
                ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Añadir ejercicio',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple.shade500,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () async {
                  final resultado = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddExerciseScreen(),
                    ),
                  );
                  if (resultado == true) {
                    cargarEntrenamientosDelDia();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


