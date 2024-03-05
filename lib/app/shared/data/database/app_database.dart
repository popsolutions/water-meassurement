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

    String sql = '''
      CREATE TABLE IF NOT EXISTS user (
        username Text PRIMARY KEY,
        password Text,
        uid int,
        name Text,
        image Text,
        partnerDisplayName Text,
        companyId int,
        partnerId int
    ); 
    ''';

    await db.execute(sql);

    sql = '''
    CREATE TABLE IF NOT EXISTS property_water_consumption_route_custom (
     id int PRIMARY KEY,
     name text,
     route_id int,
     descricao text
    ); 
    ''';

    await db.execute(sql);

    sql = '''
    CREATE TABLE IF NOT EXISTS property_water_consumption_route_lands (
      id int,
      routecustom_id int,
      land_id int,
      land_id_module_id_code text,
      land_id_block_id_code text,
      land_id_lot_id_code text,
      "sequence" int
    );
    ''';

    await db.execute(sql);
  }

  String get _waterConsumptions => ''' 
  CREATE TABLE IF NOT EXISTS waterConsumption (
    id INT PRIMARY KEY,
    land_id INT,
    land_name TEXT,
    date TEXT,
    photo TEXT,
    last_read REAL,
    current_read REAL,
    reader_id INT,
    state TEXT,
    statesendserver int,
    datetime_send timestamp,
    route_custom_id int,
    route_sequence int,
    route_realreadsequence int,
    read_datetime datetime
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
