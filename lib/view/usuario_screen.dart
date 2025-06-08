import 'package:flutter/material.dart';
import 'package:myapp/model/usuario.dart';
import 'package:myapp/database/db_helper.dart';

class UsuarioScreen extends StatefulWidget {
  final Usuario usuario;

  const UsuarioScreen({super.key, required this.usuario});

  @override
  State<UsuarioScreen> createState() => _UsuarioScreenState();
}

class _UsuarioScreenState extends State<UsuarioScreen> {
  late Usuario _usuario;

  @override
  void initState() {
    super.initState();
    _usuario = widget.usuario;
  }

  void _cerrarSesion() async {
    await DBHelper.logoutUser();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  void _editarUsuario() async {
    final nombreController = TextEditingController(text: _usuario.username);
    final correoController = TextEditingController(
      text: _usuario.correoElectronico,
    );
    final nacimientoController = TextEditingController(
      text: _usuario.fechaNacimiento,
    );
    final pesoController = TextEditingController(
      text: _usuario.peso.toString(),
    );
    final edadController = TextEditingController(
      text: _usuario.edad.toString(),
    );

    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Editar datos de usuario'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  _campoTexto(nombreController, 'Nombre de usuario'),
                  _campoTexto(correoController, 'Correo electrónico'),
                  _campoTexto(
                    nacimientoController,
                    'Fecha de nacimiento (AAAA-MM-DD)',
                  ),
                  _campoTexto(pesoController, 'Peso (kg)', isNumber: true),
                  _campoTexto(edadController, 'Edad', isNumber: true),
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

    if (confirm == true) {
      final db = await DBHelper.getDB();

      final nuevosDatos = <String, Object>{
        'username': nombreController.text.trim(),
        'correo_electronico': correoController.text.trim(),
        'fecha_nacimiento': nacimientoController.text.trim(),
        'peso': double.tryParse(pesoController.text.trim()) ?? 0.0,
        'edad': int.tryParse(edadController.text.trim()) ?? 0,
      };

      await db.update(
        DBHelper.tablaUsuarios,
        nuevosDatos,
        where: 'id = ?',
        whereArgs: [_usuario.id],
      );

      setState(() {
        _usuario = Usuario(
          id: _usuario.id,
          username: nuevosDatos['username'] as String,
          correoElectronico: nuevosDatos['correo_electronico'] as String,
          fechaNacimiento: nuevosDatos['fecha_nacimiento'] as String,
          peso: nuevosDatos['peso'] as double,
          edad: nuevosDatos['edad'] as int,
          fechaRegistro: _usuario.fechaRegistro,
          password: _usuario.password,
          activo: _usuario.activo,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Datos actualizados exitosamente')),
      );
    }
  }

  void _eliminarCuenta() async {
    final confirmacion = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Eliminar cuenta'),
            content: const Text(
              '¿Estás seguro de que deseas eliminar tu cuenta? Esta acción no se puede deshacer.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );

    if (confirmacion == true) {
      final db = await DBHelper.getDB();
      await db.delete(
        DBHelper.tablaUsuarios,
        where: 'id = ?',
        whereArgs: [_usuario.id],
      );
      await DBHelper.logoutUser();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }

  void _handleMenu(String opcion) {
    switch (opcion) {
      case 'editar':
        _editarUsuario();
        break;
      case 'eliminar':
        _eliminarCuenta();
        break;
    }
  }

  Widget _campoTexto(
    TextEditingController controller,
    String label, {
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _info(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value ?? '-', style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
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
          IconButton(icon: const Icon(Icons.logout), onPressed: _cerrarSesion),
          PopupMenuButton<String>(
            onSelected: _handleMenu,
            icon: const Icon(Icons.more_vert, color: Colors.white),
            itemBuilder:
                (_) => const [
                  PopupMenuItem(value: 'editar', child: Text('Editar usuario')),
                  PopupMenuItem(
                    value: 'eliminar',
                    child: Text('Eliminar cuenta'),
                  ),
                ],
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Icon(
                  Icons.account_circle,
                  size: 100,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 20),
              _info('ID', _usuario.id.toString()),
              _info('Usuario', _usuario.username),
              _info('Correo', _usuario.correoElectronico),
              _info('Nacimiento', _usuario.fechaNacimiento),
              _info('Peso', _usuario.peso.toString()),
              _info('Edad', _usuario.edad.toString()),
              _info('Registrado el', _usuario.fechaRegistro),
            ],
          ),
        ),
      ),
    );
  }
}
