import 'package:flutter/material.dart';

// Pantalla visual de creación de plantilla de ejercicio (con funcionalidad)
class CrearPlantillaScreen extends StatefulWidget {
  const CrearPlantillaScreen({super.key});

  @override
  State<CrearPlantillaScreen> createState() => _CrearPlantillaScreenState();
}

class _CrearPlantillaScreenState extends State<CrearPlantillaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();

  bool _trackSeries = false;
  bool _trackReps = false;
  bool _trackPeso = false;
  bool _trackDistancia = false;
  bool _trackTiempo = false;

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  void _guardarPlantilla() {
    if (_formKey.currentState?.validate() ?? false) {
      if (!(_trackSeries || _trackReps || _trackPeso || _trackDistancia || _trackTiempo)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecciona al menos un tipo de dato a medir.')),
        );
        return;
      }
      // Aquí puedes guardar la plantilla en la base de datos si lo deseas
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plantilla guardada correctamente')),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text(
          'Crear Plantilla de Ejercicio',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Nombre de la plantilla',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa un nombre' : null,
              ),
              const SizedBox(height: 30),
              const Text(
                '¿Qué vas a medir?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                title: const Text('Series'),
                value: _trackSeries,
                onChanged: (v) => setState(() => _trackSeries = v),
              ),
              SwitchListTile(
                title: const Text('Repeticiones'),
                value: _trackReps,
                onChanged: (v) => setState(() => _trackReps = v),
              ),
              SwitchListTile(
                title: const Text('Peso'),
                value: _trackPeso,
                onChanged: (v) => setState(() => _trackPeso = v),
              ),
              SwitchListTile(
                title: const Text('Distancia'),
                value: _trackDistancia,
                onChanged: (v) => setState(() => _trackDistancia = v),
              ),
              SwitchListTile(
                title: const Text('Tiempo'),
                value: _trackTiempo,
                onChanged: (v) => setState(() => _trackTiempo = v),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text(
                    'Guardar Plantilla',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade500,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: _guardarPlantilla,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Volver'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
