import 'package:get/get.dart';
import '../controllers/trader_controller.dart';

class TraderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TraderController>(() {
      final depotId = Get.arguments['depotId'] as String;
      return TraderController(depotId);
    });
  }
}
