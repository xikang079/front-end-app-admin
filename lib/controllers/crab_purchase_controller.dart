import 'package:get/get.dart';
import '../models/crab_purchase_model.dart';
import '../services/crab_purchase_service.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class CrabPurchaseController extends GetxController {
  var crabPurchases = <CrabPurchase>[].obs;
  var isLoading = false.obs;
  final ApiServiceCrabPurchase crabPurchaseService = ApiServiceCrabPurchase();
  late final String depotId;

  CrabPurchaseController(this.depotId);

  @override
  void onInit() {
    super.onInit();
    fetchCrabPurchasesByDateRange();
  }

  void fetchCrabPurchasesByDateRange() async {
    EasyLoading.show(status: 'Đang tải hóa đơn...');
    isLoading.value = true;
    try {
      DateTime now = DateTime.now().toUtc().add(const Duration(hours: 7));
      DateTime startOfToday;
      DateTime startOfTomorrow;

      if (now.hour < 6) {
        startOfToday =
            DateTime(now.year, now.month, now.day - 1, 6, 0, 0).toUtc();
        startOfTomorrow =
            DateTime(now.year, now.month, now.day, 6, 0, 0).toUtc();
      } else {
        startOfToday = DateTime(now.year, now.month, now.day, 6, 0, 0).toUtc();
        startOfTomorrow =
            DateTime(now.year, now.month, now.day + 1, 6, 0, 0).toUtc();
      }

      var fetchedCrabPurchases = await crabPurchaseService
          .getCrabPurchasesByDateRange(depotId, startOfToday, startOfTomorrow);
      crabPurchases.assignAll(fetchedCrabPurchases);
    } finally {
      isLoading.value = false;
      EasyLoading.dismiss();
    }
  }

  void fetchCrabPurchasesByDate(DateTime date) async {
    EasyLoading.show(status: 'Đang tải hóa đơn...');
    isLoading.value = true;
    try {
      var fetchedCrabPurchases =
          await crabPurchaseService.getCrabPurchasesByDate(depotId, date);
      crabPurchases.assignAll(fetchedCrabPurchases);
    } finally {
      isLoading.value = false;
      EasyLoading.dismiss();
    }
  }

  double getCurrentWeightByCrabType(String crabTypeId) {
    double totalWeight = 0.0;
    for (var purchase in crabPurchases) {
      for (var crab in purchase.crabs) {
        if (crab.crabType.id == crabTypeId) {
          totalWeight += crab.weight;
        }
      }
    }
    return totalWeight;
  }

  bool hasSoldCrabsByTrader(String traderId) {
    return crabPurchases.any((purchase) => purchase.trader.id == traderId);
  }
}
