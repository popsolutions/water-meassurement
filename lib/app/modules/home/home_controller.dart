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

  var lands = <LandModel>[].obs;
  var isLoading = false.obs;
  final format = DateFormat('dd/MM/yyyy');
  var currentWaterConsumption = WaterConsumptionModel();

  @override
  onInit() async {
    super.onInit();
    currentWaterConsumption.date = format.format(DateTime.now());

    await getLandsDB();
  }

  saveWaterConsumption() async {
    await _service.saveWaterConsumption(currentWaterConsumption);
  }

  Future<void> readWaterConsumption() async {
    await _service.readWaterConsumption();
  }

  Future<List<LandModel>> getLands() async {
    return await _service.getLands();
  }

  Future<void> getLandsDB() async {
    final landsDao = await _dao.getLandsDao();
    if (landsDao.isNotEmpty) {
      lands.value = landsDao;
    }
  }

  Future<void> saveLandsDB() async {
    final landsApi = await _service.getLands();
    final landsDao = await _dao.getLandsDao();
    if (landsDao.isEmpty) {
      await _dao.saveLandsDao(landsApi);
    }
  }
}
