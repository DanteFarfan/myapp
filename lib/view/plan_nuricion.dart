import 'package:flutter/material.dart';
import 'package:myapp/view/home_screen.dart';
import 'package:myapp/model/plan_nutricion.dart';
import 'package:myapp/database/db_helper.dart';

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
  PlanNutricion? _planNutricion; // Instancia para guardar los datos

  @override
  void initState() {
    super.initState();
    _cargarPlanGuardado();
  }

  Future<void> _cargarPlanGuardado() async {
    final plan = await DBHelper.getPlanNutricionUsuarioActivo();
    if (plan != null) {
      setState(() {
        _planNutricion = plan;
        _pesoController.text = plan.peso.toString();
        _alturaController.text = plan.altura.toString();
        _edadController.text = plan.edad.toString();
        _genero = plan.genero;
        _objetivo = plan.objetivo;
        _calorias = plan.calorias;
      });
    }
  }

  void _calcularCalorias() async {
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

      final plan = PlanNutricion(
        peso: peso,
        altura: altura,
        edad: edad,
        genero: _genero,
        objetivo: _objetivo,
        calorias: calorias,
      );

      await DBHelper.savePlanNutricion(plan);

      setState(() {
        _calorias = calorias;
        _planNutricion = plan;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Si hay datos guardados, autocompleta los campos (esto es útil si vuelves a la pantalla)
    if (_planNutricion != null) {
      _pesoController.text = _planNutricion!.peso.toString();
      _alturaController.text = _planNutricion!.altura.toString();
      _edadController.text = _planNutricion!.edad.toString();
      _genero = _planNutricion!.genero;
      _objetivo = _planNutricion!.objetivo;
      _calorias = _planNutricion!.calorias;
    }

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
                    child: const Text(
                      'Calcular calorías',
                      style: TextStyle(color: Colors.white, fontSize: 16), // Más contraste
                    ),
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
                  if (_planNutricion != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        'Datos guardados:\n'
                        'Peso: ${_planNutricion!.peso} kg, '
                        'Altura: ${_planNutricion!.altura} cm, '
                        'Edad: ${_planNutricion!.edad}, '
                        'Género: ${_planNutricion!.genero}, '
                        'Objetivo: ${_planNutricion!.objetivo}',
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.home, color: Colors.white),
              label: const Text(
                'Volver al inicio',
                style: TextStyle(color: Colors.white, fontSize: 16), // Más contraste
              ),
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