import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/model/datos_entrenamiento.dart';
import 'package:myapp/database/db_helper.dart';
import 'package:myapp/model/plantilla_ejercicio.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final DatosEntrenamiento entrenamiento;

  const ExerciseDetailScreen({super.key, required this.entrenamiento});

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  late TextEditingController _tituloController;
  late TextEditingController _descripcionController;
  // late TextEditingController _ordenController; // eliminar esta línea
  late TextEditingController _seriesController;
  late TextEditingController _repsController;
  late TextEditingController _pesoController;
  late TextEditingController _tiempoController;
  late TextEditingController _distanciaController;

  bool _editMode = false;
  PlantillaEjercicio? _plantilla;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(
      text: widget.entrenamiento.titulo,
    );
    _descripcionController = TextEditingController(
      text: widget.entrenamiento.descripcion,
    );
    // _ordenController = TextEditingController(
    //   text: widget.entrenamiento.orden?.toString() ?? '',
    // );
    _seriesController = TextEditingController(
      text: widget.entrenamiento.series?.toString() ?? '',
    );
    _repsController = TextEditingController(
      text: widget.entrenamiento.reps?.toString() ?? '',
    );
    _pesoController = TextEditingController(
      text: widget.entrenamiento.peso?.toString() ?? '',
    );
    _tiempoController = TextEditingController(
      text: widget.entrenamiento.tiempo ?? '',
    );
    _distanciaController = TextEditingController(
      text: widget.entrenamiento.distancia?.toString() ?? '',
    );
    _cargarPlantilla();
  }

  Future<void> _cargarPlantilla() async {
    if (widget.entrenamiento.idPlantilla != null) {
      final plantillas = await DBHelper.getPlantillas();
      final plantillaList = plantillas.where(
        (p) => p.id == widget.entrenamiento.idPlantilla,
      );
      final plantilla = plantillaList.isNotEmpty ? plantillaList.first : null;
      setState(() {
        _plantilla = plantilla;
      });
    } else {
      setState(() {
        _plantilla = null;
      });
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    // _ordenController.dispose();
    _seriesController.dispose();
    _repsController.dispose();
    _pesoController.dispose();
    _tiempoController.dispose();
    _distanciaController.dispose();
    super.dispose();
  }

  void _guardarCambios() async {
    final usuario = await DBHelper.getUsuarioActivo();

    if (usuario == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No hay usuario activo.')));
      return;
    }

    if (_tituloController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'El título no puede estar vacío o solo contener espacios.',
          ),
        ),
      );
      return;
    }
    if (_descripcionController.text.trim().isEmpty) {
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
        s.length > 1 && s.trim().startsWith('0') && !s.trim().startsWith('0.');

    // Series
    int? series;
    final seriesRaw = _seriesController.text;
    final seriesTrim = seriesRaw.trim();
    if (_plantilla == null || _plantilla!.trackSeries) {
      series = seriesTrim.isEmpty ? null : int.tryParse(seriesTrim);
      if (seriesRaw.isNotEmpty) {
        if (seriesTrim.isEmpty) {
          errors.add('Series no puede ser solo espacios.');
        } else if (empiezaConCero(seriesTrim)) {
          errors.add('Series tiene un valor invalido (no debe empezar con 0).');
        } else if (series == null) {
          errors.add('Series debe ser un número entero.');
        } else if (series <= 0) {
          errors.add('Series debe ser mayor que cero.');
        } else if (series < 2) {
          errors.add('Series debe ser al menos 2.');
        } else {
          algunDatoValido = true;
        }
      }
    }

    // Repeticiones
    int? reps;
    final repsRaw = _repsController.text;
    final repsTrim = repsRaw.trim();
    if (_plantilla == null || _plantilla!.trackReps) {
      reps = repsTrim.isEmpty ? null : int.tryParse(repsTrim);
      if (repsRaw.isNotEmpty) {
        if (repsTrim.isEmpty) {
          errors.add('Repeticiones no puede ser solo espacios.');
        } else if (empiezaConCero(repsTrim)) {
          errors.add('Repeticiones tiene un valor invalido.');
        } else if (reps == null) {
          errors.add('Repeticiones debe ser un número entero.');
        } else if (reps <= 0) {
          errors.add('Repeticiones debe ser mayor que cero.');
        } else if (reps < 2) {
          errors.add('Repeticiones debe ser al menos 2.');
        } else {
          algunDatoValido = true;
        }
      }
    }

    // Peso
    double? peso;
    final pesoRaw = _pesoController.text;
    final pesoTrim = pesoRaw.trim();
    if (_plantilla == null || _plantilla!.trackPeso) {
      peso = pesoTrim.isEmpty ? null : double.tryParse(pesoTrim);
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
    }

    // Tiempo
    String? tiempo;
    final tiempoRaw = _tiempoController.text;
    final tiempoTrim = tiempoRaw.trim();
    double? tiempoDouble;
    if (_plantilla == null || _plantilla!.trackTiempo) {
      tiempo = tiempoTrim.isEmpty ? null : tiempoTrim;
      tiempoDouble = tiempo != null ? double.tryParse(tiempo) : null;
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
    }

    // Distancia
    double? distancia;
    final distanciaRaw = _distanciaController.text;
    final distanciaTrim = distanciaRaw.trim();
    if (_plantilla == null || _plantilla!.trackDistancia) {
      distancia = distanciaTrim.isEmpty ? null : double.tryParse(distanciaTrim);
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

    // Si hay plantilla, los campos no seleccionados deben guardarse como null
    if (_plantilla != null) {
      if (!_plantilla!.trackSeries) series = null;
      if (!_plantilla!.trackReps) reps = null;
      if (!_plantilla!.trackPeso) peso = null;
      if (!_plantilla!.trackTiempo) tiempo = null;
      if (!_plantilla!.trackDistancia) distancia = null;
    }

    final actualizado = DatosEntrenamiento(
      id: widget.entrenamiento.id,
      titulo: _tituloController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      fecha: widget.entrenamiento.fecha,
      series: series,
      reps: reps,
      peso: peso,
      tiempo: tiempo,
      distancia: distancia,
      idUsuario: usuario.id,
      idPlantilla: widget.entrenamiento.idPlantilla,
    );

    await DBHelper.update(actualizado);

    // Actualizar seguimiento relacionado (si existe)
    final seguimientos = await DBHelper.getSeguimientoPorUsuario(usuario.id);
    for (final s in seguimientos.where(
      (s) => s.idEntrenamiento == actualizado.id,
    )) {
      double? nuevoValor;
      switch (s.tipoRecord) {
        case 'series':
          nuevoValor = actualizado.series?.toDouble();
          break;
        case 'reps':
          nuevoValor = actualizado.reps?.toDouble();
          break;
        case 'peso':
          nuevoValor = actualizado.peso;
          break;
        case 'tiempo':
          nuevoValor = double.tryParse(actualizado.tiempo ?? '');
          break;
        case 'distancia':
          nuevoValor = actualizado.distancia;
          break;
      }
      if (nuevoValor != null) {
        await DBHelper.updateSeguimiento(s.copyWith(valorRecord: nuevoValor));
      }
    }

    Navigator.pop(context, true);
  }

  void _confirmarEliminacion() async {
    final confirmacion = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('¿Eliminar ejercicio?'),
            content: const Text('Esta acción no se puede deshacer.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmacion == true) {
      // Elimina los seguimientos relacionados antes de borrar el entrenamiento
      final usuario = await DBHelper.getUsuarioActivo();
      if (usuario != null) {
        final seguimientos = await DBHelper.getSeguimientoPorUsuario(
          usuario.id,
        );
        for (final s in seguimientos.where(
          (s) => s.idEntrenamiento == widget.entrenamiento.id,
        )) {
          await DBHelper.deleteSeguimiento(s.id!);
        }
      }
      await DBHelper.delete(widget.entrenamiento.id!);
      Navigator.pop(context, true); // Notifica recarga a la pantalla anterior
    }
  }

  Widget _buildEditableField(
    String label,
    TextEditingController controller, {
    TextInputType tipo = TextInputType.text,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        enabled: enabled && _editMode,
        keyboardType: tipo,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: _editMode ? Colors.grey[100] : Colors.transparent,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fechaFormateada = DateFormat(
      'dd/MM/yyyy',
    ).format(widget.entrenamiento.fecha);

    final plantilla = _plantilla;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Entrenamiento'),
        backgroundColor: Colors.deepPurple.shade400,
        actions: [
          IconButton(
            icon: Icon(_editMode ? Icons.save : Icons.edit),
            onPressed: () {
              if (_editMode) {
                _guardarCambios();
              } else {
                setState(() => _editMode = true);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _confirmarEliminacion,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Text(
              fechaFormateada,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 10),
            _buildEditableField(
              'Título',
              _tituloController,
              enabled: false, // No editable
            ),
            _buildEditableField('Descripción', _descripcionController),
            const Divider(height: 30, thickness: 1),
            const Text(
              'Detalles del Ejercicio',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Eliminar campo de orden:
            // _buildEditableField(
            //   'Orden',
            //   _ordenController,
            //   tipo: TextInputType.number,
            // ),
            if (plantilla != null) ...[
              if (plantilla.trackSeries)
                _buildEditableField(
                  'Series',
                  _seriesController,
                  tipo: TextInputType.number,
                ),
              if (plantilla.trackReps)
                _buildEditableField(
                  'Repeticiones',
                  _repsController,
                  tipo: TextInputType.number,
                ),
              if (plantilla.trackPeso)
                _buildEditableField(
                  'Peso (kg)',
                  _pesoController,
                  tipo: TextInputType.number,
                ),
              if (plantilla.trackTiempo)
                _buildEditableField(
                  'Tiempo (min)',
                  _tiempoController,
                  tipo: TextInputType.number,
                ),
              if (plantilla.trackDistancia)
                _buildEditableField(
                  'Distancia (km)',
                  _distanciaController,
                  tipo: TextInputType.number,
                ),
            ],
            if (plantilla == null) ...[
              _buildEditableField(
                'Series',
                _seriesController,
                tipo: TextInputType.number,
              ),
              _buildEditableField(
                'Repeticiones',
                _repsController,
                tipo: TextInputType.number,
              ),
              _buildEditableField(
                'Peso (kg)',
                _pesoController,
                tipo: TextInputType.number,
              ),
              _buildEditableField(
                'Tiempo (min)',
                _tiempoController,
                tipo: TextInputType.number,
              ),
              _buildEditableField(
                'Distancia (km)',
                _distanciaController,
                tipo: TextInputType.number,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
