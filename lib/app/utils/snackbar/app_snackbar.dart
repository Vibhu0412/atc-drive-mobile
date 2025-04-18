import 'package:atc_drive/app/controller/home_controller.dart';
import 'package:atc_drive/app/utils/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSnackBar {
  static void error({
    String title = AppStrings.error,
    required String message,
    Color backgroundColor = Colors.red,
    Icon icon = const Icon(Icons.error),
    Duration duration = const Duration(seconds: 2),
  }) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: backgroundColor,
      icon: icon,
      duration: duration,
    );
  }

  static void info({
    String title = AppStrings.info,
    required String message,
    Color backgroundColor = Colors.black,
    Duration duration = const Duration(seconds: 2),
  }) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: backgroundColor,
      duration: duration,
    );
  }

  static void success({
    String title = AppStrings.success,
    required String message,
    Color backgroundColor = Colors.green,
    Icon icon = const Icon(Icons.check),
    Duration duration = const Duration(seconds: 2),
  }) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: backgroundColor,
      icon: icon,
      duration: duration,
    );
  }

  static void _showSnackbar({
    required String title,
    required String message,
    required Color backgroundColor,
    Icon? icon,
    required Duration duration,
  }) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
    Get.showSnackbar(GetSnackBar(
      title: title,
      message: message,
      backgroundColor: backgroundColor,
      icon: icon,
      duration: duration,
      key: Key(title.runtimeType.toString()),
    ));
  }

  static void showDownloadSnackbar(String fileName) {
    Get.showSnackbar(
      GetSnackBar(
        message: "1 item will be downloaded. See notification for details.",
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        margin: const EdgeInsets.all(10),
        borderRadius: 8,
        isDismissible: true,
      ),
    );
  }

  static void showLogoutConfirmation(HomeController controller) {
    Get.dialog(
      Theme(
        data: Theme.of(Get.context!).copyWith(
          dialogBackgroundColor: Colors.grey[900],
          textTheme: TextTheme(
            titleLarge: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            bodyMedium: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Text(
            "Logout",
            style: Get.textTheme.bodyLarge,
          ),
          content: Text(
            "Are you sure you want to logout?",
            style: Get.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text(
                "No",
                style: TextStyle(color: Colors.blue),
              ),
            ),
            TextButton(
              onPressed: () {
                Get.back();

                controller.logout();
              },
              child: const Text(
                "Yes",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }
}
