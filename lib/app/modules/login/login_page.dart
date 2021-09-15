import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:water_meassurement/app/config/app_images.dart';
import 'package:water_meassurement/app/config/app_routes.dart';
import 'package:water_meassurement/app/modules/auth/auth_controller.dart';
import 'package:water_meassurement/app/modules/home/home_controller.dart';
import 'package:water_meassurement/app/shared/models/user_model.dart';
import 'login_controller.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthController auth = Get.find();
  final LoginController controller = Get.find();
  final HomeController homeController = Get.find();

  @override
  void initState() {
    super.initState();
    auth.emailEC.text = 'support@popsolutions.co';
    auth.passwordEC.text = '1ND1C0p4c1f1c0';
  }

  @override
  void dispose() {
    super.dispose();
    auth.emailEC.dispose();
    auth.passwordEC.dispose();
  }

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
                        controller: auth.emailEC,
                        decoration: InputDecoration(
                          suffixIcon: Icon(Icons.person),
                        ),
                      ),
                      SizedBox(height: 10),
                      Obx(() {
                        return TextFormField(
                          controller: auth.passwordEC,
                          obscureText: controller.isPasswordObscure.value,
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.isPasswordObscure.value
                                    ? Icons.visibility_off
                                    : Icons.remove_red_eye,
                              ),
                              onPressed: () {
                                controller.isPasswordObscure.value =
                                    !controller.isPasswordObscure.value;
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
                            controller.isLoading.value = true;
                            final authProvider = Provider.of<AuthController>(
                              context,
                              listen: false,
                            );

                            await authProvider.login(
                              UserModel(
                                username: 'support@popsolutions.co',
                                password: '1ND1C0p4c1f1c0',
                              ),
                            );

                            await authProvider.getImage();
                            await homeController.loginSaveWaterConsumptionsDB();
                            controller.isLoading.value = false;
                            Get.offNamed(Routes.HOME);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
                Obx(() {
                  return Visibility(
                    visible: controller.isLoading.value,
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          color: Colors.transparent,
          height: 40,
          margin: const EdgeInsets.only(bottom: 20),
          child: Image.asset(
            AppImages.logo,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
