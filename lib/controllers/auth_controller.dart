import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../apps/apps_colors.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/local_storage_service.dart';

class AuthController extends GetxController {
  var isLoggedIn = false.obs;
  var user = Rx<User?>(null);
  var isCheckingLoginStatus = false.obs;

  final ApiAuthService apiService = ApiAuthService();

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    if (isCheckingLoginStatus.value) return;
    isCheckingLoginStatus.value = true;

    String? token = await LocalStorageService.getToken();
    String? userId = await LocalStorageService.getUserId();
    if (token != null &&
        token.isNotEmpty &&
        userId != null &&
        userId.isNotEmpty) {
      var isValid = await apiService.checkTokenValidity(token, userId);
      if (isValid) {
        var userDetails = await apiService.fetchUserDetails(token, userId);
        if (userDetails != null) {
          user.value = userDetails;
          user.value?.accessToken = token;
          isLoggedIn.value = true;
          LocalStorageService.saveToken(token);
        } else {
          logout();
        }
      } else {
        logout();
      }
    } else {
      isLoggedIn.value = false;
    }

    isCheckingLoginStatus.value = false;
  }

  void login(String username, String password) async {
    EasyLoading.show(status: 'Đang đăng nhập...');
    var response = await apiService.login(username, password);
    EasyLoading.dismiss();

    if (response != null) {
      if (response.role == 'admin') {
        user.value = response;
        isLoggedIn.value = true;
        await LocalStorageService.saveToken(response.accessToken);
        await LocalStorageService.saveUserId(response.id);
        Get.offAllNamed('/home');
        Get.snackbar(
          'Thành công',
          'Đã đăng nhập thành công',
          backgroundColor: AppColors.snackBarSuccessColor,
          colorText: AppColors.buttonTextColor,
        );
      } else {
        Get.snackbar(
          'Lỗi',
          'Bạn không có quyền vào app quản lí',
          backgroundColor: AppColors.errorColor,
          colorText: AppColors.buttonTextColor,
        );
      }
    } else {
      Get.snackbar(
        'Lỗi',
        'Thông tin đăng nhập không chính xác',
        backgroundColor: AppColors.errorColor,
        colorText: AppColors.buttonTextColor,
      );
    }
  }

  void logout() async {
    await LocalStorageService.clearToken();
    await LocalStorageService.clearUserId();
    isLoggedIn.value = false;
    user.value = null;
    Get.offAllNamed('/login');
  }
}
