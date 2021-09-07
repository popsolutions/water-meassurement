import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:water_meassurement/app/modules/home/home_service.dart';
import 'package:water_meassurement/app/shared/models/land_model.dart';
import 'package:water_meassurement/app/shared/models/water_consumption_model.dart';
import 'dao/land_dao.dart';

class HomeController extends GetxController {
  final HomeService _service;
  final LandDao _dao;
  HomeController(this._service, this._dao);
  RxList<LandModel> lands = <LandModel>[].obs;

  @override
  onInit() async {
    super.onInit();
    await getLandsDao();
  }

  var currentWaterConsumption = WaterConsumptionModel();
  final format = DateFormat('dd/MM/yyyy');

  saveWaterConsumption(WaterConsumptionModel currentWaterConsumption) async {
    await _service.saveWaterConsumption(currentWaterConsumption);
  }

  Future<void> readWaterConsumption() async {
    await _service.readWaterConsumption();
  }

  Future<List<LandModel>> getLands() async {
    return await _service.getLands();
  }

  Future<void> getLandsDao() async {
    lands.value = await _dao.getLandsDao();
  }

  Future<void> saveLandsDB() async {
    lands.value = await _dao.getLandsDao();
    if (lands.isNotEmpty) {
      return;
    }
    final landsApi = await _service.getLands();
    await _dao.saveLands(landsApi);
  }
}
