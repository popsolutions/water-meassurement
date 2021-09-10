import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:water_meassurement/app/modules/auth/auth_controller.dart';
import 'package:water_meassurement/app/modules/home/home_service.dart';
import 'package:water_meassurement/app/shared/models/land_model.dart';
import 'package:water_meassurement/app/shared/models/water_consumption_model.dart';
import 'dao/water_consumption_dao.dart';

class HomeController extends GetxController {
  final HomeService _service;
  final WaterConsumptionDao _dao;
  HomeController(this._service, this._dao);

  var lands = <LandModel>[].obs;
  var waterConsumptions = <WaterConsumptionModel>[].obs;
  var isLoading = false.obs;
  final format = DateFormat('dd/MM/yyyy');
  var currentWaterConsumption = WaterConsumptionModel();
  final landEC = TextEditingController();
  final currentReadEC = TextEditingController();
  final lastReadEC = TextEditingController();

  @override
  onInit() async {
    super.onInit();

    await getWaterConsumptionsDB();
  }

  saveWaterConsumption() async {
    await _service.saveWaterConsumption(currentWaterConsumption);
  }

  Future<void> readWaterConsumption() async {
    await _service.readWaterConsumption();
  }

  Future<void> getWaterConsumptionsDB() async {
    final waterConsumptionsDao = await _dao.getWaterConsumptionsDao();
    if (waterConsumptionsDao.isNotEmpty) {
      waterConsumptions.value = waterConsumptionsDao;
    }
  }

  Future<void> loginSaveWaterConsumptionsDB() async {
    final waterConsumptionsApi = await _service.getWaterConsumptions();
    final waterConsumptionsDao = await _dao.getWaterConsumptionsDao();
    if (waterConsumptionsDao.isEmpty) {
      await _dao.saveWaterConsumptionsDao(waterConsumptionsApi);
    }
  }

  Future<void> saveWaterConsumptionOdoo(BuildContext context) async {
    final _authProvider = Provider.of<AuthController>(context, listen: false);
    currentWaterConsumption.readerId = _authProvider.currentUser.partnerId;
    currentWaterConsumption.date = format.format(DateTime.now());

    isLoading.value = true;
    await saveWaterConsumption();
    currentWaterConsumption.state = 'pending';
    await saveWaterConsumption();
    isLoading.value = false;

    landEC.text = '';
    currentReadEC.text = '';
    lastReadEC.text = '';
  }
}
