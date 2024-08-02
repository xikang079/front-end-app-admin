import 'dart:ui';

import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../apps/apps_colors.dart';
import '../models/crab_type_model.dart';
import '../services/crab_type_service.dart';

class CrabTypeController extends GetxController {
  final ApiServiceCrabType apiServiceCrabType = ApiServiceCrabType();
  var crabTypes = <CrabType>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCrabTypes();
  }

  Future<void> fetchCrabTypes() async {
    isLoading.value = true;
    EasyLoading.show(status: 'Đang tải...');
    try {
      List<CrabType> fetchedCrabTypes =
          await apiServiceCrabType.getAllCrabTypes();
      crabTypes.assignAll(fetchedCrabTypes);
    } catch (e) {
      showSnackbar(
          'Lỗi', 'Không thể tải danh sách loại cua', AppColors.errorColor);
    } finally {
      isLoading.value = false;
      EasyLoading.dismiss();
    }
  }

  void showSnackbar(String title, String message, Color backgroundColor) {
    Get.snackbar(title, message,
        backgroundColor: backgroundColor, colorText: AppColors.buttonTextColor);
  }
}
