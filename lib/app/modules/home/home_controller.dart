import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:water_meassurement/app/config/odoo_api/odoo_api.dart';
import 'package:water_meassurement/app/shared/models/water_consumption_model.dart';

class HomeController extends GetxController {
  final _odoo = Odoo();
  Rx<DateTime?> date = DateTime.now().obs;
  final format = DateFormat('dd/MM/yyyy');
  var currentWaterConsumption = WaterConsumptionModel();
  final model = 'property.water.consumption';

  Future saveWaterConsumption(WaterConsumptionModel waterConsumption) async {
    await _odoo.create(
      model,
      // waterConsumption.toMap(),
      {
        "land_id": 196,
        "date": "2021-08-30",
        "last_read": 10,
        "current_read": 30,
        "consumption": 12,
        "reader_id": 8083,
        "total": 10.0,
        "state": "draft"
      },
    );
  }

  Future readWaterConsumption() async {
    await _odoo.searchRead(model, [], []);
  }
}
