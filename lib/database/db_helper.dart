import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/datos_entrenamiento.dart';
import '../model/usuario.dart';
import '../model/seguimiento.dart';
import '../model/plan_nutricion.dart';

class DBHelper {
  static Database? _db;
  static const String tabla = 'DatosEntrenamiento';
  static const String tablaUsuarios = 'Usuarios';
  static const String tablaSeguimiento = 'Seguimiento';
  static const String tablaPlanNutricion = 'PlanNutricion';
  static const String tablaHistorialPlanNutricion = 'HistorialPlanNutricion';

  @Deprecated('Usar con precaución, solo para pruebas')
  static Future<void> borrarBaseDeDatos() async {
    final dbPath = await getDatabasesPath();
    final fullPath = join(dbPath, 'fitness.db');
    await deleteDatabase(fullPath);
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'fitness.db');

    return openDatabase(
      path,
      version: 8,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tabla (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            titulo TEXT,
            descripcion TEXT,
            fecha TEXT,
            orden INTEGER,
            series INTEGER,
            reps INTEGER,
            peso REAL,
            tiempo TEXT,
            distancia REAL,
            id_usuario INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE $tablaUsuarios (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE,
            password TEXT,
            correo_electronico TEXT,
            fecha_registro TEXT,
            fecha_nacimiento TEXT,
            peso REAL,
            edad INTEGER,
            activo INTEGER DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE TABLE $tablaSeguimiento (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            id_usuario INTEGER,
            id_entrenamiento INTEGER,
            fecha_entrenamiento TEXT,
            tipo_record TEXT,
            valor_record REAL
          )
        ''');

        await db.execute('''
          CREATE TABLE $tablaPlanNutricion (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            id_usuario INTEGER,
            peso REAL,
            altura REAL,
            edad INTEGER,
            genero TEXT,
            objetivo TEXT,
            calorias REAL
          )
        ''');

        await db.execute('''
          CREATE TABLE $tablaHistorialPlanNutricion (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            id_usuario INTEGER,
            peso REAL,
            altura REAL,
            edad INTEGER,
            genero TEXT,
            objetivo TEXT,
            calorias REAL,
            fecha_guardado TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        final columnasMap = await db.rawQuery(
          "PRAGMA table_info($tablaUsuarios)",
        );
        final columnas = columnasMap.map((c) => c['name'] as String).toList();

        if (oldVersion < 2) {
          await db.execute('ALTER TABLE $tabla ADD COLUMN orden INTEGER');
          await db.execute('ALTER TABLE $tabla ADD COLUMN series INTEGER');
          await db.execute('ALTER TABLE $tabla ADD COLUMN reps INTEGER');
          await db.execute('ALTER TABLE $tabla ADD COLUMN peso REAL');
          await db.execute('ALTER TABLE $tabla ADD COLUMN tiempo TEXT');
          await db.execute('ALTER TABLE $tabla ADD COLUMN distancia REAL');
          await db.execute('ALTER TABLE $tabla ADD COLUMN id_usuario  INTEGER');
        }

        if (oldVersion < 4) {
          if (!columnas.contains('activo')) {
            await db.execute(
              'ALTER TABLE $tablaUsuarios ADD COLUMN activo INTEGER DEFAULT 0',
            );
          }
        }

        if (oldVersion < 5) {
          if (!columnas.contains('correo_electronico')) {
            await db.execute(
              'ALTER TABLE $tablaUsuarios ADD COLUMN correo_electronico TEXT',
            );
          }
          if (!columnas.contains('fecha_registro')) {
            await db.execute(
              'ALTER TABLE $tablaUsuarios ADD COLUMN fecha_registro TEXT',
            );
          }
          if (!columnas.contains('fecha_nacimiento')) {
            await db.execute(
              'ALTER TABLE $tablaUsuarios ADD COLUMN fecha_nacimiento TEXT',
            );
          }
          if (!columnas.contains('peso')) {
            await db.execute('ALTER TABLE $tablaUsuarios ADD COLUMN peso REAL');
          }
          if (!columnas.contains('edad')) {
            await db.execute(
              'ALTER TABLE $tablaUsuarios ADD COLUMN edad INTEGER',
            );
          }
        }

        if (oldVersion < 6) {
          await db.execute('ALTER TABLE $tabla ADD COLUMN id_usuario INTEGER');
        }
        if (oldVersion < 7) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS $tablaSeguimiento (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              id_usuario INTEGER,
              id_entrenamiento INTEGER,
              fecha_entrenamiento TEXT,
              tipo_record TEXT,
              valor_record REAL
            )
          ''');
        }
        if (oldVersion < 8) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS $tablaHistorialPlanNutricion (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              id_usuario INTEGER,
              peso REAL,
              altura REAL,
              edad INTEGER,
              genero TEXT,
              objetivo TEXT,
              calorias REAL,
              fecha_guardado TEXT
            )
          ''');
        }
      },
    );
  }

  static Future<Database> getDB() async {
    _db ??= await _initDB();
    return _db!;
  }

  // MÉTODOS DE USUARIO

  static Future<bool> registerUser({
    required String username,
    required String password,
    required String correoElectronico,
    required String fechaRegistro,
    required String fechaNacimiento,
    required double peso,
    required int edad,
  }) async {
    final db = await getDB();
    final fechaRegistro = DateTime.now().toIso8601String();

    try {
      await db.insert(tablaUsuarios, {
        'username': username,
        'password': password,
        'correo_electronico': correoElectronico,
        'fecha_registro': fechaRegistro,
        'fecha_nacimiento': fechaNacimiento,
        'peso': peso,
        'edad': edad,
        'activo': 0,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> loginUser(String username, String password) async {
    final db = await getDB();

    final result = await db.query(
      tablaUsuarios,
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (result.isNotEmpty) {
      final userId = result.first['id'];

      await db.update(tablaUsuarios, {'activo': 0});
      await db.update(
        tablaUsuarios,
        {'activo': 1},
        where: 'id = ?',
        whereArgs: [userId],
      );

      return true;
    }

    return false;
  }

  static Future<void> logoutUser() async {
    final db = await getDB();
    await db.update(tablaUsuarios, {'activo': 0});
  }

  static Future<Usuario?> getUsuarioActivo() async {
    final db = await getDB();
    final result = await db.query(tablaUsuarios, where: 'activo = 1', limit: 1);
    if (result.isNotEmpty) {
      return Usuario.fromMap(result.first);
    }
    return null;
  }

  static Future<bool> existeUsuario(String username) async {
    final db = await getDB();
    final result = await db.query(
      tablaUsuarios,
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty;
  }

  // MÉTODOS DE ENTRENAMIENTO

  static Future<int> insert(DatosEntrenamiento datos) async {
    final db = await getDB();
    return await db.insert(tabla, datos.toMap());
  }

  static Future<List<DatosEntrenamiento>> getEntrenamientosDelDiaUsuarioActivo(
    DateTime fecha,
  ) async {
    final db = await DBHelper.getDB();

    final usuario = await getUsuarioActivo();
    if (usuario == null) return [];

    final inicio = DateTime(fecha.year, fecha.month, fecha.day);
    final fin = inicio.add(const Duration(days: 1));

    final maps = await db.query(
      'DatosEntrenamiento',
      where: 'fecha >= ? AND fecha < ? AND id_usuario = ?',
      whereArgs: [inicio.toIso8601String(), fin.toIso8601String(), usuario.id],
    );

    return maps.map((map) => DatosEntrenamiento.fromMap(map)).toList();
  }

  static Future<List<DatosEntrenamiento>>
  getEntrenamientosUsuarioActivo() async {
    final usuario = await getUsuarioActivo();
    if (usuario == null) return [];

    final db = await DBHelper.getDB();
    final maps = await db.query(
      'DatosEntrenamiento',
      where: 'id_usuario = ?',
      whereArgs: [usuario.id],
    );

    return maps.map((e) => DatosEntrenamiento.fromMap(e)).toList();
  }

  static Future<List<DatosEntrenamiento>> getEntrenamientosDelUsuario(
    int idUsuario,
  ) async {
    final db = await getDB();
    final List<Map<String, dynamic>> maps = await db.query(
      tabla,
      where: 'id_usuario = ?',
      whereArgs: [idUsuario],
      orderBy: 'fecha ASC, orden ASC',
    );
    return maps.map((e) => DatosEntrenamiento.fromMap(e)).toList();
  }

  static Future<int> update(DatosEntrenamiento datos) async {
    final db = await getDB();
    return await db.update(
      tabla,
      datos.toMap(),
      where: 'id = ?',
      whereArgs: [datos.id],
    );
  }

  static Future<int> delete(int id) async {
    final db = await getDB();
    return await db.delete(tabla, where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<DatosEntrenamiento>> getAll() async {
    final db = await getDB();
    final List<Map<String, dynamic>> maps = await db.query(tabla);
    return maps.map((e) => DatosEntrenamiento.fromMap(e)).toList();
  }

  static Future<void> close() async {
    final db = await getDB();
    await db.close();
    _db = null;
  }

  // MÉTODOS DE SEGUIMIENTO

  // Insertar nuevo seguimiento
  static Future<int> insertSeguimiento(Seguimiento seguimiento) async {
    final db = await getDB();
    return await db.insert(tablaSeguimiento, seguimiento.toMap());
  }

  // Obtener seguimiento por usuario
  static Future<List<Seguimiento>> getSeguimientoPorUsuario(
    int idUsuario,
  ) async {
    final db = await getDB();
    final List<Map<String, dynamic>> maps = await db.query(
      tablaSeguimiento,
      where: 'id_usuario = ?',
      whereArgs: [idUsuario],
      orderBy: 'fecha_entrenamiento ASC',
    );
    return maps.map((e) => Seguimiento.fromMap(e)).toList();
  }

  // Actualizar seguimiento
  static Future<int> updateSeguimiento(Seguimiento seguimiento) async {
    final db = await getDB();
    return await db.update(
      tablaSeguimiento,
      seguimiento.toMap(),
      where: 'id = ?',
      whereArgs: [seguimiento.id],
    );
  }

  // Eliminar seguimiento
  static Future<int> deleteSeguimiento(int id) async {
    final db = await getDB();
    return await db.delete(tablaSeguimiento, where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Seguimiento>> getAllSeguimientos() async {
    final db = await getDB();
    final List<Map<String, dynamic>> maps = await db.query(tablaSeguimiento);
    return maps.map((e) => Seguimiento.fromMap(e)).toList();
  }

  // MÉTODOS DE NUTRICIÓN

  // Guarda un plan de nutrición para el usuario activo
  static Future<void> savePlanNutricion(PlanNutricion plan) async {
    final db = await getDB();
    final usuario = await getUsuarioActivo();
    if (usuario == null) return;
    // Elimina el plan anterior si existe (uno por usuario)
    await db.delete(tablaPlanNutricion, where: 'id_usuario = ?', whereArgs: [usuario.id]);
    await db.insert(tablaPlanNutricion, {
      'id_usuario': usuario.id,
      ...plan.toMap(),
    });
  }

  // Obtiene el plan de nutrición del usuario activo
  static Future<PlanNutricion?> getPlanNutricionUsuarioActivo() async {
    final db = await getDB();
    final usuario = await getUsuarioActivo();
    if (usuario == null) return null;
    final result = await db.query(
      tablaPlanNutricion,
      where: 'id_usuario = ?',
      whereArgs: [usuario.id],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return PlanNutricion.fromMap(result.first);
    }
    return null;
  }

  // Método para guardar en el historial
  static Future<void> saveHistorialPlanNutricion(PlanNutricion plan) async {
    final db = await getDB();
    final usuario = await getUsuarioActivo();
    if (usuario == null) return;
    await db.insert(tablaHistorialPlanNutricion, {
      'id_usuario': usuario.id,
      'peso': plan.peso,
      'altura': plan.altura,
      'edad': plan.edad,
      'genero': plan.genero,
      'objetivo': plan.objetivo,
      'calorias': plan.calorias,
      'fecha_guardado': DateTime.now().toIso8601String(),
    });
  }

  // Método para obtener el historial del usuario activo
  static Future<List<Map<String, dynamic>>> getHistorialPlanNutricionUsuarioActivo() async {
    final db = await getDB();
    final usuario = await getUsuarioActivo();
    if (usuario == null) return [];
    return await db.query(
      tablaHistorialPlanNutricion,
      where: 'id_usuario = ?',
      whereArgs: [usuario.id],
      orderBy: 'fecha_guardado DESC',
    );
  }
}
