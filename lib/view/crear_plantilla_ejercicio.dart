import 'package:flutter/material.dart';
import 'package:myapp/database/db_helper.dart';
import 'package:myapp/model/plantilla_ejercicio.dart';

// Pantalla visual de creación de plantilla de ejercicio (con funcionalidad)
class CrearPlantillaScreen extends StatefulWidget {
  const CrearPlantillaScreen({super.key});

  @override
  State<CrearPlantillaScreen> createState() => _CrearPlantillaScreenState();
}

class _CrearPlantillaScreenState extends State<CrearPlantillaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();

  bool _trackSeries = false;
  bool _trackReps = false;
  bool _trackPeso = false;
  bool _trackDistancia = false;
  bool _trackTiempo = false;

  List<PlantillaEjercicio> _plantillas = [];

  @override
  void initState() {
    super.initState();
    _cargarPlantillas();
  }

  Future<void> _cargarPlantillas() async {
    final plantillas = await DBHelper.getPlantillas();
    setState(() {
      _plantillas = plantillas;
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  void _mostrarPopupPlantillas() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Plantillas existentes'),
          content: SizedBox(
            width: double.maxFinite,
            child:
                _plantillas.isEmpty
                    ? const Text('No hay plantillas registradas.')
                    : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _plantillas.length,
                      itemBuilder: (context, index) {
                        final plantilla = _plantillas[index];
                        return ListTile(
                          leading: const Icon(
                            Icons.list_alt,
                            color: Colors.deepPurple,
                          ),
                          title: Text(plantilla.nombre),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.deepPurple,
                            ),
                            tooltip: 'Editar plantilla',
                            onPressed: () async {
                              Navigator.pop(context); // Cierra el popup
                              await showDialog(
                                context: context,
                                builder: (context) {
                                  final nombreController =
                                      TextEditingController(
                                        text: plantilla.nombre,
                                      );
                                  bool trackSeries = plantilla.trackSeries;
                                  bool trackReps = plantilla.trackReps;
                                  bool trackPeso = plantilla.trackPeso;
                                  bool trackDistancia =
                                      plantilla.trackDistancia;
                                  bool trackTiempo = plantilla.trackTiempo;
                                  final editFormKey = GlobalKey<FormState>();

                                  return AlertDialog(
                                    title: const Text('Editar plantilla'),
                                    content: StatefulBuilder(
                                      builder: (context, setStateDialog) {
                                        return Form(
                                          key: editFormKey,
                                          child: SingleChildScrollView(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextFormField(
                                                  controller: nombreController,
                                                  decoration:
                                                      const InputDecoration(
                                                        labelText: 'Nombre',
                                                        border:
                                                            OutlineInputBorder(),
                                                      ),
                                                  validator:
                                                      (v) =>
                                                          (v == null ||
                                                                  v
                                                                      .trim()
                                                                      .isEmpty)
                                                              ? 'Ingresa un nombre'
                                                              : null,
                                                ),
                                                const SizedBox(height: 16),
                                                SwitchListTile(
                                                  title: const Text('Series'),
                                                  value: trackSeries,
                                                  onChanged:
                                                      (v) => setStateDialog(
                                                        () => trackSeries = v,
                                                      ),
                                                ),
                                                SwitchListTile(
                                                  title: const Text(
                                                    'Repeticiones',
                                                  ),
                                                  value: trackReps,
                                                  onChanged:
                                                      (v) => setStateDialog(
                                                        () => trackReps = v,
                                                      ),
                                                ),
                                                SwitchListTile(
                                                  title: const Text('Peso'),
                                                  value: trackPeso,
                                                  onChanged:
                                                      (v) => setStateDialog(
                                                        () => trackPeso = v,
                                                      ),
                                                ),
                                                SwitchListTile(
                                                  title: const Text(
                                                    'Distancia',
                                                  ),
                                                  value: trackDistancia,
                                                  onChanged:
                                                      (v) => setStateDialog(
                                                        () =>
                                                            trackDistancia = v,
                                                      ),
                                                ),
                                                SwitchListTile(
                                                  title: const Text('Tiempo'),
                                                  value: trackTiempo,
                                                  onChanged:
                                                      (v) => setStateDialog(
                                                        () => trackTiempo = v,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancelar'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          if (editFormKey.currentState
                                                  ?.validate() ??
                                              false) {
                                            final nuevoNombre =
                                                nombreController.text.trim();
                                            if (!(trackSeries ||
                                                trackReps ||
                                                trackPeso ||
                                                trackDistancia ||
                                                trackTiempo)) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Selecciona al menos un tipo de dato a medir.',
                                                  ),
                                                ),
                                              );
                                              return;
                                            }
                                            // Verifica si el nombre ya existe en otra plantilla
                                            final existeOtro = _plantillas.any(
                                              (p) =>
                                                  p.nombre.toLowerCase() ==
                                                      nuevoNombre
                                                          .toLowerCase() &&
                                                  p.id != plantilla.id,
                                            );
                                            if (existeOtro) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Ya existe una plantilla con ese nombre.',
                                                  ),
                                                ),
                                              );
                                              return;
                                            }
                                            final actualizada = plantilla
                                                .copyWith(
                                                  nombre: nuevoNombre,
                                                  trackSeries: trackSeries,
                                                  trackReps: trackReps,
                                                  trackPeso: trackPeso,
                                                  trackDistancia:
                                                      trackDistancia,
                                                  trackTiempo: trackTiempo,
                                                );
                                            await DBHelper.updatePlantilla(
                                              actualizada,
                                            );
                                            await _cargarPlantillas();
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(
                                              this.context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Plantilla actualizada',
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        child: const Text('Guardar'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _guardarPlantilla() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (!(_trackSeries ||
          _trackReps ||
          _trackPeso ||
          _trackDistancia ||
          _trackTiempo)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selecciona al menos un tipo de dato a medir.'),
          ),
        );
        return;
      }
      final nombre = _nombreController.text.trim();
      // Verifica si ya existe una plantilla con ese nombre (case-insensitive)
      final existe = _plantillas.any(
        (p) => p.nombre.toLowerCase() == nombre.toLowerCase(),
      );
      if (existe) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ya existe una plantilla con ese nombre.'),
          ),
        );
        return;
      }
      final plantilla = PlantillaEjercicio(
        nombre: nombre,
        trackSeries: _trackSeries,
        trackReps: _trackReps,
        trackPeso: _trackPeso,
        trackDistancia: _trackDistancia,
        trackTiempo: _trackTiempo,
      );
      await DBHelper.insertPlantilla(plantilla);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plantilla guardada correctamente')),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text(
          'Crear Plantilla de Ejercicio',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt, color: Colors.deepPurple),
            tooltip: 'Ver plantillas existentes',
            onPressed: _mostrarPopupPlantillas,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Nombre de la plantilla',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Ingresa un nombre'
                            : null,
              ),
              const SizedBox(height: 30),
              const Text(
                '¿Qué vas a medir?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                title: const Text('Series'),
                value: _trackSeries,
                onChanged: (v) => setState(() => _trackSeries = v),
              ),
              SwitchListTile(
                title: const Text('Repeticiones'),
                value: _trackReps,
                onChanged: (v) => setState(() => _trackReps = v),
              ),
              SwitchListTile(
                title: const Text('Peso'),
                value: _trackPeso,
                onChanged: (v) => setState(() => _trackPeso = v),
              ),
              SwitchListTile(
                title: const Text('Distancia'),
                value: _trackDistancia,
                onChanged: (v) => setState(() => _trackDistancia = v),
              ),
              SwitchListTile(
                title: const Text('Tiempo'),
                value: _trackTiempo,
                onChanged: (v) => setState(() => _trackTiempo = v),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text(
                    'Guardar Plantilla',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade500,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: _guardarPlantilla,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Volver'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
