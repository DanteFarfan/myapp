import 'package:flutter/material.dart';
import '../database/db_helper.dart';

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
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();

  Future<void> _registrarUsuario() async {
    if (_formKey.currentState!.validate()) {
      final usuario = _usuarioController.text.trim();
      final contrasena = _contrasenaController.text.trim();

      final correo = _correoController.text.trim();
      final fechaNacimiento = _fechaNacimientoController.text.trim();
      final peso = double.tryParse(_pesoController.text.trim()) ?? 0.0;
      final edad = int.tryParse(_edadController.text.trim()) ?? 0;

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
        fechaNacimiento: fechaNacimiento,
        peso: peso,
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
                _campo(_usuarioController, 'Usuario', Icons.person, true),
                const SizedBox(height: 20),
                _campo(
                  _contrasenaController,
                  'Contraseña',
                  Icons.lock,
                  true,
                  obscure: true,
                  minLength: 4,
                ),
                const SizedBox(height: 20),
                _campo(
                  _correoController,
                  'Correo electrónico',
                  Icons.email,
                  false,
                ),
                const SizedBox(height: 20),
                _campo(
                  _fechaNacimientoController,
                  'Fecha de nacimiento (AAAA-MM-DD)',
                  Icons.calendar_today,
                  false,
                ),
                const SizedBox(height: 20),
                _campo(
                  _pesoController,
                  'Peso (kg)',
                  Icons.monitor_weight,
                  false,
                ),
                const SizedBox(height: 20),
                _campo(_edadController, 'Edad', Icons.cake, false),
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
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      obscureText: obscure,
      validator: (value) {
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
