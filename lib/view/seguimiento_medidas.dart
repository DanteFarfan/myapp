import 'package:flutter/material.dart';
import 'package:myapp/model/seguimiento_medidas.dart';
import 'package:myapp/database/db_helper.dart';

class SeguimientoMedidasScreen extends StatefulWidget {
  const SeguimientoMedidasScreen({super.key});

  @override
  State<SeguimientoMedidasScreen> createState() =>
      _SeguimientoMedidasScreenState();
}

class _SeguimientoMedidasScreenState extends State<SeguimientoMedidasScreen> {
  List<Medida> historial = [];

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  Future<void> _cargarHistorial() async {
    final medidas = await DBHelper.getMedidasUsuarioActivo();
    setState(() {
      historial = medidas;
    });
  }

  Future<void> _agregarMedida({Medida? medidaEditar}) async {
    final nombreController = TextEditingController(
      text: medidaEditar?.nombre ?? '',
    );
    final descripcionController = TextEditingController(
      text: medidaEditar?.descripcion ?? '',
    );
    final valorController = TextEditingController(
      text: medidaEditar != null ? medidaEditar.valor.toString() : '',
    );
    String unidad = medidaEditar?.unidad ?? 'kg';

    String? errorNombre;

    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setStateDialog) => AlertDialog(
                  title: Text(
                    medidaEditar == null ? 'Nueva medida' : 'Editar medida',
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nombreController,
                          decoration: InputDecoration(
                            labelText: 'Nombre',
                            errorText: errorNombre,
                          ),
                          enabled:
                              medidaEditar ==
                              null, // No permitir editar el nombre si es edición
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: descripcionController,
                          decoration: const InputDecoration(
                            labelText: 'Descripción',
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: valorController,
                          decoration: const InputDecoration(labelText: 'Valor'),
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: unidad,
                          items: const [
                            DropdownMenuItem(value: 'kg', child: Text('kg')),
                            DropdownMenuItem(value: 'cm', child: Text('cm')),
                          ],
                          onChanged: (value) {
                            if (value != null) unidad = value;
                          },
                          decoration: const InputDecoration(
                            labelText: 'Unidad',
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    if (medidaEditar != null)
                      TextButton(
                        onPressed: () async {
                          final confirmDelete = await showDialog<bool>(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: const Text('Eliminar medida'),
                                  content: const Text(
                                    '¿Seguro que deseas eliminar esta medida y todo su historial? Esta acción no se puede deshacer.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(context, false),
                                      child: const Text('Cancelar'),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      onPressed:
                                          () => Navigator.pop(context, true),
                                      child: const Text('Eliminar'),
                                    ),
                                  ],
                                ),
                          );
                          if (confirmDelete == true) {
                            final usuario = await DBHelper.getUsuarioActivo();
                            if (usuario != null) {
                              await DBHelper.deleteMedidasPorNombre(
                                usuario.id,
                                medidaEditar.nombre,
                              );
                              Navigator.pop(
                                context,
                                false,
                              ); // Cierra el diálogo de edición
                              _cargarHistorial();
                            }
                          }
                        },
                        child: const Text(
                          'Eliminar',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final nombre = nombreController.text.trim();
                        final valor = valorController.text.trim();
                        double? valorNum = double.tryParse(valor);

                        if (nombre.isEmpty || valor.isEmpty) {
                          setStateDialog(() {
                            errorNombre =
                                nombre.isEmpty ? 'Campo requerido' : null;
                          });
                          return;
                        }
                        if (valorNum == null || valorNum < 0) {
                          setStateDialog(() {
                            errorNombre = null;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'El valor no puede ser negativo ni estar vacío.',
                              ),
                            ),
                          );
                          return;
                        }
                        // Validar nombre único solo al crear
                        if (medidaEditar == null) {
                          final existe = historial.any(
                            (m) =>
                                m.nombre.toLowerCase() == nombre.toLowerCase(),
                          );
                          if (existe) {
                            setStateDialog(() {
                              errorNombre =
                                  'Ya existe una medida con ese nombre';
                            });
                            return;
                          }
                        }
                        Navigator.pop(context, true);
                      },
                      child: const Text('Guardar'),
                    ),
                  ],
                ),
          ),
    );

    if (confirm == true) {
      final usuario = await DBHelper.getUsuarioActivo();
      if (usuario == null) return;
      final nuevaMedida = Medida(
        id: null,
        idUsuario: usuario.id,
        nombre: nombreController.text.trim(),
        descripcion: descripcionController.text.trim(),
        valor: double.tryParse(valorController.text.trim()) ?? 0,
        unidad: unidad,
        fecha: DateTime.now(),
      );
      await DBHelper.insertMedida(nuevaMedida);
      _cargarHistorial();
    }
  }

  Future<void> _mostrarHistorialMedida(Medida medida) async {
    final usuario = await DBHelper.getUsuarioActivo();
    if (usuario == null) return;

    // Obtén todas las versiones históricas de la medida desde la base de datos
    final db = await DBHelper.getDB();
    final maps = await db.query(
      DBHelper.tablaMedidas,
      where: 'id_usuario = ? AND LOWER(nombre) = ?',
      whereArgs: [usuario.id, medida.nombre.toLowerCase()],
      orderBy: 'fecha DESC',
    );
    final historialMedida = maps.map((e) => Medida.fromMap(e)).toList();

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Historial de "${medida.nombre}"'),
            content: SizedBox(
              width: double.maxFinite,
              child:
                  historialMedida.isEmpty
                      ? const Text('No hay historial para esta medida.')
                      : ListView.builder(
                        shrinkWrap: true,
                        itemCount: historialMedida.length,
                        itemBuilder: (context, i) {
                          final m = historialMedida[i];
                          return ListTile(
                            title: Text('${m.valor} ${m.unidad}'),
                            subtitle: Text(
                              '${m.descripcion}\nFecha: ${m.fecha.day.toString().padLeft(2, '0')}/${m.fecha.month.toString().padLeft(2, '0')}/${m.fecha.year}',
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
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Colores igual que HomeScreen
    const fondo = Color(0xFFF4F4F4);
    const colorPrincipal = Colors.deepPurple;
    const colorTexto = Colors.black;

    // Agrupa por nombre y muestra solo la más reciente
    final Map<String, Medida> ultimasMedidas = {};
    for (final m in historial) {
      if (!ultimasMedidas.containsKey(m.nombre) ||
          m.fecha.isAfter(ultimasMedidas[m.nombre]!.fecha)) {
        ultimasMedidas[m.nombre] = m;
      }
    }
    final medidasMostrar =
        ultimasMedidas.values.toList()
          ..sort((a, b) => b.fecha.compareTo(a.fecha));

    return Scaffold(
      backgroundColor: fondo,
      appBar: AppBar(
        title: const Text(
          'Seguimiento de Medidas',
          style: TextStyle(color: colorTexto, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: colorTexto),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: () => _agregarMedida(),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Agregar medida',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorPrincipal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child:
                  medidasMostrar.isEmpty
                      ? const Center(
                        child: Text(
                          'No hay medidas registradas.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                      : ListView.builder(
                        itemCount: medidasMostrar.length,
                        itemBuilder: (context, i) {
                          final m = medidasMostrar[i];
                          return Card(
                            color: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            margin: const EdgeInsets.symmetric(
                              horizontal: 0,
                              vertical: 6,
                            ),
                            child: ListTile(
                              title: Text(
                                '${m.nombre} (${m.valor} ${m.unidad})',
                                style: const TextStyle(
                                  color: colorTexto,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${m.descripcion}\nFecha: ${m.fecha.day.toString().padLeft(2, '0')}/${m.fecha.month.toString().padLeft(2, '0')}/${m.fecha.year}',
                                style: const TextStyle(color: colorTexto),
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: colorPrincipal,
                                ),
                                onPressed:
                                    () => _agregarMedida(medidaEditar: m),
                                tooltip: 'Editar',
                              ),
                              onTap: () => _mostrarHistorialMedida(m),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
