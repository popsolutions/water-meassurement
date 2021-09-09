import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:water_meassurement/app/shared/utils/constants.dart';

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
    await db.execute(_lands);
  }

  String get _lands => ''' 
  CREATE TABLE IF NOT EXISTS lands (
    id INT PRIMARY KEY,
    name TEXT
    );
  ''';
}
