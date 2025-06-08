import 'package:flutter/material.dart';
import 'package:myapp/database/db_helper.dart';
import 'package:myapp/model/datos_entrenamiento.dart';
import 'package:myapp/model/seguimiento.dart';

class AddExerciseScreen extends StatefulWidget {
  final DateTime? fechaSeleccionada;

  const AddExerciseScreen({super.key, this.fechaSeleccionada});

  @override
  _AddExerciseScreenState createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _weightController = TextEditingController();
  final _repsController = TextEditingController();
  final _seriesController = TextEditingController();
  final _distanceController = TextEditingController();
  final _timeController = TextEditingController();
  final _orderController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _weightController.dispose();
    _repsController.dispose();
    _seriesController.dispose();
    _distanceController.dispose();
    _timeController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  void _saveExercise() async {
    if (_formKey.currentState!.validate()) {
      final usuario = await DBHelper.getUsuarioActivo();
      if (usuario == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: No hay usuario activo')),
        );
        return;
      }

      // final fecha = DateTime(
      //   (widget.fechaSeleccionada ?? DateTime.now()).year,
      //   (widget.fechaSeleccionada ?? DateTime.now()).month,
      //   (widget.fechaSeleccionada ?? DateTime.now()).day,
      // );

      final nuevo = DatosEntrenamiento(
        idUsuario: usuario.id,
        titulo: _nameController.text.trim(),
        descripcion: _descriptionController.text.trim(),
        fecha: widget.fechaSeleccionada ?? DateTime.now(),
        orden: int.tryParse(_orderController.text),
        series: int.tryParse(_seriesController.text),
        reps: int.tryParse(_repsController.text),
        peso: double.tryParse(_weightController.text),
        tiempo:
            _timeController.text.trim().isNotEmpty
                ? _timeController.text.trim()
                : null,
        distancia: double.tryParse(_distanceController.text),
      );

      // Inserta el ejercicio y obtén su ID
      final ejercicioId = await DBHelper.insert(nuevo);

      // Crear registros de seguimiento para los campos relevantes
      final now = DateTime.now().toIso8601String();
      if (nuevo.series != null) {
        await DBHelper.insertSeguimiento(
          Seguimiento(
            idUsuario: usuario.id,
            idEntrenamiento: ejercicioId,
            fechaEntrenamiento: now,
            tipoRecord: 'series',
            valorRecord: nuevo.series!.toDouble(),
          ),
        );
      }
      if (nuevo.reps != null) {
        await DBHelper.insertSeguimiento(
          Seguimiento(
            idUsuario: usuario.id,
            idEntrenamiento: ejercicioId,
            fechaEntrenamiento: now,
            tipoRecord: 'reps',
            valorRecord: nuevo.reps!.toDouble(),
          ),
        );
      }
      if (nuevo.peso != null) {
        await DBHelper.insertSeguimiento(
          Seguimiento(
            idUsuario: usuario.id,
            idEntrenamiento: ejercicioId,
            fechaEntrenamiento: now,
            tipoRecord: 'peso',
            valorRecord: nuevo.peso!,
          ),
        );
      }
      if (nuevo.tiempo != null && double.tryParse(nuevo.tiempo!) != null) {
        await DBHelper.insertSeguimiento(
          Seguimiento(
            idUsuario: usuario.id,
            idEntrenamiento: ejercicioId,
            fechaEntrenamiento: now,
            tipoRecord: 'tiempo',
            valorRecord: double.parse(nuevo.tiempo!),
          ),
        );
      }
      if (nuevo.distancia != null) {
        await DBHelper.insertSeguimiento(
          Seguimiento(
            idUsuario: usuario.id,
            idEntrenamiento: ejercicioId,
            fechaEntrenamiento: now,
            tipoRecord: 'distancia',
            valorRecord: nuevo.distancia!,
          ),
        );
      }

      Navigator.pop(context, true);
    }
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      filled: true,
      fillColor: Colors.grey[100],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text(
          'Añadir Ejercicio',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Información del ejercicio',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: _buildInputDecoration(
                  'Nombre',
                  Icons.fitness_center,
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Este campo es obligatorio'
                            : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: _buildInputDecoration('Descripción', Icons.notes),
              ),
              const SizedBox(height: 30),
              const Text(
                'Detalles del entrenamiento',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _orderController,
                decoration: _buildInputDecoration(
                  'Orden',
                  Icons.format_list_numbered,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _seriesController,
                decoration: _buildInputDecoration('Series', Icons.looks_3),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _repsController,
                decoration: _buildInputDecoration('Repeticiones', Icons.repeat),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _weightController,
                decoration: _buildInputDecoration(
                  'Peso (kg)',
                  Icons.line_weight,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _distanceController,
                decoration: _buildInputDecoration(
                  'Distancia (km)',
                  Icons.directions_run,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _timeController,
                decoration: _buildInputDecoration('Tiempo (min)', Icons.timer),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text(
                    'Guardar Ejercicio',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade500,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: _saveExercise,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
