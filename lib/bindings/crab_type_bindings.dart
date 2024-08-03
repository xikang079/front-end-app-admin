import 'package:get/get.dart';
import '../controllers/crab_type_controller.dart';

class CrabTypeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CrabTypeController>(() {
      final depotId = Get.arguments['depotId'] as String;
      return CrabTypeController(depotId);
    });
  }
}
