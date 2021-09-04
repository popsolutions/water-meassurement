import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:water_meassurement/app/modules/home/home_service.dart';
import 'package:water_meassurement/app/shared/models/land_model.dart';
import 'package:water_meassurement/app/shared/models/water_consumption_model.dart';

class HomeController extends GetxController {
  final _service = HomeService();
  final format = DateFormat('dd/MM/yyyy');
  var currentWaterConsumption = WaterConsumptionModel();

  saveWaterConsumption(WaterConsumptionModel currentWaterConsumption) async {
    await _service.saveWaterConsumption(currentWaterConsumption);
  }

  Future<void> readWaterConsumption() async {
    await _service.readWaterConsumption();
  }

  Future<List<LandModel>> getLands() async {
    return await _service.getLands();
  }
}
