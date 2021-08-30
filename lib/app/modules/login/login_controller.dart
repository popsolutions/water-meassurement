import 'package:get/get.dart';
import 'package:water_meassurement/app/modules/login/login_service.dart';
import 'package:water_meassurement/app/shared/models/user_model.dart';

class LoginController extends GetxController {
  var isPasswordVisible = false.obs;
  final _service = LoginService();

  Future login(UserModel user) async {
    return await _service.login(user);
  }
}
