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
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryColor.withOpacity(0.1),
                AppColors.backgroundColor,
                AppColors.primaryColor.withOpacity(0.05),
              ],
            ),
          ),
          child: Obx(() {
            if (authController.isCheckingLoginStatus.value) {
              return _buildLoadingScreen();
            } else {
              return _buildLoginForm();
            }
          }),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
              strokeWidth: 3,
            ),
            SizedBox(height: 20),
            Text(
              'Đang kiểm tra trạng thái đăng nhập...',
              style: TextStyle(
                color: AppColors.textColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            // Logo container với shadow
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage('assets/logo.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Title
            const Text(
              'Quản lí vựa cua',
              style: TextStyle(
                color: AppColors.primaryColor,
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Vui lòng đăng nhập tài khoản của bạn',
              style: TextStyle(
                color: AppColors.textColor.withOpacity(0.8),
                fontSize: 16.0,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            // Login form container
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CustomTextField(
                    controller: usernameController,
                    labelText: 'Tên đăng nhập',
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: passwordController,
                    labelText: 'Mật khẩu',
                    isPassword: true,
                  ),
                  const SizedBox(height: 30),
                  AnimatedButton(
                    text: 'Đăng nhập',
                    onPressed: _handleLogin,
                  ),
                  const SizedBox(height: 20),
                  // Status indicator
                  Obx(() {
                    if (authController.isLoggedIn.value) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color:
                              AppColors.snackBarSuccessColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                AppColors.snackBarSuccessColor.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.snackBarSuccessColor,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Đã đăng nhập: ${authController.user.value?.username}',
                              style: const TextStyle(
                                color: AppColors.snackBarSuccessColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.textColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person_outline,
                              color: AppColors.textColor.withOpacity(0.6),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Chưa đăng nhập',
                              style: TextStyle(
                                color: AppColors.textColor.withOpacity(0.6),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  }),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
