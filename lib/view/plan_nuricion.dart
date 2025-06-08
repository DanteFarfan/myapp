import 'package:flutter/material.dart';
import 'package:myapp/view/home_screen.dart';

class PlanNutricionScreen extends StatefulWidget {
  const PlanNutricionScreen({super.key});

  @override
  State<PlanNutricionScreen> createState() => _PlanNutricionScreenState();
}

class _PlanNutricionScreenState extends State<PlanNutricionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _alturaController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  String _genero = 'Masculino';
  String _objetivo = 'Bajar de peso';
  double? _calorias;

  void _calcularCalorias() {
    if (_formKey.currentState!.validate()) {
      final peso = double.parse(_pesoController.text);
      final altura = double.parse(_alturaController.text);
      final edad = int.parse(_edadController.text);

      // Fórmula de Harris-Benedict (simplificada)
      double tmb;
      if (_genero == 'Masculino') {
        tmb = 88.36 + (13.4 * peso) + (4.8 * altura) - (5.7 * edad);
      } else {
        tmb = 447.6 + (9.2 * peso) + (3.1 * altura) - (4.3 * edad);
      }

      // Ajuste según objetivo
      double calorias;
      if (_objetivo == 'Bajar de peso') {
        calorias = tmb - 500;
      } else {
        calorias = tmb + 500;
      }

      setState(() {
        _calorias = calorias;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan de Nutrición'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _genero,
                    decoration: const InputDecoration(labelText: 'Género'),
                    items: const [
                      DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
                      DropdownMenuItem(value: 'Femenino', child: Text('Femenino')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _genero = value!;
                      });
                    },
                  ),
                  TextFormField(
                    controller: _pesoController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Peso (kg)'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Ingrese su peso' : null,
                  ),
                  TextFormField(
                    controller: _alturaController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Altura (cm)'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Ingrese su altura' : null,
                  ),
                  TextFormField(
                    controller: _edadController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Edad'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Ingrese su edad' : null,
                  ),
                  DropdownButtonFormField<String>(
                    value: _objetivo,
                    decoration: const InputDecoration(labelText: 'Objetivo'),
                    items: const [
                      DropdownMenuItem(value: 'Bajar de peso', child: Text('Bajar de peso')),
                      DropdownMenuItem(value: 'Subir de peso', child: Text('Subir de peso')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _objetivo = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _calcularCalorias,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                    ),
                    child: const Text('Calcular calorías'),
                  ),
                  const SizedBox(height: 20),
                  if (_calorias != null)
                    Text(
                      'Calorías recomendadas por día: ${_calorias!.toStringAsFixed(0)} kcal',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.home),
              label: const Text('Volver al inicio'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}