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
    var db = await openDatabase(
      join(await getDatabasesPath(), AppConstants.DB_NAME),
      version: 1,
      onCreate: _onCreate,
    );

    await _updateDatabase(db);

    _database = db;

    return db;
  }


  Future<int> dbVersion_getCurrent(Database db) async {
    String query = '''
SELECT exists 
       (
       SELECT 1
         FROM sqlite_master 
        WHERE type='table' 
          AND name='version'
       ) version_exists
''';

    dynamic response = await db.rawQuery(query);

    if (response[0]['version_exists'] == 0)
      return 0;
    else {
      // O Banco já iniciou o versionamento

      String query = '''
  select version
    from version
   where status = 'atualizado'     
   order by id desc 
   limit 1      
''';

      dynamic response = await db.rawQuery(query);
      return response[0]['version'];
    }
  }

  dbVersion_Create(Database db, int version) async {
    //Cria uma versão no banco com o status 'atualizando'
    String query = '''insert or ignore into version(version, status) values (1, 'atualizando')''';
    await db.execute(query);
  }

  dbVersion_Finish(Database db, int version) async {
    //Atualiza o status de version.status para 'atualizado'
    String query = '''update version set status = 'atualizado' where version = ${version.toString()}''';
    await db.execute(query);
  }



  _onCreate(db, version) async {

    String sql = '''
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
      );''';

    await db.execute(sql);
    await db.execute('CREATE INDEX indx_waterConsumption_statesendserver ON waterConsumption (statesendserver);');

    sql = '''
      CREATE TABLE IF NOT EXISTS waterLog (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        loteprocess int,
        waterconsumption_id int,
        typelog INT,
        logText TEXT,
        datetime timestamp,
        FOREIGN KEY(waterconsumption_id) REFERENCES waterConsumption(id)
  );''';

    await db.execute(sql);

     sql = '''
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

    await db.execute('''
 CREATE TABLE version (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    update_datetime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    version integer,
    status text
);''');

    await db.execute('CREATE UNIQUE INDEX version_version_IDX ON version (version);');

    await dbVersion_Create(db, 1);
    await dbVersion_Finish(db, 1);
  }

  _updateDatabase(db) async {

    if (await dbVersion_getCurrent(db) == 0) {
      // ## Inicio do versionamento do banco

      // await dbVersion_Create(1); //Linha desnecessária pois ná existe em _onCreate

      // 1. Deletar o banco todo...
      await db.execute('drop table if exists property_water_consumption_route_lands');
      await db.execute('drop table if exists property_water_consumption_route_custom');
      await db.execute('drop table if exists user');
      await db.execute('drop table if exists waterConsumption');
      await db.execute('drop table if exists waterLog');

      // 2. Reconstruir o banco
      await _onCreate(db, 0);

      // await dbVersion_Finish(db, 1); //Linha desnecessária pois ná existe em _onCreate
    }

    /** Estrutura para novas versões de banco
        if (await dbVersion_getCurrent() == 2){
        await dbVersion_Create(3);

        await db.execute('''create table test(i int);''');

        await dbVersion_Finish(3);
        }
     */
  }
}
