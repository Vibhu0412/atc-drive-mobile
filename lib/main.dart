import 'package:atc_drive/app/routes/app_routes.dart';
import 'package:atc_drive/app/services/network_service.dart';
import 'package:atc_drive/app/services/notification_service.dart';
import 'package:atc_drive/app/services/storage_service.dart';
import 'package:atc_drive/app/utils/app_constants.dart';
import 'package:atc_drive/app/utils/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  String initialRoute =
      StorageService.isUserLoggedIn() ? AppRoutes.home : AppRoutes.login;
  Get.put(NetworkService());

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppThemeData.appThemeData(context, isDark: true),
      darkTheme: AppThemeData.appThemeData(context, isDark: true),
      themeMode: ThemeMode.light,
      locale: Get.deviceLocale ?? const Locale('en', 'US'),
      transitionDuration: const Duration(milliseconds: 500),
      initialRoute: initialRoute,
      getPages: AppPages.routes,
      defaultTransition: Transition.cupertino,
      defaultGlobalState: true,
      enableLog: true,
      useInheritedMediaQuery: true,
    );
  }
}
