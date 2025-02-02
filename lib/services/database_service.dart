import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/counter_model.dart';

class DatabaseService {
  static const String _dbName = 'counter_app.db';
  static const String tableName = 'counters';
  static const int _version = 1;

  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), _dbName);
    return await openDatabase(
      path,
      version: _version,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            count INTEGER NOT NULL,
            color TEXT NOT NULL
          )
        ''');
      },
    );
  }

  static Future<List<CounterModel>> getCounters() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return List.generate(maps.length, (i) {
      return CounterModel(
        id: maps[i]['id'] as int,
        name: maps[i]['name'] as String,
        count: maps[i]['count'] as int,
        color: maps[i]['color'] as String,
      );
    });
  }

  static Future<int> insertCounter(CounterModel counter) async {
    final db = await database;
    return await db.insert(
      tableName,
      {
        'name': counter.name,
        'count': counter.count,
        'color': counter.color,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> updateCounter(int id, CounterModel counter) async {
    final db = await database;
    await db.update(
      tableName,
      {
        'name': counter.name,
        'count': counter.count,
        'color': counter.color,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> deleteCounter(int id) async {
    final db = await database;
    await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
} 