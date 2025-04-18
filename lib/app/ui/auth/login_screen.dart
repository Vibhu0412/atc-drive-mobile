import 'package:atc_drive/app/controller/auth_controller.dart';
import 'package:atc_drive/app/utils/app_images.dart';
import 'package:atc_drive/app/utils/buttons/app_button.dart';
import 'package:atc_drive/app/utils/textfields/app_textfields.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends GetView<AuthController> {
  LoginScreen({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: AuthController(),
      builder: (controller) {
        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        AppImages.appLogo,
                        height: 100,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          AppTextField(
                            controller: controller.emailController,
                            labelText: "Email",
                            hintText: "example@gmail.com",
                            icon: Icons.person,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your username';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          AppTextField(
                            controller: controller.passwordController,
                            labelText: "Password",
                            hintText: "••••••••",
                            icon: Icons.lock,
                            isPassword: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 4) {
                                return 'Password must be at least 4 characters long';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 30),
                          // Login Button
                          Obx(() {
                            if (controller.isLoading.value) {
                              return CircularProgressIndicator();
                            }
                            return AppButton(
                              text: "Login",
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  controller.login();
                                }
                              },
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Forgot Password Link
                    /* TextButton(
                      onPressed: () {
                        Get.snackbar(
                            "Forgot Password", "Feature not implemented yet.");
                      },
                      child: const Text(
                        "Forgot password?",
                        style: TextStyle(color: Colors.blue, fontSize: 14),
                      ),
                    ), */
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
