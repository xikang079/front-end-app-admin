import 'dart:ui';

import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../models/trader_model.dart';
import '../services/trader_service.dart';
import '../apps/apps_colors.dart';

class TraderController extends GetxController {
  final ApiServiceTrader apiServiceTrader = ApiServiceTrader();
  var traders = <Trader>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTraders();
  }

  Future<void> fetchTraders() async {
    isLoading.value = true;
    EasyLoading.show(status: 'Đang tải...');
    try {
      List<Trader> fetchedTraders = await apiServiceTrader.getAllTraders();
      traders.assignAll(fetchedTraders);
    } catch (e) {
      showSnackbar(
          'Lỗi', 'Không thể tải danh sách thương lái', AppColors.errorColor);
    } finally {
      isLoading.value = false;
      EasyLoading.dismiss();
    }
  }

  void showSnackbar(String title, String message, Color backgroundColor) {
    Get.snackbar(
      title,
      message,
      backgroundColor: backgroundColor,
      colorText: AppColors.buttonTextColor,
    );
  }
}
