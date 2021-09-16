import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:water_meassurement/app/config/app_routes.dart';
import 'package:water_meassurement/app/modules/auth/auth_controller.dart';
import 'package:water_meassurement/app/modules/home/home_service.dart';
import 'package:water_meassurement/app/shared/enums/enums.dart';
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
  final format = DateFormat('MM/dd/yyyy');
  var currentWaterConsumption = WaterConsumptionModel();
  final landEC = TextEditingController();
  final currentReadEC = TextEditingController();
  final lastReadEC = TextEditingController();
  var titleAppBar = ['Nova Leitura', 'Perfil'];
  var index = 0.obs;

  var amountToRead = 0.obs;
  var amountToSend = 0.obs;
  var amountSend = 0.obs;

  bool processListSendsWaterConsumptionOdooInExec = false;

  @override
  onInit() async {
    super.onInit();
    await getWaterConsumptionsDB();
  }

  saveWaterConsumption() async {
    await _service.saveWaterConsumptionOdoo(currentWaterConsumption);
  }

  Future<void> readWaterConsumption() async {
    await _service.readWaterConsumption();
  }

  Future<void> getWaterConsumptionsDB() async {
    final waterConsumptionsDao = await _dao.getWaterConsumptionsDao();
    if (waterConsumptionsDao.isNotEmpty) {
      waterConsumptions.value = waterConsumptionsDao;
    }
    setAmount();
  }

  Future<void> loginSaveWaterConsumptionsDB() async {
    final waterConsumptionsApi = await _service.getWaterConsumptions();
    final waterConsumptionsDao = await _dao.getWaterConsumptionsDao();
    if (waterConsumptionsDao.isEmpty) {
      await _dao.saveWaterConsumptionsDaoList(waterConsumptionsApi);
    }
  }

  Future<void> saveWaterConsumptionDao(BuildContext context) async {
    final _authProvider = Provider.of<AuthController>(context, listen: false);
    currentWaterConsumption.readerId = _authProvider.currentUser.partnerId;
    currentWaterConsumption.date = format.format(DateTime.now());
    currentWaterConsumption.statesendserver = StateSendServerEnum.read_2;
    await _dao.updateWaterConsumptionsDao(currentWaterConsumption);
    setAmount();
    processListSendsWaterConsumptionOdoo();
  }

  Future<void> processListSendsWaterConsumptionOdoo() async {
    if (processListSendsWaterConsumptionOdooInExec) return;

    processListSendsWaterConsumptionOdooInExec = true;

    try {
      String waterConsumptionIgnore = '';

      while (true) {
        WaterConsumptionModel? waterConsumptionModel = await _dao
            .getNextSendOdooWaterConsumptionModel(waterConsumptionIgnore);
        int? loteProcess = 0;

        Future<void> logInsert(int typelog, [String? logText]) async {
          int? id = await _dao.waterLogInsert(
              waterConsumptionModel?.id, typelog, loteProcess, logText);

          if (loteProcess == 0) loteProcess = id;
        }

        if (waterConsumptionModel == null) break;

        try {
          await logInsert(TypeLogEnum.processWaterSend_1,
              'currentRead: ' + waterConsumptionModel.currentRead.toString());
          waterConsumptionModel.statesendserver = StateSendServerEnum.sending_3;
          await _dao.updateWaterConsumptionsDao(waterConsumptionModel);
          await logInsert(TypeLogEnum.DaoToStateSend_2);

          waterConsumptionModel.state = 'draft';
          await _service.saveWaterConsumptionOdoo(waterConsumptionModel);
          await logInsert(TypeLogEnum.SendDraftToOdoo_3);

          waterConsumptionModel.state = 'pending';
          await _service.saveWaterConsumptionOdoo(waterConsumptionModel);
          await logInsert(TypeLogEnum.SendPendingToOdoo_4);

          waterConsumptionModel.statesendserver = StateSendServerEnum.send_5;
          waterConsumptionModel.datetimeSend = DateTime.now();
          await _dao.updateWaterConsumptionsDao(waterConsumptionModel);
          await logInsert(TypeLogEnum.SendDaoToStateSend_5);
        } catch (e) {
          waterConsumptionIgnore = (waterConsumptionIgnore == '')
              ? '0'
              : waterConsumptionModel.id.toString();
          await logInsert(TypeLogEnum.processWaterError_6, e.toString());
          waterConsumptionModel.statesendserver =
              StateSendServerEnum.sendingError_4;
          await _dao.updateWaterConsumptionsDao(waterConsumptionModel);
        }
        setAmount();
      }
    } finally {
      processListSendsWaterConsumptionOdooInExec = false;
    }
  }

  Future<void> clearWaterConsumptionsDao() async {
    await _dao.clearWaterConsumptionsDao();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await _dao.logout();
    await prefs.clear();
    Get.offAllNamed(Routes.LOGIN);
  }

  setAmount() async {
    dynamic response = await _dao.getWaterConsumptionAmounts();
    amountToRead.value = response[0]['amountToRead'];
    amountToSend.value = response[0]['amountToSend'];
    amountSend.value = response[0]['amountSend'];
  }
}
