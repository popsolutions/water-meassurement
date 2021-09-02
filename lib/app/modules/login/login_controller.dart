import 'package:get/get.dart';
import 'package:water_meassurement/app/config/app_routes.dart';
import 'package:water_meassurement/app/modules/login/login_service.dart';
import 'package:water_meassurement/app/shared/models/user_model.dart';

class LoginController extends GetxController {
  var isPasswordVisible = false.obs;
  final _service = LoginService();
  UserModel? user;

  Future login(UserModel user) async {
    user = await _service.login(user);
  }

  contemUsuario() {
    if (user != null) {
      Get.offNamed(Routes.HOME);
    } else {
      return;
    }
  }
}
