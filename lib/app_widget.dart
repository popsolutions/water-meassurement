import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:water_meassurement/app/config/app_routes.dart';
import 'package:water_meassurement/app/shared/data/dao/UserDao.dart';

import 'app/modules/auth/auth_controller.dart';
import 'app/modules/login/login_service.dart';

class AppWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => AuthController(LoginService(), UserDao())),
      ],
      child: GetMaterialApp(
        theme: ThemeData(
          primaryColor: Color(0xFF244579),
          colorScheme:
              ThemeData().colorScheme.copyWith(secondary: Color(0xFF244579)),
          scaffoldBackgroundColor: Color(0xFF244579),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              primary: Color(0xFF244579),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            contentPadding: EdgeInsets.only(
              left: 23,
              top: 25,
              bottom: 25,
            ),
            fillColor: Color(0xFFF0F5F7),
            hintStyle: TextStyle(
              fontSize: 18,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w600,
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(
                Radius.circular(55),
              ),
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: Routes.LOGIN,
        getPages: AppRoutes.routes,
      ),
    );
  }
}
