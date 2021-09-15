import 'package:water_meassurement/app/config/app_constants.dart';
import 'package:water_meassurement/app/shared/utils/global.dart';
import 'package:water_meassurement/app/shared/models/land_model.dart';
import 'package:water_meassurement/app/shared/models/water_consumption_model.dart';

class HomeService {
  Future<void> saveWaterConsumption(WaterConsumptionModel wc) async {
    await odoo.write(
      AppConstants.waterConsumptionModel,
      [wc.id!],
      wc.toMap(),
    );
  }

  Future<void> readWaterConsumption() async {
    await odoo.searchRead(AppConstants.waterConsumptionModel, [], []);
  }

  Future<List<LandModel>> getLands() async {
    final response = await odoo.searchRead(
      AppConstants.land,
      [],
      ['id', 'name'],
    );

    final List json = response.getRecords();
    final listMission = json.map((e) => LandModel.fromJson(e)).toList();

    return listMission;
  }

  Future<List<WaterConsumptionModel>> getWaterConsumptions() async {
    final response = await odoo.searchRead(
      AppConstants.waterConsumptionModel,
      [
        ["state", "=", "draft"]
      ],
      [
        "id",
        "land_id",
        "name",
        "date",
        "last_read",
        "current_read",
        "reader_id",
        "state"
      ],
    );

    final List json = response.getRecords();
    final listMission =
        json.map((e) => WaterConsumptionModel.fromJson(e)).toList();

    return listMission;
  }
}
