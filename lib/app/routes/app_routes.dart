import 'package:atc_drive/app/controller/home_controller.dart';
import 'package:atc_drive/app/ui/auth/login_screen.dart';
import 'package:atc_drive/app/ui/home/home_screen.dart';
import 'package:get/get.dart';

class AppRoutes {
  static const login = '/login';
  static const home = '/home';
}

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.login,
      page: () => LoginScreen(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => HomeScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => HomeController());
      }),
    ),
  ];
}
