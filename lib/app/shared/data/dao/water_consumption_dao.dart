import 'package:sqflite/sqflite.dart';
import 'package:water_meassurement/app/shared/data/database/app_database.dart';
import 'package:water_meassurement/app/shared/enums/enums.dart';
import 'package:water_meassurement/app/shared/models/property_water_consumption_route_custom_model.dart';
import 'package:water_meassurement/app/shared/models/property_water_consumption_route_lands_model.dart';
import 'package:water_meassurement/app/shared/models/water_consumption_model.dart';

class WaterConsumptionDao {
  late Database _db;

  Future<void> saveWaterConsumptionsDaoList(
      List<WaterConsumptionModel> waterConsumptions) async {
    _db = await AppDatabase.instance.database;

    await _db.transaction((txn) async {
      waterConsumptions.forEach((WaterConsumptionModel wc) async {
        await txn.insert('waterConsumption', wc.toMapDao());
      });
    });

    print('Inseridos os Water Consumptions no banco local.');
  }

  Future<void> updateWaterConsumptionsDao(
      WaterConsumptionModel waterConsumptions) async {
    _db = await AppDatabase.instance.database;
    await _db.transaction((txn) async {
      await txn.update('waterConsumption', waterConsumptions.toMapDao(),
          where: "id = ?", whereArgs: [waterConsumptions.id]);
    });
  }

  Future<void> clearWaterConsumptionsDao() async {
    _db = await AppDatabase.instance.database;
    await _db.transaction((txn) async {
      await txn.delete(
        'waterLog',
      );
      await txn.delete(
        'waterConsumption',
      );
      await txn.delete(
        'property_water_consumption_route_lands',
      );
      await txn.delete(
        'property_water_consumption_route_custom',
      );
    });
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

  Future<List<Property_water_consumption_route_custom>> getRouteCustomDao() async {
    _db = await AppDatabase.instance.database;
    final routesCustomDao = await _db.query('property_water_consumption_route_custom');
    final List<Property_water_consumption_route_custom> listRoutesCustom = [];

    for (final routesCustom in routesCustomDao) {
      listRoutesCustom.add(Property_water_consumption_route_custom.fromDao(routesCustom));
    }
    return listRoutesCustom;
  }


  Future<WaterConsumptionModel?> getNextSendOdooWaterConsumptionModel(
      [String waterConsumptionIgnore = '']) async {
    if (waterConsumptionIgnore != '')
      waterConsumptionIgnore = ' and id > ($waterConsumptionIgnore)';

    _db = await AppDatabase.instance.database;
    var waterConsumptiosDao = await _db.query('waterConsumption',
        where: 'statesendserver = ${StateSendServerEnum.read_2}', limit: 1);

    if (waterConsumptiosDao.length == 0)
      waterConsumptiosDao = await _db.query(
        'waterConsumption',
        where:
            'statesendserver in (${StateSendServerEnum.sending_3}, ${StateSendServerEnum.sendingError_4}) $waterConsumptionIgnore',
        orderBy: 'id',
        limit: 1,
      );

    if (waterConsumptiosDao.length == 0) return null;

    final WaterConsumptionModel waterConsumptionModel =
        WaterConsumptionModel.fromDao(waterConsumptiosDao[0]);
    return waterConsumptionModel;
  }

  Future<void> logout() async {
    _db = await AppDatabase.instance.database;
    // await _db.delete('waterConsumption');
  }

  Future<int?> waterLogInsert(int? waterConsumptionId, int? typelog,
      [int? loteprocess = 0, String? logText]) async {
    int? id;
    await _db.transaction((txn) async {
      id = await txn.insert('waterLog', {
        'waterconsumption_id': waterConsumptionId,
        'typelog': typelog,
        'loteprocess': loteprocess,
        'logtext': logText,
        'datetime': DateTime.now().toString()
      });
      if (loteprocess == 0)
        await txn.update('waterLog', {'loteprocess': id},
            where: "id = ?", whereArgs: [id]);
    });
    return id;
  }

  Future<dynamic> getWaterConsumptionAmounts() async {
    String amountToReadSql = StateSendServerEnum.unread_1.toString();
    String amountToSendSql =
        '${StateSendServerEnum.read_2}, ${StateSendServerEnum.sending_3}, ${StateSendServerEnum.sendingError_4}';
    String amountSendSql = StateSendServerEnum.send_5.toString();

    String query = '''
select sum(amountToRead) amountToRead,
       sum(amountToSend) amountToSend,
       sum(amountSend) amountSend
 from (select case when statesendserver in ($amountToReadSql) THEN 1 ELSE 0 END amountToRead,
              case when statesendserver in ($amountToSendSql) THEN 1 ELSE 0 END amountToSend,
              case when statesendserver in ($amountSendSql) THEN 1 ELSE 0 END amountSend
         from waterConsumption
      )
''';

    _db = await AppDatabase.instance.database;
    dynamic response = await _db.rawQuery(query);
    return response;
  }

  Future<void> saveProperty_water_consumption_route_customDaoList(
      List<Property_water_consumption_route_custom> listRoute_custom) async {
    _db = await AppDatabase.instance.database;

    await _db.transaction((txn) async {
      listRoute_custom.forEach((Property_water_consumption_route_custom rc) async {
        await txn.insert('property_water_consumption_route_custom', rc.toMap());
      });
    });

    print('Inseridos os Property_water_consumption_route no banco local.');
  }

  Future<void> saveProperty_water_consumption_route_landsDaoList(
      List<Property_water_consumption_route_lands> listRoute_lands) async {
    _db = await AppDatabase.instance.database;

    await _db.transaction((txn) async {
      listRoute_lands.forEach((Property_water_consumption_route_lands rc) async {
        await txn.insert('property_water_consumption_route_lands', rc.toMap());
      });
    });

    print('Inseridos os Property_water_consumption_lands no banco local.');
  }

  Future<dynamic> getNextRead(int routecustom_id) async {
    String query = '''
select wc.land_id
  from property_water_consumption_route_lands rl
       join waterConsumption wc on wc.land_id = rl.land_id and wc.statesendserver = 1/*Não lido*/
 where rl.routecustom_id = ''' + routecustom_id.toString() + ''' 
 order by rl.sequence 
 limit 1
''';

    _db = await AppDatabase.instance.database;
    dynamic response = await _db.rawQuery(query);
    return response[0]['land_id'];
  }


  Future<int> getRoute_realReadSequence() async {
    //Sequência Real de leitura
    String query = '''
select coalesce(max(wc.route_realreadsequence), 0) + 1 next_route_realreadsequence from waterConsumption wc ''';

    _db = await AppDatabase.instance.database;
    dynamic response = await _db.rawQuery(query);
    return response[0]['next_route_realreadsequence'];
  }

  Future<int> getRoute_readSequence(int land_id, int route_custom_id) async {
    //Sequência definida na rota
    String query = '''
select rl.sequence next_route_realreadsequence
  from property_water_consumption_route_lands rl
 where rl.routecustom_id = ''' + route_custom_id.toString() + ''' 
   and rl.land_id = ''' + land_id.toString() + '''
 limit 1 
''';

    _db = await AppDatabase.instance.database;
    dynamic response = await _db.rawQuery(query);
    try {
      return response[0]['next_route_realreadsequence'];
    } catch (e) {
      return 0;
    }

  }

}
