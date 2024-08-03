import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../models/crab_type_model.dart';
import '../services/crab_type_service.dart';
import 'crab_purchase_controller.dart';

class CrabTypeController extends GetxController {
  var crabTypes = <CrabType>[].obs;
  var isLoading = true.obs;
  final ApiServiceCrabType crabTypeService = ApiServiceCrabType();
  late final String depotId;
  late final CrabPurchaseController crabPurchaseController;

  CrabTypeController(this.depotId);

  @override
  void onInit() {
    super.onInit();
    crabPurchaseController = Get.put(CrabPurchaseController(depotId));
    fetchCrabTypes();
  }

  void fetchCrabTypes() async {
    try {
      isLoading(true);
      EasyLoading.show(status: 'Đang tải dữ liệu...');
      var fetchedCrabTypes = await crabTypeService.getAllCrabTypes(depotId);
      crabTypes.assignAll(fetchedCrabTypes);
      crabPurchaseController.fetchCrabPurchasesByDate(DateTime.now());
    } finally {
      isLoading(false);
      EasyLoading.dismiss();
    }
  }

  String? getCrabTypeNameById(String id) {
    final crabType =
        crabTypes.firstWhereOrNull((crabType) => crabType.id == id);
    return crabType?.name ?? 'Không tìm thấy loại cua';
  }

  double getCurrentWeight(String crabTypeId) {
    return crabPurchaseController.getCurrentWeightByCrabType(crabTypeId);
  }
}
