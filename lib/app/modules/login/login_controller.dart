import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:water_meassurement/app/config/app_routes.dart';
import 'package:water_meassurement/app/modules/auth/auth_controller.dart';

class LoginController extends GetxController {
  var isPasswordObscure = true.obs;

  containUser(BuildContext context) {
    final user = Provider.of<AuthController>(
      context,
      listen: false,
    ).currentUser;

    if (user != null) {
      Get.offNamed(Routes.HOME);
    } else {
      return;
    }
  }
}
