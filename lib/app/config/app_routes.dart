import 'package:get/get.dart';
import 'package:water_meassurement/app/modules/login/login_page.dart';
import 'package:water_meassurement/app/modules/home/home_page.dart';

class AppRoutes {
  static final routes = [
    GetPage(name: Routes.LOGIN, page: () => LoginPage()),
    GetPage(name: Routes.HOME, page: () => HomePage()),
  ];
}

class Routes {
  static const LOGIN = '/login';
  static const HOME = '/home';
}
