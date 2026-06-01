import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'asistencia.dart';
import 'estudiante.dart';

class BaseDatos {
  BaseDatos._();

  static final BaseDatos instancia = BaseDatos._();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;

    final ruta = join(await getDatabasesPath(), 'estudiantes.db');

    _db = await openDatabase(
      ruta,
      version: 2,
      onCreate: (database, version) async {
        await _crearTablas(database);
        await _insertarDatosIniciales(database);
      },
      onUpgrade: (database, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await database.execute('''
            CREATE TABLE IF NOT EXISTS asistencias(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              estudianteId TEXT NOT NULL,
              nombre TEXT NOT NULL,
              fecha TEXT NOT NULL,
              hora TEXT NOT NULL,
              confianza REAL NOT NULL
            )
          ''');
        }
      },
    );

    return _db!;
  }

  Future<void> _crearTablas(Database database) async {
    await database.execute('''
      CREATE TABLE estudiantes(
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        semestre TEXT NOT NULL,
        carrera TEXT NOT NULL
      )
    ''');

    await database.execute('''
      CREATE TABLE asistencias(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        estudianteId TEXT NOT NULL,
        nombre TEXT NOT NULL,
        fecha TEXT NOT NULL,
        hora TEXT NOT NULL,
        confianza REAL NOT NULL
      )
    ''');
  }

  Future<void> _insertarDatosIniciales(Database database) async {
    final estudiantes = [
      Estudiante(
        id: '20170638',
        nombre: 'Nombre estudiante 1',
        semestre: '8',
        carrera: 'Ingeniería en Sistemas Computacionales',
      ),
      Estudiante(
        id: '20170639',
        nombre: 'Nombre estudiante 2',
        semestre: '8',
        carrera: 'Ingeniería en Sistemas Computacionales',
      ),
      Estudiante(
        id: '21170495',
        nombre: 'Nombre estudiante 3',
        semestre: '8',
        carrera: 'Ingeniería en Sistemas Computacionales',
      ),
      Estudiante(
        id: '21170937',
        nombre: 'Nombre estudiante 4',
        semestre: '8',
        carrera: 'Ingeniería en Sistemas Computacionales',
      ),
      Estudiante(
        id: '22170618',
        nombre: 'Nombre estudiante 5',
        semestre: '8',
        carrera: 'Ingeniería en Sistemas Computacionales',
      ),
      Estudiante(
        id: '22170621',
        nombre: 'Nombre estudiante 6',
        semestre: '8',
        carrera: 'Ingeniería en Sistemas Computacionales',
      ),
      Estudiante(
        id: '22170640',
        nombre: 'Nombre estudiante 7',
        semestre: '8',
        carrera: 'Ingeniería en Sistemas Computacionales',
      ),
    ];

    for (final estudiante in estudiantes) {
      await database.insert(
        'estudiantes',
        estudiante.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<Estudiante?> obtenerEstudiantePorId(String id) async {
    final database = await db;

    final resultado = await database.query(
      'estudiantes',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (resultado.isEmpty) return null;

    return Estudiante.fromMap(resultado.first);
  }

  Future<List<Estudiante>> obtenerTodos() async {
    final database = await db;

    final resultado = await database.query(
      'estudiantes',
      orderBy: 'nombre ASC',
    );

    return resultado.map((map) => Estudiante.fromMap(map)).toList();
  }

  Future<void> actualizarEstudiante(Estudiante estudiante) async {
    final database = await db;

    await database.update(
      'estudiantes',
      estudiante.toMap(),
      where: 'id = ?',
      whereArgs: [estudiante.id],
    );
  }

  Future<void> eliminarEstudiante(String id) async {
    final database = await db;

    await database.delete('estudiantes', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> insertarEstudiante(Estudiante estudiante) async {
    final database = await db;

    await database.insert(
      'estudiantes',
      estudiante.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> registrarAsistencia({
    required Estudiante estudiante,
    required double confianza,
  }) async {
    final database = await db;

    final ahora = DateTime.now();

    final fecha =
        '${ahora.year.toString().padLeft(4, '0')}-'
        '${ahora.month.toString().padLeft(2, '0')}-'
        '${ahora.day.toString().padLeft(2, '0')}';

    final hora =
        '${ahora.hour.toString().padLeft(2, '0')}:'
        '${ahora.minute.toString().padLeft(2, '0')}:'
        '${ahora.second.toString().padLeft(2, '0')}';

    await database.insert('asistencias', {
      'estudianteId': estudiante.id,
      'nombre': estudiante.nombre,
      'fecha': fecha,
      'hora': hora,
      'confianza': confianza,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Asistencia>> obtenerAsistencias() async {
    final database = await db;

    final resultado = await database.query('asistencias', orderBy: 'id DESC');

    return resultado.map((map) => Asistencia.fromMap(map)).toList();
  }

  Future<void> eliminarAsistencias() async {
    final database = await db;
    await database.delete('asistencias');
  }
}
