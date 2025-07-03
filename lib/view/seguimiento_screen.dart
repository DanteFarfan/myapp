import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:myapp/database/db_helper.dart';
import 'package:myapp/model/seguimiento.dart';

enum TipoDato { series, reps, peso, tiempo, distancia }

extension TipoDatoExtension on TipoDato {
  String get nombre {
    switch (this) {
      case TipoDato.series:
        return 'Series';
      case TipoDato.reps:
        return 'Repeticiones';
      case TipoDato.peso:
        return 'Peso (kg)';
      case TipoDato.tiempo:
        return 'Tiempo (min)';
      case TipoDato.distancia:
        return 'Distancia (km)';
    }
  }

  String get keyRecord {
    // Valores que coinciden con el campo tipoRecord en la DB
    switch (this) {
      case TipoDato.series:
        return 'series';
      case TipoDato.reps:
        return 'reps';
      case TipoDato.peso:
        return 'peso';
      case TipoDato.tiempo:
        return 'tiempo';
      case TipoDato.distancia:
        return 'distancia';
    }
  }
}

class SeguimientoScreen extends StatefulWidget {
  const SeguimientoScreen({super.key});

  @override
  State<SeguimientoScreen> createState() => _SeguimientoScreenState();
}

class _SeguimientoScreenState extends State<SeguimientoScreen> {
  List<FlSpot> spots = [];
  List<double> valores = [];
  List<String> fechas = [];
  TipoDato tipoSeleccionado = TipoDato.peso;
  String? _errorMsg; // <-- Agrega esta variable

  @override
  void initState() {
    super.initState();
    cargarDatosSeguimiento();
  }

  Future<void> cargarDatosSeguimiento() async {
    final usuario = await DBHelper.getUsuarioActivo();
    if (usuario == null) {
      setState(() {
        spots = [];
        valores = [];
        fechas = [];
        _errorMsg = 'No hay usuario activo.';
      });
      return;
    }

    // Obtener todos los registros de seguimiento del usuario
    List<Seguimiento> todosRecords = await DBHelper.getSeguimientoPorUsuario(
      usuario.id,
    );

    // Si no hay registros de seguimiento, intenta generarlos a partir de DatosEntrenamiento
    if (todosRecords.isEmpty) {
      final entrenamientos = await DBHelper.getEntrenamientosDelUsuario(
        usuario.id,
      );

      for (final e in entrenamientos) {
        final now = DateTime.now().toIso8601String();
        if (e.series != null) {
          await DBHelper.insertSeguimiento(
            Seguimiento(
              idUsuario: usuario.id,
              idEntrenamiento: e.id,
              fechaEntrenamiento: now,
              tipoRecord: 'series',
              valorRecord: e.series!.toDouble(),
            ),
          );
        }
        if (e.reps != null) {
          await DBHelper.insertSeguimiento(
            Seguimiento(
              idUsuario: usuario.id,
              idEntrenamiento: e.id,
              fechaEntrenamiento: now,
              tipoRecord: 'reps',
              valorRecord: e.reps!.toDouble(),
            ),
          );
        }
        if (e.peso != null) {
          await DBHelper.insertSeguimiento(
            Seguimiento(
              idUsuario: usuario.id,
              idEntrenamiento: e.id,
              fechaEntrenamiento: now,
              tipoRecord: 'peso',
              valorRecord: e.peso!,
            ),
          );
        }
        if (e.tiempo != null && double.tryParse(e.tiempo!) != null) {
          await DBHelper.insertSeguimiento(
            Seguimiento(
              idUsuario: usuario.id,
              idEntrenamiento: e.id,
              fechaEntrenamiento: now,
              tipoRecord: 'tiempo',
              valorRecord: double.parse(e.tiempo!),
            ),
          );
        }
        if (e.distancia != null) {
          await DBHelper.insertSeguimiento(
            Seguimiento(
              idUsuario: usuario.id,
              idEntrenamiento: e.id,
              fechaEntrenamiento: now,
              tipoRecord: 'distancia',
              valorRecord: e.distancia!,
            ),
          );
        }
      }

      // Recarga los registros de seguimiento después de insertarlos
      todosRecords = await DBHelper.getSeguimientoPorUsuario(usuario.id);
    }

    // Filtrar por el tipo seleccionado
    final List<Seguimiento> registrosFiltrados =
        todosRecords
            .where(
              (r) => r.tipoRecord.toLowerCase() == tipoSeleccionado.keyRecord,
            )
            .toList();

    if (registrosFiltrados.isEmpty) {
      setState(() {
        spots = [];
        valores = [];
        fechas = [];
        _errorMsg = 'No hay datos para mostrar para el tipo seleccionado.\n';
      });
      return;
    }

    // Ordenar por fecha
    registrosFiltrados.sort(
      (a, b) => DateTime.parse(
        a.fechaEntrenamiento,
      ).compareTo(DateTime.parse(b.fechaEntrenamiento)),
    );

    setState(() {
      valores = registrosFiltrados.map((r) => r.valorRecord).toList();
      fechas =
          registrosFiltrados
              .map(
                (r) =>
                    DateTime.parse(
                      r.fechaEntrenamiento,
                    ).toIso8601String().split('T').first,
              )
              .toList();
      spots = List.generate(
        valores.length,
        (i) => FlSpot(i.toDouble() + 1, valores[i]),
      );
      _errorMsg = null;
    });
  }

