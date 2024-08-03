import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../apps/apps_colors.dart';
import '../models/daily_summary_model.dart';
import '../services/daily_summary_service.dart';
import '../services/local_storage_service.dart';

class DailySummaryController extends GetxController {
  final ApiServiceDailySummary apiService = ApiServiceDailySummary();
  var dailySummary = DailySummary(
    id: '',
    depot: '',
    details: [],
    totalAmount: 0,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ).obs;
  var dailySummaries = <DailySummary>[].obs;
  var isLoading = false.obs;
  var dailySummaryIndex = 0.obs;
  var selectedMonth = DateTime.now().month.obs;
  var selectedYear = DateTime.now().year.obs;
  var errorMessage = ''.obs;
  late final String depotId;

  DailySummaryController(this.depotId);

  @override
  void onInit() {
    super.onInit();
    fetchDailySummariesByDepotAndMonth(selectedMonth.value, selectedYear.value);
  }

  Future<void> fetchDailySummariesByDepotAndMonth(int month, int year) async {
    isLoading.value = true;
    EasyLoading.show(status: 'Đang tải...');
    dailySummaries.clear(); // Clear old data before fetching new data
    try {
      List<DailySummary> fetchedDailySummaries = await apiService
          .getDailySummariesByDepotAndMonth(depotId, month, year);
      dailySummaries.assignAll(fetchedDailySummaries);
      dailySummaryIndex.value++;
    } catch (e) {
      errorMessage.value = 'Failed to fetch daily summaries by month: $e';
    } finally {
      isLoading.value = false;
      EasyLoading.dismiss();
    }
  }
}
