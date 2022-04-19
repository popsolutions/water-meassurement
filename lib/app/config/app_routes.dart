import 'package:get/get.dart';
import 'package:water_meassurement/app/modules/login/login_page.dart';
import 'package:water_meassurement/app/modules/home/home_page.dart';
import 'app_bindings.dart';

class AppRoutes {
  static final routes = [
    GetPage(
      name: Routes.LOGIN,
      page: () => LoginPage(),
      binding: AppBindings(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => HomePage(),
      binding: AppBindings(),
    ),
  ];
}

class Routes {
  static const LOGIN = '/login';
  static const HOME = '/home';
}
