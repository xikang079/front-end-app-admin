import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../controllers/auth_controller.dart';
import '../../apps/apps_colors.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  final AuthController authController = Get.find<AuthController>();
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    // Đảm bảo chỉ navigate một lần
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateBasedOnAuthStatus();
    });
  }

  void _navigateBasedOnAuthStatus() {
    if (_hasNavigated) return;

    // Delay để tránh lỗi navigation
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_hasNavigated) return;

      // Kiểm tra cả isLoggedIn và user để đảm bảo chắc chắn
      if (authController.isLoggedIn.value &&
          authController.user.value != null) {
        _hasNavigated = true;
        Get.offAllNamed('/home');
      } else {
        _hasNavigated = true;
        Get.offAllNamed('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Obx(() {
        if (authController.isCheckingLoginStatus.value) {
          return _buildLoadingScreen();
        } else {
          EasyLoading.dismiss();
          if (!_hasNavigated) {
            _navigateBasedOnAuthStatus();
          }
          return _buildLoadingScreen();
        }
      }),
    );
  }

  Widget _buildLoadingScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primaryColor.withOpacity(0.1),
            AppColors.backgroundColor,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
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
                children: [
                  CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
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
          ],
        ),
      ),
    );
  }
}
