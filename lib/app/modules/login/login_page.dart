import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:water_meassurement/app/config/app_images.dart';
import 'package:water_meassurement/app/config/app_routes.dart';
import 'package:water_meassurement/app/shared/models/user_model.dart';
import 'login_controller.dart';

class LoginPage extends GetView<LoginController> {
  final controller = Get.put(LoginController());

  


  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(statusBarColor: Colors.transparent),
      child: Scaffold(
        body: Container(
          width: Get.width,
          height: Get.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.white,
                Color(0xFF244579),
                Color(0xFF244579),
              ],
            ),
          ),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SafeArea(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(AppImages.paisagem),
                  ),
                ),
                Container(
                  width: Get.width * .9,
                  padding: const EdgeInsets.all(15),
                  margin: const EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: 'support@popsolutions.co',
                        decoration: InputDecoration(
                          suffixIcon: Icon(Icons.person),
                        ),
                      ),
                      Obx(() {
                        return TextFormField(
                          initialValue: '1ND1C0p4c1f1c0',
                          obscureText: controller.isPasswordVisible.value,
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.isPasswordVisible.value
                                    ? Icons.visibility_off
                                    : Icons.remove_red_eye,
                              ),
                              onPressed: () {
                                controller.isPasswordVisible.value =
                                    !controller.isPasswordVisible.value;
                              },
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 20),
                      Container(
                        width: Get.width,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            onPrimary: Colors.black,
                            primary: Colors.white,
                          ),
                          child: Text('Entrar'),
                          onPressed: () async {
                            await controller.login(
                              UserModel(
                                username: 'support@popsolutions.co',
                                password: '1ND1C0p4c1f1c0',
                              ),
                            );
                            Get.offNamed(Routes.HOME);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: GestureDetector(
          onTap: () async => await launch('https://popsolutions.co/'),
          child: Container(
            color: Colors.transparent,
            height: 60,
            margin: const EdgeInsets.only(bottom: 20),
            child: Image.asset(AppImages.popSolutionsLogo),
          ),
        ),
      ),
    );
  }
}
