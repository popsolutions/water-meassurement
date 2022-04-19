import 'package:get/get.dart';
import 'package:water_meassurement/app/modules/auth/auth_controller.dart';
import 'package:water_meassurement/app/modules/home/home_controller.dart';
import 'package:water_meassurement/app/modules/home/home_service.dart';
import 'package:water_meassurement/app/modules/login/login_controller.dart';
import 'package:water_meassurement/app/modules/login/login_service.dart';
import 'package:water_meassurement/app/shared/data/dao/water_consumption_dao.dart';

class AppBindings implements Bindings {
  final _homeService = Get.put(HomeService());
  final _loginService = Get.put(LoginService());
  final _homeDao = Get.put(WaterConsumptionDao());

  @override
  void dependencies() {
    Get.put(AuthController(_loginService));
    Get.put(LoginController());
    Get.put(HomeController(_homeService, _homeDao));
  }
}
