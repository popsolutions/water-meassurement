import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:water_meassurement/app/shared/utils/constants.dart';

// Este arquivo parece defazado, foi susbtituído por "// Este arquivo parece defazado, foi susbtituído por "app_database.dart"
class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();
  static Database? _database;

  get database async {
    if (_database != null) {
      return _database;
    }

    return await _initDatabase();
  }

  _initDatabase() async {
    return await openDatabase(
      join(await getDatabasesPath(), Constants.DB_NAME),
      version: 1,
      onCreate: _onCreate,
    );
  }

  _onCreate(db, version) async {
    await db.execute(_waterConsumptions);
  }

  String get _waterConsumptions => ''' 
  CREATE TABLE IF NOT EXISTS waterConsumption (
    id INT PRIMARY KEY,
    land_id INT,
    land_name TEXT,
    date TEXT,
    last_read REAL,
    current_read REAL,
    reader_id INT,
    state TEXT
    );
  ''';
}
