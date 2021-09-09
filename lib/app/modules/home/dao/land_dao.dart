import 'package:sqflite/sqflite.dart';
import 'package:water_meassurement/app/shared/database/app_database.dart';
import 'package:water_meassurement/app/shared/models/land_model.dart';

class LandDao {
  late Database _db;

  Future<void> saveLandsDao(List<LandModel> lands) async {
    _db = await AppDatabase.instance.database;

    await _db.transaction((txn) async {
      lands.forEach((LandModel land) async {
        await txn.insert('lands', land.toMap());
      });
    });

    print('Inseridos os terrenos no banco local.');
  }

  Future<List<LandModel>> getLandsDao() async {
    _db = await AppDatabase.instance.database;
    final lands = await _db.query('lands');
    final List<LandModel> landsList = [];

    for (final land in lands) {
      landsList.add(LandModel.fromMap(land));
    }
    return landsList;
  }
}
