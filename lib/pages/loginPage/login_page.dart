import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../../widgets/touch_off_keyboard.dart';
import '../../../widgets/animated_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../../apps/apps_colors.dart';
import '../../controllers/auth_controller.dart';

class LoginPage extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginPage({super.key});

  void _handleLogin() {
    if (!authController.isLoggedIn.value) {
      EasyLoading.show(status: 'Đang đăng nhập...');
      authController.login(usernameController.text, passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TouchOutsideToDismissKeyboard(
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Obx(() {
          if (authController.isCheckingLoginStatus.value) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 80),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage(
                            'assets/logo.png',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Quản lí vựa cua',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 32.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Vui lòng đăng nhập tài khoản của bạn',
                      style: TextStyle(
                        color: AppColors.textColor,
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 32),
                    CustomTextField(
                      controller: usernameController,
                      labelText: 'Tên đăng nhập',
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: passwordController,
                      labelText: 'Mật khẩu',
                      isPassword: true,
                    ),
                    const SizedBox(height: 32),
                    AnimatedButton(
                      text: 'Đăng nhập',
                      onPressed: _handleLogin,
                    ),
                    const SizedBox(height: 16),
                    Obx(() {
                      if (authController.isLoggedIn.value) {
                        return Text(
                          'Đã đăng nhập: ${authController.user.value?.username}',
                          style: const TextStyle(color: AppColors.textColor),
                        );
                      } else {
                        return const Text(
                          'Chưa đăng nhập',
                          style: TextStyle(color: AppColors.textColor),
                        );
                      }
                    }),
                  ],
                ),
              ),
            );
          }
        }),
      ),
    );
  }
}
