import 'package:flutter/material.dart';

class SeguimientoMedidasScreen extends StatelessWidget {
  const SeguimientoMedidasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seguimiento de Medidas'),
        backgroundColor: Colors.deepPurple,
      ),
      body: const Center(
        child: Text('Aquí irá el seguimiento de medidas.'),
      ),
    );
  }
}