import 'package:water_meassurement/app/config/app_constants.dart';
import 'package:water_meassurement/app/shared/models/property_water_consumption_route_custom_model.dart';
import 'package:water_meassurement/app/shared/models/property_water_consumption_route_lands_model.dart';
import 'package:water_meassurement/app/shared/utils/global.dart';
import 'package:water_meassurement/app/shared/models/land_model.dart';
import 'package:water_meassurement/app/shared/models/water_consumption_model.dart';
import 'package:intl/intl.dart';

class HomeService {
  Future<void> saveWaterConsumptionOdoo(WaterConsumptionModel wc) async {
    await odoo.write(
      AppConstants.waterConsumptionModel,
      [wc.id!],
      wc.toMap(),
    );
  }

  Future<void> saveWaterConsumptionOdooToPending(WaterConsumptionModel wc) async {
    wc.state = 'pending';

    await odoo.write(
      AppConstants.waterConsumptionModel,
      [wc.id!],
      {"state": 'pending'},
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
    String currentYearMonth = await getCurrentYear_month();

    DateTime currentYearMonth_FirstDay = DateTime.parse(currentYearMonth + '01');
    currentYearMonth_FirstDay = DateTime(currentYearMonth_FirstDay.year, currentYearMonth_FirstDay.month - 1, currentYearMonth_FirstDay.day); // Vou subtrair 1 dia pois a data da água é o mês de referência e não o mês de venvimento. (Equivalente a vw_property_settings_monthly_last.year_month_property_water_consumption)
    DateTime currentYearMonth_LastDay = DateTime(currentYearMonth_FirstDay.year, currentYearMonth_FirstDay.month + 1, 0);
    final dateFormat = new DateFormat('yyyy-MM-dd');
    String currentYearMonth_FirstDayOdoo = dateFormat.format(currentYearMonth_FirstDay);
    String currentYearMonth_LastDayOdoo = dateFormat.format(currentYearMonth_LastDay);

    final response = await odoo.searchRead(
      AppConstants.waterConsumptionModel,
      [
        ["date", ">=", currentYearMonth_FirstDayOdoo],
        ["date", "<=", currentYearMonth_LastDayOdoo]
      ],
      [
        "id",
        "land_id",
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

  Future<List<Property_water_consumption_route_custom>> getProperty_water_consumption_route_custom() async {

    final response = await odoo.searchRead(
      AppConstants.property_water_consumption_route_custom,
      [
        ["active", "=", "True"]
      ],
      [
        "id",
        "name",
        "route_id",
      ],
    );

    final List json = response.getRecords();
    final listRoutes =
    json.map((e) => Property_water_consumption_route_custom.fromJson(e)).toList();

    return listRoutes;
  }

  Future<List<Property_water_consumption_route_lands>> getProperty_water_consumption_route_lands() async {

    final response = await odoo.searchRead(
      AppConstants.property_water_consumption_route_lands,
      [
        ["routecustom_id.active", "=", true]
      ],
      [
        "id",
        "routecustom_id",
        "land_id",
        "land_id_module_id_code",
        "land_id_block_id_code",
        "land_id_lot_id_code",
        "sequence",
      ],
    );

    final List json = response.getRecords();
    final listRoutes = json.map((e) => Property_water_consumption_route_lands.fromJson(e)).toList();

    return listRoutes;
  }

  Future<String> getCurrentYear_month() async {
    final response =
        await odoo.searchRead(AppConstants.propertyWaterCatchmentMonthlyRate, [], ['year_month'], limit: 1, order: 'year_month desc');

    final List json = response.getRecords();
    String currentYearMonth = json[0]['year_month'].toString();
    return currentYearMonth;
  }
}
