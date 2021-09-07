import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:water_meassurement/app/config/app_routes.dart';
import 'package:water_meassurement/app/modules/auth/auth_controller.dart';

class LoginController extends GetxController {
  var isPasswordObscure = true.obs;
  final AuthController auth = Get.find();

  containUser(BuildContext context) {
    final user = auth.currentUser;

    if (user != null) {
      Get.offNamed(Routes.HOME);
    } else {
      return;
    }
  }
}
