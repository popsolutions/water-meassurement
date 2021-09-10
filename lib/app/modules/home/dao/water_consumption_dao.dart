import 'package:sqflite/sqflite.dart';
import 'package:water_meassurement/app/shared/database/app_database.dart';
import 'package:water_meassurement/app/shared/models/water_consumption_model.dart';

class WaterConsumptionDao {
  late Database _db;

  Future<void> saveWaterConsumptionsDao(
      List<WaterConsumptionModel> waterConsumptions) async {
    _db = await AppDatabase.instance.database;

    await _db.transaction((txn) async {
      waterConsumptions.forEach((WaterConsumptionModel wc) async {
        await txn.insert('waterConsumption', wc.toMap());
      });
    });

    print('Inseridos os Water ConsumptionS no banco local.');
  }

  Future<List<WaterConsumptionModel>> getWaterConsumptionsDao() async {
    _db = await AppDatabase.instance.database;
    final waterConsumptiosDao = await _db.query('waterConsumption');
    final List<WaterConsumptionModel> waterConsumptios = [];

    for (final waterConsumptio in waterConsumptiosDao) {
      waterConsumptios.add(WaterConsumptionModel.fromDao(waterConsumptio));
    }
    return waterConsumptios;
  }
}
