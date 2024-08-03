import 'package:get/get.dart';
import '../controllers/daily_summary_controller.dart';

class DailySummaryBinding extends Bindings {
  @override
  void dependencies() {
    String? depotId = Get.arguments['depotId'];
    if (depotId != null) {
      Get.lazyPut<DailySummaryController>(
          () => DailySummaryController(depotId));
    } else {
      throw Exception('depotId is null');
    }
  }
}
