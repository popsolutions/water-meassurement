import 'package:get/get.dart';
import 'package:water_meassurement/app/modules/auth/auth_controller.dart';
import 'package:water_meassurement/app/modules/home/dao/land_dao.dart';
import 'package:water_meassurement/app/modules/home/home_controller.dart';
import 'package:water_meassurement/app/modules/home/home_service.dart';
import 'package:water_meassurement/app/modules/login/login_controller.dart';
import 'package:water_meassurement/app/modules/login/login_service.dart';

class AppBindings implements Bindings {
  final _homeService = Get.put(HomeService());
  final _homeDao = Get.put(LandDao());

  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());
    Get.lazyPut<HomeController>(() => HomeController(_homeService, _homeDao));
    Get.lazyPut<AuthController>(() => AuthController(Get.put(LoginService())));
  }
}