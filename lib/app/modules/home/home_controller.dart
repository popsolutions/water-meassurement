import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:water_meassurement/app/config/app_routes.dart';
import 'package:water_meassurement/app/modules/auth/auth_controller.dart';
import 'package:water_meassurement/app/modules/home/home_service.dart';
import 'package:water_meassurement/app/shared/data/dao/water_consumption_dao.dart';
import 'package:water_meassurement/app/shared/enums/enums.dart';
import 'package:water_meassurement/app/shared/models/land_model.dart';
import 'package:water_meassurement/app/shared/models/property_water_consumption_route_custom_model.dart';
import 'package:water_meassurement/app/shared/models/water_consumption_model.dart';
import 'package:package_info_plus/package_info_plus.dart';

class HomeController extends GetxController {
  final HomeService _service;
  final WaterConsumptionDao _dao;
  HomeController(this._service, this._dao);

  var lands = <LandModel>[].obs;
  var waterConsumptions = <WaterConsumptionModel>[].obs;
  var listRouteCustom = <Property_water_consumption_route_custom>[].obs;
  var isLoading = false.obs;
  final format = DateFormat('MM/dd/yyyy');
  var currentWaterConsumption = WaterConsumptionModel();
  Property_water_consumption_route_custom? currentRouteCustom;
  final landEC = TextEditingController();
  final currentReadEC = TextEditingController();
  var currentReadEC_focusNode = FocusNode();
  final lastReadEC = TextEditingController();
  var titleAppBar = ['Nova Leitura', 'Perfil'];
  var index = 0.obs;
  String currentYear_month = '';
  var currentYear_monthText = ''.obs;
  String appVersion = '';
  List<String> monthsName = ['', 'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
  final selectedRouteEC = TextEditingController();

  var amountToRead = 0.obs;
  var amountToSend = 0.obs;
  var amountSend = 0.obs;

  bool processListSendsWaterConsumptionOdooInExec = false;

  @override
  onInit() async {
    super.onInit();

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appVersion = packageInfo.version;

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

    final routeCustomDao = await _dao.getRouteCustomDao();
    if (routeCustomDao.isNotEmpty) {
      listRouteCustom.value = routeCustomDao;
    }

    DateTime currentYearMonth_Date = DateTime.parse(waterConsumptionsDao[0].date!);
    currentYearMonth_Date = DateTime(currentYearMonth_Date.year, currentYearMonth_Date.month + 1, currentYearMonth_Date.day); // Vou adcionar 1 dia pois a data da água é o mês de referência e não o mês de venvimento. (Equivalente a vw_property_settings_monthly_last.year_month_property_water_consumption)

    currentYear_month = currentYearMonth_Date.year.toString() + currentYearMonth_Date.month.toString().padLeft(2, '0');
    currentYear_monthText.value = monthsName[currentYearMonth_Date.month] + '/' + currentYearMonth_Date.year.toString();

    setAmount();
  }

  Future<void> loginSaveWaterConsumptionsDB(bool loginIsOnline) async {
    //verificar se é necessário carregar o celular com property.water.consumption
    final waterConsumptionsDao = await _dao.getWaterConsumptionsDao();

    if (loginIsOnline){
      if (waterConsumptionsDao.isEmpty) {

        final waterConsumptionsApi = await _service.getWaterConsumptions();
        await _dao.saveWaterConsumptionsDaoList(waterConsumptionsApi);

        final property_water_consumption_route_custom = await _service.getProperty_water_consumption_route_custom();
        await _dao.saveProperty_water_consumption_route_customDaoList(property_water_consumption_route_custom);

        final property_water_consumption_route_lands = await _service.getProperty_water_consumption_route_lands();
        await _dao.saveProperty_water_consumption_route_landsDaoList(property_water_consumption_route_lands);

        print('Dao Atualizado.');
      }
    }
  }

  Future<void> saveWaterConsumptionDao(BuildContext context) async {
    final _authProvider = Provider.of<AuthController>(context, listen: false);
    currentWaterConsumption.readerId = _authProvider.currentUser.partnerId;
    currentWaterConsumption.date = format.format(DateTime.now());
    currentWaterConsumption.statesendserver = StateSendServerEnum.read_2;
    currentWaterConsumption.read_datetime = DateTime.now();

    if (currentRouteCustom != null){
      currentWaterConsumption.route_custom_id = currentRouteCustom!.id;
      currentWaterConsumption.route_sequence = await _dao.getRoute_readSequence(currentWaterConsumption.landId ?? 0, currentRouteCustom!.id);
    }

    currentWaterConsumption.route_realreadsequence = await _dao.getRoute_realReadSequence();

    await _dao.updateWaterConsumptionsDao(currentWaterConsumption);
    setAmount();
    processListSendsWaterConsumptionOdoo();
    setNextRead();
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

          await _service.saveWaterConsumptionOdooToPending(waterConsumptionModel);
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
    amountToRead.value = response[0]['amountToRead'] ?? 0;
    amountToSend.value = response[0]['amountToSend'] ?? 0;
    amountSend.value = response[0]['amountSend'] ?? 0;
  }

  setNextRead() async {
    int nextReadLand_id = 0;

    if (currentRouteCustom != null) {
      nextReadLand_id = await _dao.getNextRead(currentRouteCustom?.id ?? 0);
    }

    currentWaterConsumption = waterConsumptions.firstWhere((wc) => wc.landId == nextReadLand_id);

    landEC.text = currentWaterConsumption.landName ?? '';
    lastReadEC.text = (currentWaterConsumption.lastRead ?? 0).toStringAsFixed(0);

    if (currentWaterConsumption.currentRead == 0)
      currentReadEC.clear();
    else
      currentReadEC.text = (currentWaterConsumption.currentRead ?? 0).toStringAsFixed(0);

    currentReadEC_focusNode.requestFocus();
  }
}
