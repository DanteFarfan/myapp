import 'package:flutter/material.dart';
import 'package:myapp/model/usuario.dart';

class UsuarioScreen extends StatelessWidget {
  final Usuario usuario;

  const UsuarioScreen({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de Usuario'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person, size: 100, color: Colors.deepPurple),
            const SizedBox(height: 20),
            Text(
              'Nombre: ${usuario.username}',
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
