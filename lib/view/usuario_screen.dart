import 'package:flutter/material.dart';
import 'package:myapp/model/usuario.dart';
import 'package:myapp/database/db_helper.dart';

class UsuarioScreen extends StatelessWidget {
  final Usuario usuario;

  const UsuarioScreen({super.key, required this.usuario});

  void _cerrarSesion(BuildContext context) async {
    await DBHelper.logoutUser();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  Future<void> _editarUsuario(BuildContext context) async {
    final nombreController = TextEditingController(text: usuario.nombre);
    final passwordController = TextEditingController(text: usuario.password);
    final correoController = TextEditingController(text: usuario.correo);
    final fechaNacController = TextEditingController(
      text: usuario.fechaNacimiento,
    );
    final pesoController = TextEditingController(text: usuario.peso.toString());
    final edadController = TextEditingController(text: usuario.edad.toString());

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Editar perfil'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: nombreController,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                  ),
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(labelText: 'Contraseña'),
                    obscureText: true,
                  ),
                  TextField(
                    controller: correoController,
                    decoration: const InputDecoration(labelText: 'Correo'),
                  ),
                  TextField(
                    controller: fechaNacController,
                    decoration: const InputDecoration(
                      labelText: 'Fecha de Nacimiento (YYYY-MM-DD)',
                    ),
                  ),
                  TextField(
                    controller: pesoController,
                    decoration: const InputDecoration(labelText: 'Peso (kg)'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: edadController,
                    decoration: const InputDecoration(labelText: 'Edad'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Guardar'),
              ),
            ],
          ),
    );

    if (result == true) {
      final nuevoNombre = nombreController.text.trim();
      final nuevaPassword = passwordController.text.trim();
      final nuevoCorreo = correoController.text.trim();
      final nuevaFechaNac = fechaNacController.text.trim();
      final nuevoPeso =
          double.tryParse(pesoController.text.trim()) ?? usuario.peso;
      final nuevaEdad =
          int.tryParse(edadController.text.trim()) ?? usuario.edad;

      final db = await DBHelper.getDB();
      await db.update(
        DBHelper.tablaUsuarios,
        {
          'nombre': nuevoNombre,
          'password': nuevaPassword,
          'correo': nuevoCorreo,
          'fecha_nacimiento': nuevaFechaNac,
          'peso': nuevoPeso,
          'edad': nuevaEdad,
        },
        where: 'id = ?',
        whereArgs: [usuario.id],
      );

      await DBHelper.logoutUser();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  void _eliminarCuenta(BuildContext context) async {
    final confirmacion = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Eliminar cuenta'),
            content: const Text(
              '¿Estás seguro de que deseas eliminar tu cuenta? Esta acción no se puede deshacer.',
            ),
            actions: [
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () => Navigator.pop(context, false),
              ),
              ElevatedButton(
                child: const Text('Eliminar'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
    );

    if (confirmacion == true) {
      final db = await DBHelper.getDB();
      await db.delete(
        DBHelper.tablaUsuarios,
        where: 'id = ?',
        whereArgs: [usuario.id],
      );
      await DBHelper.logoutUser();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  void _handleMenuSelection(BuildContext context, String choice) {
    switch (choice) {
      case 'editar':
        _editarUsuario(context);
        break;
      case 'eliminar':
        _eliminarCuenta(context);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Perfil de Usuario',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () => _cerrarSesion(context),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuSelection(context, value),
            icon: const Icon(Icons.more_vert, color: Colors.white),
            itemBuilder:
                (BuildContext context) => [
                  const PopupMenuItem(
                    value: 'editar',
                    child: Text('Editar usuario'),
                  ),
                  const PopupMenuItem(
                    value: 'eliminar',
                    child: Text('Eliminar cuenta'),
                  ),
                ],
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Icon(
                  Icons.account_circle,
                  size: 120,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'ID: ${usuario.id}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              Text(
                'Nombre: ${usuario.nombre}',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 10),
              Text(
                'Correo: ${usuario.correo}',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 10),
              Text(
                'Fecha de Registro: ${usuario.fechaRegistro}',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 10),
              Text(
                'Fecha de Nacimiento: ${usuario.fechaNacimiento}',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 10),
              Text(
                'Peso: ${usuario.peso} kg',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 10),
              Text(
                'Edad: ${usuario.edad}',
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
