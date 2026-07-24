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
      version: 3,
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.execute("DROP TABLE IF EXISTS medicines");
        await _createDB(db, newVersion);
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
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
        isActive INTEGER NOT NULL,

        taken INTEGER NOT NULL DEFAULT 0,
        takenDate TEXT
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

  Future<int> updateMedicine(Map<String, dynamic> medicine) async {
    final db = await database;

    return await db.update(
      'medicines',
      medicine,
      where: 'id = ?',
      whereArgs: [medicine['id']],
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

  Future<void> markMedicineTaken(int id) async {
    final db = await database;

    await db.update(
      'medicines',
      {
        'taken': 1,
        'takenDate': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markMedicineNotTaken(int id) async {
    final db = await database;

    await db.update(
      'medicines',
      {
        'taken': 0,
        'takenDate': null,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getTakenCount() async {
    final db = await database;

    final result = await db.rawQuery(
      "SELECT COUNT(*) as total FROM medicines WHERE taken = 1",
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }
}