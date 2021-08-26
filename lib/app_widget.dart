import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:water_meassurement/app/config/app_routes.dart';

class AppWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        primaryColor: Color(0xFF244579),
        scaffoldBackgroundColor: Color(0xFF244579),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.LOGIN,
      getPages: AppRoutes.routes,
    );
  }
}
