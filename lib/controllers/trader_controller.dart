import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../models/trader_model.dart';
import '../services/trader_service.dart';
import 'crab_purchase_controller.dart';

class TraderController extends GetxController {
  var traders = <Trader>[].obs;
  var isLoading = true.obs;
  final ApiServiceTrader traderService = ApiServiceTrader();
  late final String depotId;
  late final CrabPurchaseController crabPurchaseController;

  TraderController(this.depotId);

  @override
  void onInit() {
    super.onInit();
    crabPurchaseController = Get.put(CrabPurchaseController(depotId));
    fetchTraders();
  }

  void fetchTraders() async {
    try {
      isLoading(true);
      EasyLoading.show(status: 'Đang tải dữ liệu...');
      var fetchedTraders = await traderService.getAllTraders(depotId);
      traders.assignAll(fetchedTraders);
      crabPurchaseController.fetchCrabPurchasesByDate(DateTime.now());
    } finally {
      isLoading(false);
      EasyLoading.dismiss();
    }
  }

  bool hasSoldCrabs(String traderId) {
    return crabPurchaseController.hasSoldCrabsByTrader(traderId);
  }
}
