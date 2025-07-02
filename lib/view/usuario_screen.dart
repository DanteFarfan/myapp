import 'package:flutter/material.dart';
import 'package:myapp/model/usuario.dart';
import 'package:myapp/database/db_helper.dart';
import 'package:intl/intl.dart';

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
    int edadCalculada = _usuario.edad;

    void actualizarEdad() {
      try {
        final fecha = DateTime.parse(nacimientoController.text);
        final hoy = DateTime.now();
        int edad = hoy.year - fecha.year;
        if (hoy.month < fecha.month ||
            (hoy.month == fecha.month && hoy.day < fecha.day)) {
          edad--;
        }
        edadCalculada = edad;
      } catch (_) {
        edadCalculada = 0;
      }
    }

    actualizarEdad();

    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => StatefulBuilder(
            builder:
                (context, setStateDialog) => AlertDialog(
                  title: const Text('Editar datos de usuario'),
                  content: SingleChildScrollView(
                    child: Column(
                      children: [
                        _campoTexto(nombreController, 'Nombre de usuario'),
                        _campoTexto(correoController, 'Correo electrónico'),
                        TextField(
                          controller: nacimientoController,
                          decoration: const InputDecoration(
                            labelText: 'Fecha de nacimiento (dd/mm/aaaa)',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setStateDialog(() {
                              // No mostrar ni recalcular edad aquí
                            });
                          },
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
          ),
    );

    if (confirm == true) {
      final db = await DBHelper.getDB();

      // Calcula la edad correctamente al guardar
      int edadCalculada = 0;
      try {
        final fecha = DateTime.parse(nacimientoController.text);
        final hoy = DateTime.now();
        int edad = hoy.year - fecha.year;
        if (hoy.month < fecha.month ||
            (hoy.month == fecha.month && hoy.day < fecha.day)) {
          edad--;
        }
        edadCalculada = edad;
      } catch (_) {
        edadCalculada = 0;
      }

      final nuevosDatos = <String, Object>{
        'username': nombreController.text.trim(),
        'correo_electronico': correoController.text.trim(),
        'fecha_nacimiento': nacimientoController.text.trim(),
        'edad': edadCalculada,
      };

      await db.update(
        DBHelper.tablaUsuarios,
        nuevosDatos,
        where: 'id = ?',
        whereArgs: [_usuario.id],
      );

      setState(() {
        // Calcula la edad usando la fecha de nacimiento actualizada
        int edadActualizada = 0;
        try {
          DateTime fechaNac;
          // Intenta parsear en ambos formatos
          if (_esFechaISO(nuevosDatos['fecha_nacimiento'] as String)) {
            fechaNac = DateTime.parse(
              nuevosDatos['fecha_nacimiento'] as String,
            );
          } else {
            fechaNac = DateFormat(
              'dd/MM/yyyy',
            ).parseStrict(nuevosDatos['fecha_nacimiento'] as String);
          }
          final hoy = DateTime.now();
          int edad = hoy.year - fechaNac.year;
          if (hoy.month < fechaNac.month ||
              (hoy.month == fechaNac.month && hoy.day < fechaNac.day)) {
            edad--;
          }
          edadActualizada = edad;
        } catch (_) {
          edadActualizada = 0;
        }

        _usuario = Usuario(
          id: _usuario.id,
          username: nuevosDatos['username'] as String,
          correoElectronico: nuevosDatos['correo_electronico'] as String,
          fechaNacimiento: nuevosDatos['fecha_nacimiento'] as String,
          peso: _usuario.peso,
          edad: edadActualizada,
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
    // Formatea la fecha de registro a dd/mm/aaaa
    String fechaRegistroFormateada = '-';
    try {
      final fecha = DateTime.parse(_usuario.fechaRegistro);
      fechaRegistroFormateada = DateFormat('dd/MM/yyyy').format(fecha);
    } catch (_) {
      fechaRegistroFormateada = _usuario.fechaRegistro;
    }

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
              _info('Edad', _usuario.edad.toString()),
              _info('Registrado el', fechaRegistroFormateada),
            ],
          ),
        ),
      ),
    );
  }

  bool _esFechaISO(String fecha) {
    // Verifica si la fecha es tipo aaaa-mm-dd
    final isoReg = RegExp(r'^\d{4}-\d{2}-\d{2}');
    return isoReg.hasMatch(fecha);
  }
}
