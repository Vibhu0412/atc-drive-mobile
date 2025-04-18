import 'package:atc_drive/app/model/login_model.dart';
import 'package:atc_drive/app/routes/app_routes.dart';
import 'package:atc_drive/app/services/network_service.dart';
import 'package:atc_drive/app/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final NetworkService _networkService = Get.find();
  final TextEditingController emailController = TextEditingController(text: "");
  final TextEditingController passwordController =
      TextEditingController(text: "");

  var isLoading = false.obs;
  var loggedInUser = Rxn<LoginResponse>();

  Future<void> login() async {
    isLoading.value = true;
    try {
      final response = await _networkService.post('auth/login', body: {
        "email": emailController.text.trim(),
        "password": passwordController.text.trim()
      });

      final loginResponse = LoginResponse.fromJson(response);
      loggedInUser.value = loginResponse;

      // Save user data and tokens
      StorageService.saveUserData(response);
      StorageService.saveAccessToken(loginResponse.detail.accessToken);
      StorageService.saveRefreshToken(loginResponse.detail.refreshToken);

      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void logout() {
    loggedInUser.value = null;
    StorageService.clearAll();
    Get.offAllNamed(AppRoutes.login);
  }
}
