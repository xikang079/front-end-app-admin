import 'package:get/get.dart';
import '../controllers/data_management_controller.dart';

class DataManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DataManagementController>(() => DataManagementController());
  }
}

