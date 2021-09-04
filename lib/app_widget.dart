import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:water_meassurement/app/config/app_routes.dart';
import 'package:water_meassurement/app/modules/auth/auth_controller.dart';

class AppWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => AuthController()),
      ],
      child: GetMaterialApp(
        theme: ThemeData(
          primaryColor: Color(0xFF244579),
          accentColor: Color(0xFF244579),
          scaffoldBackgroundColor: Color(0xFF244579),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              primary: Color(0xFF244579),
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