  void cambiarTipoDato(TipoDato nuevoTipo) {
    setState(() {
      tipoSeleccionado = nuevoTipo;
    });
    cargarDatosSeguimiento();
  }

  @override
  Widget build(BuildContext context) {
    final double ultimoValor = valores.isNotEmpty ? valores.last : 0;
    final double promedio =
        valores.isNotEmpty
            ? valores.reduce((a, b) => a + b) / valores.length
            : 0;
    final double variacion =
        valores.length > 1 ? valores.last - valores.first : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seguimiento de Entrenamientos'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<TipoDato>(
              value: tipoSeleccionado,
              items:
                  TipoDato.values
                      .map(
                        (tipo) => DropdownMenuItem(
                          value: tipo,
                          child: Text(tipo.nombre),
                        ),
                      )
                      .toList(),
              onChanged: (nuevo) {
                if (nuevo != null) cambiarTipoDato(nuevo);
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Evolución de ${tipoSeleccionado.nombre}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child:
                  valores.isEmpty
                      ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            _errorMsg ?? 'No hay datos para mostrar.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      )
                      : Center(
                        // Centra el gráfico horizontal y verticalmente
                        child: AspectRatio(
                          aspectRatio:
                              0.6, // Cambia este valor para ajustar el tamaño del gráfico
                          child: LineChart(
                            LineChartData(
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 18,
                                    interval: null,
                                    getTitlesWidget: (value, meta) {
                                      // Mostrar los números en horizontal, no en vertical
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          right: 2,
                                        ),
                                        child: Text(
                                          value.toStringAsFixed(0),
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, _) {
                                      int index = value.toInt() - 1;
                                      return Text(
                                        index >= 0 && index < fechas.length
                                            ? fechas[index].substring(5)
                                            : '',
                                        style: const TextStyle(fontSize: 10),
                                      );
                                    },
                                    interval: 1,
                                  ),
                                ),
                              ),
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: true,
                                horizontalInterval:
                                    valores.length > 1
                                        ? ((valores.reduce(
                                                  (a, b) => a > b ? a : b,
                                                ) -
                                                valores.reduce(
                                                  (a, b) => a < b ? a : b,
                                                )) /
                                            5)
                                        : 1,
                                getDrawingHorizontalLine:
                                    (value) => FlLine(
                                      color: Colors.deepPurple.withOpacity(
                                        0.08,
                                      ),
                                      strokeWidth: 1,
                                    ),
                                getDrawingVerticalLine:
                                    (value) => FlLine(
                                      color: Colors.deepPurple.withOpacity(
                                        0.08,
                                      ),
                                      strokeWidth: 1,
                                    ),
                              ),
                              borderData: FlBorderData(
                                show: true,
                                border: Border.all(
                                  color: Colors.deepPurple.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: spots,
                                  isCurved: true,
                                  color: Colors.deepPurple,
                                  barWidth: 3,
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter:
                                        (spot, percent, bar, index) =>
                                            FlDotCirclePainter(
                                              radius: 4,
                                              color: Colors.deepPurple,
                                              strokeWidth: 2,
                                              strokeColor: Colors.white,
                                            ),
                                  ),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: Colors.deepPurple.withOpacity(0.15),
                                  ),
                                ),
                              ],
                              lineTouchData: LineTouchData(
                                touchTooltipData: LineTouchTooltipData(
                                  tooltipBgColor: Colors.deepPurple.shade100,
                                  getTooltipItems: (touchedSpots) {
                                    return touchedSpots.map((spot) {
                                      int idx = spot.spotIndex;
                                      return LineTooltipItem(
                                        '${fechas[idx]}: ${valores[idx].toStringAsFixed(2)}',
                                        const TextStyle(
                                          color: Colors.deepPurple,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    }).toList();
                                  },
                                ),
                                handleBuiltInTouches: true,
                              ),
                            ),
                          ),
                        ),
                      ),
            ),
            const SizedBox(height: 20),
            Text(
              'Resumen',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Text('• Último: ${ultimoValor.toStringAsFixed(1)}'),
            Text('• Promedio: ${promedio.toStringAsFixed(1)}'),
            Text('• Variación: ${variacion.toStringAsFixed(1)}'),
          ],
        ),
      ),
    );
  }
}
