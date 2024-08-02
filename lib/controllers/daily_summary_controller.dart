import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../models/daily_summary_model.dart';
import '../services/daily_summary_service.dart';

class DailySummaryController extends GetxController {
  var dailySummaries = <DailySummary>[].obs;
  var isLoading = false.obs;
  var selectedMonth = DateTime.now().month.obs;
  var selectedYear = DateTime.now().year.obs;
  var errorMessage = ''.obs;
  var dailySummary = DailySummary(
    id: '',
    depot: '',
    details: [],
    totalAmount: 0,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ).obs;
  final ApiDailySummaryService apiService = ApiDailySummaryService();

  void fetchDailySummariesByDepotAndDate(String depotId, DateTime date) async {
    EasyLoading.show(status: 'Loading...');
    isLoading.value = true;
    try {
      var fetchedDailySummaries =
          await apiService.getDailySummariesByDepotAndDate(depotId, date);
      dailySummaries.assignAll(fetchedDailySummaries);
    } catch (e) {
      errorMessage.value = 'Failed to fetch daily summaries';
    } finally {
      isLoading.value = false;
      EasyLoading.dismiss();
    }
  }

  void fetchDailySummariesByDepotAndMonth(
      String depotId, int month, int year) async {
    EasyLoading.show(status: 'Loading...');
    isLoading.value = true;
    try {
      var fetchedDailySummaries = await apiService
          .getDailySummariesByDepotAndMonth(depotId, month, year);
      dailySummaries.assignAll(fetchedDailySummaries);
    } catch (e) {
      errorMessage.value = 'Failed to fetch daily summaries';
    } finally {
      isLoading.value = false;
      EasyLoading.dismiss();
    }
  }
}
