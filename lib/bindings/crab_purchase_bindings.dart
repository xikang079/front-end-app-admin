import 'package:get/get.dart';
import '../controllers/crab_purchase_controller.dart';

class CrabPurchaseBinding extends Bindings {
  @override
  void dependencies() {
    String? depotId = Get.arguments['depotId'];
    if (depotId != null) {
      Get.lazyPut<CrabPurchaseController>(
          () => CrabPurchaseController(depotId));
    } else {
      throw Exception('depotId is null');
    }
  }
}
