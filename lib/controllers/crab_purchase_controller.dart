import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../models/crab_purchase_model.dart';
import '../services/crab_purchase_service.dart';

class CrabPurchaseController extends GetxController {
  var crabPurchases = <CrabPurchase>[].obs;
  var isLoading = false.obs;
  final ApiCrabPurchaseService apiService = ApiCrabPurchaseService();

  void fetchCrabPurchasesByDate(String depotId, DateTime date) async {
    EasyLoading.show(status: 'Loading...');
    isLoading.value = true;
    try {
      var fetchedCrabPurchases =
          await apiService.getCrabPurchasesByDate(depotId, date);
      crabPurchases.assignAll(fetchedCrabPurchases);
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch crab purchases');
    } finally {
      isLoading.value = false;
      EasyLoading.dismiss();
    }
  }

  void fetchCrabPurchasesByDateRange(
      String depotId, DateTime startDate, DateTime endDate) async {
    EasyLoading.show(status: 'Loading...');
    isLoading.value = true;
    try {
      var fetchedCrabPurchases = await apiService.getCrabPurchasesByDateRange(
          depotId, startDate, endDate);
      crabPurchases.assignAll(fetchedCrabPurchases);
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch crab purchases');
    } finally {
      isLoading.value = false;
      EasyLoading.dismiss();
    }
  }
}
