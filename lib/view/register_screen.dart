import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import 'package:intl/intl.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _fechaNacimientoController =
      TextEditingController();

  Future<void> _registrarUsuario() async {
    if (_formKey.currentState!.validate()) {
      final usuario = _usuarioController.text.trim();
      final contrasena = _contrasenaController.text.trim();
      final correo = _correoController.text.trim();
      final fechaNacimientoStr = _fechaNacimientoController.text.trim();

      // Validar formato de fecha y calcular edad
      DateTime? fechaNacimiento;
      try {
        fechaNacimiento = DateFormat(
          'dd/MM/yyyy',
        ).parseStrict(fechaNacimientoStr);
      } catch (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Formato de fecha inválido. Usa dd/mm/aaaa'),
          ),
        );
        return;
      }
      final hoy = DateTime.now();
      int edad = hoy.year - fechaNacimiento.year;
      if (hoy.month < fechaNacimiento.month ||
          (hoy.month == fechaNacimiento.month &&
              hoy.day < fechaNacimiento.day)) {
        edad--;
      }
      if (edad < 0 || edad > 120) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Edad no válida.')));
        return;
      }

      // Validaciones adicionales
      if (usuario.length < 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El usuario debe tener al menos 3 caracteres.'),
          ),
        );
        return;
      }
      if (contrasena.length < 4) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La contraseña debe tener al menos 4 caracteres.'),
          ),
        );
        return;
      }
      if (!correo.contains('@') || !correo.contains('.')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Correo electrónico inválido.')),
        );
        return;
      }

      final existe = await DBHelper.existeUsuario(usuario);
      if (existe) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El usuario ya está registrado')),
        );
        return;
      }

      final fechaRegistro = DateTime.now().toIso8601String();

      await DBHelper.registerUser(
        username: usuario,
        password: contrasena,
        correoElectronico: correo,
        fechaRegistro: fechaRegistro,
        fechaNacimiento: fechaNacimientoStr,
        peso: 0.0, // Peso eliminado, pero requerido por el método
        edad: edad,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuario "$usuario" registrado con éxito')),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  'Crea una cuenta',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                _campo(
                  _usuarioController,
                  'Usuario',
                  Icons.person,
                  true,
                  minLength: 3,
                ),
                const SizedBox(height: 20),
                _campo(
                  _contrasenaController,
                  'Contraseña',
                  Icons.lock,
                  true,
                  obscure: true,
                  minLength: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo requerido';
                    }
                    if (value.length < 4) {
                      return 'La contraseña debe tener al menos 4 caracteres.';
                    }
                    if (value.contains(' ')) {
                      return 'La contraseña no puede contener espacios.';
                    }
                    if (value.trim().isEmpty) {
                      return 'La contraseña no puede estar vacía ni tener solo espacios.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _campo(
                  _correoController,
                  'Correo electrónico',
                  Icons.email,
                  true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Campo requerido';
                    }
                    final correo = value.trim();
                    // Separar usuario y dominio
                    final partes = correo.split('@');
                    if (partes.length != 2) {
                      return 'Debe contener un solo "@"';
                    }
                    final nombreUsuario = partes[0];
                    final dominio = partes[1];

                    // Validar nombre de usuario
                    if (nombreUsuario.length < 6) {
                      return 'El usuario debe tener al menos 6 caracteres antes de la @';
                    }
                    if (nombreUsuario.startsWith('.') ||
                        nombreUsuario.endsWith('.')) {
                      return 'El usuario no puede empezar o terminar con punto';
                    }
                    if (RegExp(r'[._-]{2,}').hasMatch(nombreUsuario)) {
                      return 'No se permiten caracteres especiales consecutivos en el usuario';
                    }
                    if (!RegExp(r'^[a-zA-Z0-9._-]+$').hasMatch(nombreUsuario)) {
                      return 'Solo letras, números, guion bajo (_), punto (.) y guion (-) en el usuario';
                    }
                    if (RegExp(r'[._-][^a-zA-Z0-9]').hasMatch(nombreUsuario)) {
                      return 'Caracteres especiales deben ir seguidos de letra o número en el usuario';
                    }

                    // Validar dominio
                    final dominioPartes = dominio.split('.');
                    if (dominioPartes.length < 2) {
                      return 'El dominio debe tener al menos un punto';
                    }
                    if (dominioPartes.any((parte) => parte.isEmpty)) {
                      return 'El dominio no puede tener partes vacías';
                    }
                    if (dominioPartes.any(
                      (parte) =>
                          !RegExp(r'^[a-zA-Z0-9-]+$').hasMatch(parte) ||
                          parte.startsWith('-') ||
                          parte.endsWith('-'),
                    )) {
                      return 'El dominio solo permite letras, números y guiones (no al inicio/fin)';
                    }
                    if (dominioPartes.last.length < 2) {
                      return 'El dominio debe terminar con al menos 2 letras';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _fechaNacimientoController,
                  decoration: const InputDecoration(
                    labelText: 'Fecha de nacimiento (dd/mm/aaaa)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                    hintText: 'Ejemplo: 25/12/2000',
                  ),
                  keyboardType: TextInputType.datetime,
                  maxLength: 10,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Campo requerido';
                    }
                    try {
                      DateFormat('dd/MM/yyyy').parseStrict(value);
                    } catch (_) {
                      return 'Formato de fecha inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: _registrarUsuario,
                  icon: const Icon(Icons.check),
                  label: const Text("Registrar"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _campo(
    TextEditingController controller,
    String label,
    IconData icon,
    bool requerido, {
    bool obscure = false,
    int minLength = 0,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      obscureText: obscure,
      validator:
          validator ??
          (value) {
            if (requerido && (value == null || value.trim().isEmpty)) {
              return 'Campo requerido';
            }
            if (minLength > 0 && value!.length < minLength) {
              return 'Debe tener al menos $minLength caracteres';
            }
            return null;
          },
    );
  }
}
