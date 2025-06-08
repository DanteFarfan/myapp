import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/model/datos_entrenamiento.dart';
import 'package:myapp/database/db_helper.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final DatosEntrenamiento entrenamiento;

  const ExerciseDetailScreen({super.key, required this.entrenamiento});

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  late TextEditingController _tituloController;
  late TextEditingController _descripcionController;
  late TextEditingController _ordenController;
  late TextEditingController _seriesController;
  late TextEditingController _repsController;
  late TextEditingController _pesoController;
  late TextEditingController _tiempoController;
  late TextEditingController _distanciaController;

  bool _editMode = false;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(
      text: widget.entrenamiento.titulo,
    );
    _descripcionController = TextEditingController(
      text: widget.entrenamiento.descripcion,
    );
    _ordenController = TextEditingController(
      text: widget.entrenamiento.orden?.toString() ?? '',
    );
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
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _ordenController.dispose();
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
      // Manejar error, no hay usuario activo
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No hay usuario activo.')));
      return;
    }

    final actualizado = DatosEntrenamiento(
      id: widget.entrenamiento.id,
      titulo: _tituloController.text,
      descripcion: _descripcionController.text,
      fecha: widget.entrenamiento.fecha,
      orden: int.tryParse(_ordenController.text),
      series: int.tryParse(_seriesController.text),
      reps: int.tryParse(_repsController.text),
      peso: double.tryParse(_pesoController.text),
      tiempo: _tiempoController.text,
      distancia: double.tryParse(_distanciaController.text),
      idUsuario: usuario.id,
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
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        enabled: _editMode,
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
            _buildEditableField('Título', _tituloController),
            _buildEditableField('Descripción', _descripcionController),
            const Divider(height: 30, thickness: 1),
            const Text(
              'Detalles del Ejercicio',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            _buildEditableField(
              'Orden',
              _ordenController,
              tipo: TextInputType.number,
            ),
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
        ),
      ),
    );
  }
}
