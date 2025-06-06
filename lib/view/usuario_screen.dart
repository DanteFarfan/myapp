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

  void _editarUsuario(BuildContext context) async {
    final controller = TextEditingController(text: usuario.username);

    final nuevoUsername = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Editar nombre de usuario'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Nuevo nombre'),
            ),
            actions: [
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                child: const Text('Guardar'),
                onPressed: () => Navigator.pop(context, controller.text),
              ),
            ],
          ),
    );

    if (nuevoUsername != null &&
        nuevoUsername != usuario.username &&
        nuevoUsername.trim().isNotEmpty) {
      final db = await DBHelper.getDB();
      await db.update(
        DBHelper.tablaUsuarios,
        {'username': nuevoUsername},
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
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.account_circle,
                size: 120,
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 30),
              Text(
                usuario.username,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'ID: ${usuario.id}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
