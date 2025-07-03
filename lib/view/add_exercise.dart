import 'package:flutter/material.dart';
import 'package:myapp/database/db_helper.dart';
import 'package:myapp/model/datos_entrenamiento.dart';
import 'package:myapp/model/seguimiento.dart';
import 'package:myapp/view/crear_plantilla_ejercicio.dart';

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

      // Validar nombre y descripción
      if (_nameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'El nombre no puede estar vacío o solo contener espacios.',
            ),
          ),
        );
        return;
      }
      if (_descriptionController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'La descripción no puede estar vacía o solo contener espacios.',
            ),
          ),
        );
        return;
      }

      final errors = <String>[];
      bool algunDatoValido = false;
      bool empiezaConCero(String s) =>
          s.length > 1 &&
          s.trim().startsWith('0') &&
          !s.trim().startsWith('0.');

      // Series
      final seriesRaw = _seriesController.text;
      final seriesTrim = seriesRaw.trim();
      final series = seriesTrim.isEmpty ? null : int.tryParse(seriesTrim);
      if (seriesRaw.isNotEmpty) {
        if (seriesTrim.isEmpty) {
          errors.add('Series no puede ser solo espacios.');
        } else if (empiezaConCero(seriesTrim)) {
          errors.add('Series tiene un valor invalido.');
        } else if (series == null) {
          errors.add('Series debe ser un número entero.');
        } else if (series <= 0) {
          errors.add('Series debe ser mayor que cero.');
        } else if (series < 1) {
          errors.add('Series debe ser al menos 1.');
        } else {
          algunDatoValido = true;
        }
      }

      // Repeticiones
      final repsRaw = _repsController.text;
      final repsTrim = repsRaw.trim();
      final reps = repsTrim.isEmpty ? null : int.tryParse(repsTrim);
      if (repsRaw.isNotEmpty) {
        if (repsTrim.isEmpty) {
          errors.add('Repeticiones no puede ser solo espacios.');
        } else if (empiezaConCero(repsTrim)) {
          errors.add('Repeticiones tiene un valor invalido.');
        } else if (reps == null) {
          errors.add('Repeticiones debe ser un número entero.');
        } else if (reps <= 0) {
          errors.add('Repeticiones debe ser mayor que cero.');
        } else if (reps < 1) {
          errors.add('Repeticiones debe ser al menos 1.');
        } else {
          algunDatoValido = true;
        }
      }

      // Peso (permitir decimales mayores a 0)
      final pesoRaw = _weightController.text;
      final pesoTrim = pesoRaw.trim();
      final peso = pesoTrim.isEmpty ? null : double.tryParse(pesoTrim);
      if (pesoRaw.isNotEmpty) {
        if (pesoTrim.isEmpty) {
          errors.add('Peso no puede ser solo espacios.');
        } else if (empiezaConCero(pesoTrim)) {
          errors.add('Peso tiene un valor invalido.');
        } else if (peso == null) {
          errors.add('Peso debe ser un número.');
        } else if (peso <= 0) {
          errors.add('Peso debe ser mayor que cero.');
        } else {
          algunDatoValido = true;
        }
      }

      // Tiempo (permitir decimales mayores a 0)
      final tiempoRaw = _timeController.text;
      final tiempoTrim = tiempoRaw.trim();
      final tiempo = tiempoTrim.isEmpty ? null : tiempoTrim;
      final tiempoDouble = tiempo != null ? double.tryParse(tiempo) : null;
      if (tiempoRaw.isNotEmpty) {
        if (tiempoTrim.isEmpty) {
          errors.add('Tiempo no puede ser solo espacios.');
        } else if (empiezaConCero(tiempoTrim)) {
          errors.add('Tiempo tiene un valor invalido.');
        } else if (tiempoDouble == null) {
          errors.add('Tiempo debe ser un número.');
        } else if (tiempoDouble <= 0) {
          errors.add('Tiempo debe ser mayor que cero.');
        } else if (tiempoDouble < 1) {
          errors.add('Tiempo debe ser al menos 1 minuto.');
        } else {
          algunDatoValido = true;
        }
      }

      // Distancia
      final distanciaRaw = _distanceController.text;
      final distanciaTrim = distanciaRaw.trim();
      final distancia =
          distanciaTrim.isEmpty ? null : double.tryParse(distanciaTrim);
      if (distanciaRaw.isNotEmpty) {
        if (distanciaTrim.isEmpty) {
          errors.add('Distancia no puede ser solo espacios.');
        } else if (empiezaConCero(distanciaTrim)) {
          errors.add('Distancia tiene un valor invalido.');
        } else if (distancia == null) {
          errors.add('Distancia debe ser un número.');
        } else if (distancia <= 0) {
          errors.add('Distancia debe ser mayor que cero.');
        } else {
          algunDatoValido = true;
        }
      }

      // Orden
      final ordenRaw = _orderController.text;
      final ordenTrim = ordenRaw.trim();
      final orden = ordenTrim.isEmpty ? null : int.tryParse(ordenTrim);
      if (ordenRaw.isNotEmpty) {
        if (ordenTrim.isEmpty) {
          errors.add('Orden no puede ser solo espacios.');
        } else if (empiezaConCero(ordenTrim)) {
          errors.add('Orden tiene un valor invalido.');
        } else if (orden == null) {
          errors.add('Orden debe ser un número entero.');
        } else if (orden <= 0) {
          errors.add('Orden debe ser mayor que cero.');
        }
      }

      if (!algunDatoValido) {
        errors.add(
          'Debes ingresar al menos un dato válido en los detalles del entrenamiento.',
        );
      }

      if (errors.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errors.join('\n'))));
        return;
      }

      // Verificar si ya existe un ejercicio con el mismo nombre y fecha
      final inicio = DateTime(
        widget.fechaSeleccionada!.year,
        widget.fechaSeleccionada!.month,
        widget.fechaSeleccionada!.day,
      );
      final fin = inicio.add(const Duration(days: 1));
      final db = await DBHelper.getDB();
      final existe = await db.query(
        DBHelper.tabla,
        where: 'titulo = ? AND fecha >= ? AND fecha < ? AND id_usuario = ?',
        whereArgs: [
          _nameController.text.trim(),
          inicio.toIso8601String(),
          fin.toIso8601String(),
          usuario.id,
        ],
      );
      if (existe.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Ya existe un ejercicio con ese nombre para este día.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final nuevo = DatosEntrenamiento(
        idUsuario: usuario.id,
        titulo: _nameController.text.trim(),
        descripcion: _descriptionController.text.trim(),
        fecha: widget.fechaSeleccionada ?? DateTime.now(),
        orden: orden,
        series: series,
        reps: reps,
        peso: peso,
        tiempo: tiempo,
        distancia: distancia,
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
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.view_list, color: Colors.white),
                  label: const Text(
                    'Usar plantilla',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CrearPlantillaScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
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
