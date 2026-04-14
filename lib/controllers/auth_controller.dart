import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'dart:convert';

import '../apps/apps_colors.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/local_storage_service.dart';

class AuthController extends GetxController {
  var isLoggedIn = false.obs;
  var user = Rx<User?>(null);
  var isCheckingLoginStatus = false.obs;
  var isOfflineMode = false.obs; // Flag để theo dõi chế độ offline

  final ApiAuthService apiService = ApiAuthService();

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    if (isCheckingLoginStatus.value) return;
    isCheckingLoginStatus.value = true;

    try {
      // Kiểm tra xem có dữ liệu offline không
      bool hasOfflineData = await LocalStorageService.hasOfflineData();

      if (hasOfflineData) {
        // Sử dụng dữ liệu offline để đăng nhập ngay lập tức
        await _loadOfflineUserData();

        // Đảm bảo user đã được set trước khi kiểm tra background
        if (user.value != null) {
          isLoggedIn.value = true;
          isOfflineMode.value = true; // Đánh dấu đang ở chế độ offline

          // Kiểm tra token validity ở background (không ảnh hưởng đến trạng thái đăng nhập)
          String? token = await LocalStorageService.getToken();
          String? userId = await LocalStorageService.getUserId();
          if (token != null && userId != null) {
            _validateTokenInBackground(token, userId);
          }
        } else {
          isLoggedIn.value = false;
          isOfflineMode.value = false;
        }
      } else {
        isLoggedIn.value = false;
        isOfflineMode.value = false;
      }
    } catch (e) {
      print('Error checking login status: $e');
      // Nếu có lỗi, vẫn cố gắng load offline data
      try {
        await _loadOfflineUserData();
        if (user.value != null) {
          isLoggedIn.value = true;
        } else {
          isLoggedIn.value = false;
        }
      } catch (e2) {
        print('Error loading offline data: $e2');
        isLoggedIn.value = false;
      }
    } finally {
      isCheckingLoginStatus.value = false;
    }
  }

  // Tạo user object cơ bản khi không có dữ liệu đầy đủ
  User _createBasicUser(String userId, String token) {
    return User(
      id: userId,
      fullname: 'User',
      username: 'user',
      role: 'admin',
      status: true,
      depotName: 'Default Depot',
      address: 'N/A',
      phone: 'N/A',
      accessToken: token,
      refreshToken: '',
    );
  }

  // Tải dữ liệu user từ offline storage
  Future<void> _loadOfflineUserData() async {
    try {
      String? token = await LocalStorageService.getToken();
      String? userId = await LocalStorageService.getUserId();
      String? userDataJson = await LocalStorageService.getUserData();

      if (token != null && userId != null) {
        if (userDataJson != null) {
          // Nếu có dữ liệu user đầy đủ, sử dụng nó
          try {
            var userDataMap = jsonDecode(userDataJson) as Map<String, dynamic>;
            var userData = User.fromJson(userDataMap);
            userData.accessToken = token;
            user.value = userData;
          } catch (e) {
            // Nếu parse JSON lỗi, tạo user object cơ bản
            user.value = _createBasicUser(userId, token);
          }
        } else {
          // Nếu không có dữ liệu user đầy đủ, tạo user object cơ bản
          user.value = _createBasicUser(userId, token);
        }
        isLoggedIn.value = true;
      }
    } catch (e) {
      print('Error loading offline user data: $e');
      isLoggedIn.value = false;
    }
  }

  // Kiểm tra token ở background mà không logout
  void _validateTokenInBackground(String token, String userId) async {
    try {
      var isValid = await apiService.checkTokenValidity(token, userId);
      if (isValid) {
        var userDetails = await apiService.fetchUserDetails(token, userId);
        if (userDetails != null) {
          // Cập nhật thông tin user nếu có mạng và token hợp lệ
          user.value = userDetails;
          user.value?.accessToken = token;
          await LocalStorageService.saveToken(token);
          // Lưu dữ liệu user đầy đủ để sử dụng offline
          await LocalStorageService.saveUserData(userDetails.toJson());
          isOfflineMode.value = false; // Có mạng, thoát chế độ offline
        }
        // Nếu không lấy được userDetails, vẫn giữ đăng nhập với thông tin cũ
      }
      // Nếu token không hợp lệ, vẫn giữ đăng nhập (chỉ logout khi user tự logout)
    } catch (e) {
      // Bỏ qua lỗi mạng, giữ đăng nhập và ở chế độ offline
      print('Token validation failed but keeping user logged in: $e');
      isOfflineMode.value = true; // Đánh dấu đang ở chế độ offline
    }
  }

  void login(String username, String password) async {
    EasyLoading.show(status: 'Đang đăng nhập...');
    var response = await apiService.login(username, password);
    EasyLoading.dismiss();

    if (response != null) {
      if (response.role == 'admin') {
        user.value = response;
        isLoggedIn.value = true;
        isOfflineMode.value = false; // Đăng nhập thành công, có mạng
        await LocalStorageService.saveToken(response.accessToken);
        await LocalStorageService.saveUserId(response.id);
        // Lưu dữ liệu user đầy đủ để sử dụng offline
        await LocalStorageService.saveUserData(response.toJson());
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
    await LocalStorageService.clearAllData();
    isLoggedIn.value = false;
    user.value = null;
    isOfflineMode.value = false; // Reset flag offline khi logout
    Get.offAllNamed('/login');
  }
}
