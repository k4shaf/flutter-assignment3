import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  static Database? _database;

  DBHelper._internal();

  factory DBHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'remember_location.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            address TEXT NOT NULL,
            password TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE locations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            location_name TEXT NOT NULL,
            description TEXT NOT NULL,
            image_path TEXT,
            user_id INTEGER NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users (id)
          )
        ''');
      },
    );
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  Future<int> insertLocation(Map<String, dynamic> location) async {
    final db = await database;
    return await db.insert('locations', location);
  }

  Future<List<Map<String, dynamic>>> getLocations(int userId) async {
    final db = await database;
    return await db.query('locations', where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<int> updateLocation(int id, Map<String, dynamic> location) async {
    final db = await database;
    return await db.update('locations', location, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteLocation(int id) async {
    final db = await database;
    return await db.delete('locations', where: 'id = ?', whereArgs: [id]);
  }
}
