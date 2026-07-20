import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('meditrack.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.execute("DROP TABLE IF EXISTS medicines");
        await _createDB(db, newVersion);
      },
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE medicines(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        dose TEXT NOT NULL,
        time TEXT NOT NULL,
        startDate TEXT NOT NULL,
        endDate TEXT NOT NULL,
        timesPerDay INTEGER NOT NULL,
        notes TEXT,
        isActive INTEGER NOT NULL
      )
    ''');
  }

  Future<int> insertMedicine(Map<String, dynamic> medicine) async {
    final db = await database;

    return await db.insert(
      'medicines',
      medicine,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getMedicines() async {
    final db = await database;

    return await db.query(
      'medicines',
      orderBy: 'time ASC',
    );
  }

  Future<int> deleteMedicine(int id) async {
    final db = await database;

    return await db.delete(
      'medicines',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateMedicine(Map<String, dynamic> medicine) async {
    final db = await database;

    return await db.update(
      'medicines',
      medicine,
      where: 'id = ?',
      whereArgs: [medicine['id']],
    );
  }
}