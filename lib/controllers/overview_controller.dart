import 'package:get/get.dart';
import '../services/crab_purchase_service.dart';
import '../services/user_serivce.dart';

class DepotOverviewController extends GetxController {
  var totalWeight = 0.0.obs;
  var totalCost = 0.0.obs;
  var estimatedBoxes = 0.0.obs;
  var isLoading = false.obs;

  final ApiServiceCrabPurchase crabPurchaseService = ApiServiceCrabPurchase();
  final UserService userService = UserService();

  // Danh sách để lưu trữ dữ liệu từ từng vựa
  var depotWeights = <String, double>{}.obs;
  var depotCosts = <String, double>{}.obs;
  var depotNames = <String>[].obs;

  // Biến để lưu trữ ngày đã chọn
  var selectedDate = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    fetchDepotOverview();
  }

  void fetchDepotOverview() async {
    isLoading.value = true;
    totalWeight.value = 0.0;
    totalCost.value = 0.0;
    estimatedBoxes.value = 0.0;
    depotWeights.clear();
    depotCosts.clear();
    depotNames.clear();

    try {
      DateTime selected = selectedDate.value;

      // Thiết lập thời gian bắt đầu và kết thúc theo giờ reset lúc 6h sáng
      DateTime startOfToday =
          DateTime(selected.year, selected.month, selected.day, 6, 0, 0)
              .toUtc();
      DateTime startOfTomorrow = startOfToday.add(const Duration(days: 1));

      // Lấy tất cả các user (được coi là các vựa)
      var users = await userService.getAllUsers();

      for (var user in users) {
        // Gọi API lấy dữ liệu cua từ mỗi vựa
        var crabPurchases =
            await crabPurchaseService.getCrabPurchasesByDateRange(
                user.id, startOfToday, startOfTomorrow);

        double depotTotalWeight = 0.0;
        double depotTotalCost = 0.0;

        // Tổng hợp dữ liệu cho mỗi vựa
        for (var purchase in crabPurchases) {
          depotTotalWeight +=
              purchase.crabs.fold(0.0, (sum, crab) => sum + crab.weight);
          depotTotalCost += purchase.totalCost;
        }

        // Lưu trữ dữ liệu của từng vựa
        depotWeights[user.depotName] = depotTotalWeight;
        depotCosts[user.depotName] = depotTotalCost;
        depotNames.add(user.depotName);

        // Cộng dồn vào tổng số
        totalWeight.value += depotTotalWeight;
        totalCost.value += depotTotalCost;
      }

      // Tính toán số thùng cua dự đoán
      estimatedBoxes.value = totalWeight.value / 24;
    } finally {
      isLoading.value = false;
    }
  }

  // Hàm để chọn ngày mới và tải lại dữ liệu
  void selectDate(DateTime date) {
    selectedDate.value = date;
    fetchDepotOverview();
  }
}
