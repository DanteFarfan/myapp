import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/datos_entrenamiento.dart';

class DBHelper {
  static Database? _db;
  static const String tabla = 'DatosEntrenamiento';
  static const String tablaUsuarios = 'Usuarios';

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'fitness.db');

    return openDatabase(
      path,
      version: 3,
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
            distancia REAL
          )
        ''');

        await db.execute('''
          CREATE TABLE $tablaUsuarios (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE,
            password TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE $tabla ADD COLUMN orden INTEGER');
          await db.execute('ALTER TABLE $tabla ADD COLUMN series INTEGER');
          await db.execute('ALTER TABLE $tabla ADD COLUMN reps INTEGER');
          await db.execute('ALTER TABLE $tabla ADD COLUMN peso REAL');
          await db.execute('ALTER TABLE $tabla ADD COLUMN tiempo TEXT');
          await db.execute('ALTER TABLE $tabla ADD COLUMN distancia REAL');
        }
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS $tablaUsuarios (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              username TEXT UNIQUE,
              password TEXT
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

  // ────────────────────────────────
  // MÉTODOS DE USUARIO
  // ────────────────────────────────

  /// Registra un usuario. Devuelve `true` si fue exitoso, `false` si ya existe.
  static Future<bool> registerUser(String username, String password) async {
    final db = await getDB();

    try {
      await db.insert(tablaUsuarios, {
        'username': username,
        'password': password,
      });
      return true;
    } catch (e) {
      return false; // Usuario ya registrado o error
    }
  }

  /// Verifica si un usuario y contraseña son correctos
  static Future<bool> loginUser(String username, String password) async {
    final db = await getDB();

    final result = await db.query(
      tablaUsuarios,
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    return result.isNotEmpty;
  }

  /// Verifica si ya existe un usuario por nombre
  static Future<bool> existeUsuario(String username) async {
    final db = await getDB();

    final result = await db.query(
      tablaUsuarios,
      where: 'username = ?',
      whereArgs: [username],
    );

    return result.isNotEmpty;
  }

  // ────────────────────────────────
  // MÉTODOS DE ENTRENAMIENTO
  // ────────────────────────────────

  static Future<int> insert(DatosEntrenamiento datos) async {
    final db = await getDB();
    return await db.insert(tabla, datos.toMap());
  }

  static Future<List<DatosEntrenamiento>> getEntrenamientosDelDia(
      DateTime dia) async {
    final db = await getDB();
    final hoyStr =
        '${dia.year}-${dia.month.toString().padLeft(2, '0')}-${dia.day.toString().padLeft(2, '0')}';
    final List<Map<String, dynamic>> maps = await db.query(
      tabla,
      where: 'fecha = ?',
      whereArgs: [hoyStr],
      orderBy: 'orden ASC',
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
}
