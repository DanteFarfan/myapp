import 'package:flutter/material.dart';
import 'package:myapp/view/home_screen.dart';

class PlanNutricionScreen extends StatelessWidget {
  const PlanNutricionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan de Nutrición'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: ElevatedButton.icon(
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
      ),
    );
  }
}