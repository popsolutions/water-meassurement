import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:water_meassurement/app/config/app_constants.dart';

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
      join(await getDatabasesPath(), AppConstants.DB_NAME),
      version: 1,
      onCreate: _onCreate,
    );
  }

  _onCreate(db, version) async {
    await db.execute(_waterConsumptions);
    await db.execute(_waterLog);
  }

  String get _waterConsumptions => ''' 
  CREATE TABLE IF NOT EXISTS waterConsumption (
    id INT PRIMARY KEY,
    land_id INT,
    land_name TEXT,
    property_land_address TEXT,
    property_land_number INT,
    date TEXT,
    photo TEXT,
    last_read REAL,
    current_read REAL,
    reader_id INT,
    state TEXT,
    statesendserver int,
    datetime_send timestamp
    );
    
    CREATE INDEX indx_waterConsumption_statesendserver ON waterConsumption (statesendserver);
  ''';

  String get _waterLog => ''' 
  CREATE TABLE IF NOT EXISTS waterLog (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    loteprocess int,
    waterconsumption_id int,
    typelog INT,
    logText TEXT,
    datetime timestamp,
    FOREIGN KEY(waterconsumption_id) REFERENCES waterConsumption(id)
  );
  ''';
}
