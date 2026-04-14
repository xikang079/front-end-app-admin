import 'package:get/get.dart';
import '../models/data_management_model.dart';
import '../services/data_management_service.dart';

class DataManagementController extends GetxController {
  final DataManagementService _service = DataManagementService();

  // Loading states
  final isLoading = false.obs;
  final isLoadingBackups = false.obs;
  final isDeleting = false.obs;
  final isRestoring = false.obs;

  // Statistics
  final statistics = Rxn<DataStatistics>();
  final todayStatistics = Rxn<DataStatistics>();

  // Backups
  final backupList = <BackupInfo>[].obs;
  final selectedBackupPreview = Rxn<BackupPreview>();

  // Delete mode
  final selectedDeleteMode = DeleteMode.today.obs;

  // Depot selection: null = tất cả vựa
  final selectedDepotId = Rxn<String>();

  // Date selections for custom/by-date modes
  final selectedDate = Rxn<DateTime>();
  final selectedStartDate = Rxn<DateTime>();
  final selectedEndDate = Rxn<DateTime>();

  // Error handling
  final errorMessage = ''.obs;
  final isApiUnavailable = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadStatistics();
    loadTodayStatistics();
  }

  // ==================== STATISTICS ====================

  /// Load thống kê tổng - không truyền depotId để lấy tất cả vựa
  Future<void> loadStatistics() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      isApiUnavailable.value = false;

      final result = await _service.getStatistics(depotId: selectedDepotId.value);
      statistics.value = result;
    } catch (e) {
      if (e.toString().contains('API_NOT_AVAILABLE_404')) {
        isApiUnavailable.value = true;
        errorMessage.value = 'API Quản lý Dữ liệu chưa sẵn sàng';
      } else {
        errorMessage.value = 'Lỗi khi tải thống kê: $e';
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Load thống kê hôm nay
  Future<void> loadTodayStatistics() async {
    try {
      final result = await _service.getStatisticsToday(depotId: selectedDepotId.value);
      todayStatistics.value = result;
    } catch (e) {
      print('Error loading today statistics: $e');
    }
  }

  /// Refresh thống kê khi thay đổi depot
  Future<void> refreshStatistics() async {
    await Future.wait([
      loadStatistics(),
      loadTodayStatistics(),
    ]);
  }

  // ==================== BACKUP ====================

  /// Tạo backup mới
  Future<BackupInfo?> createBackup() async {
    try {
      isLoading.value = true;
      final result = await _service.createBackup(depotId: selectedDepotId.value);
      if (result != null) {
        await loadBackupList(); // Refresh danh sách
      }
      return result;
    } catch (e) {
      errorMessage.value = 'Lỗi tạo backup: $e';
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Load danh sách backup
  Future<void> loadBackupList({int limit = 20}) async {
    try {
      isLoadingBackups.value = true;
      backupList.value = await _service.getBackupList(
        limit: limit,
        depotId: selectedDepotId.value,
      );
    } catch (e) {
      print('Error loading backup list: $e');
    } finally {
      isLoadingBackups.value = false;
    }
  }

  /// Load preview của một backup
  Future<BackupPreview?> loadBackupPreview(String backupId) async {
    try {
      isLoading.value = true;
      final result = await _service.getBackupPreview(backupId);
      selectedBackupPreview.value = result;
      return result;
    } catch (e) {
      errorMessage.value = 'Lỗi tải chi tiết backup: $e';
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== DELETE ====================

  /// Xóa dữ liệu
  /// depotId = null: xóa tất cả vựa
  Future<DeleteResult?> deleteData({required String password}) async {
    try {
      isDeleting.value = true;
      errorMessage.value = '';

      final result = await _service.deleteData(
        mode: selectedDeleteMode.value,
        password: password,
        depotId: selectedDepotId.value, // null = tất cả vựa
        date: selectedDate.value,
        startDate: selectedStartDate.value,
        endDate: selectedEndDate.value,
      );

      if (result != null) {
        // Refresh thống kê sau khi xóa
        await refreshStatistics();
      }

      return result;
    } catch (e) {
      String error = e.toString().replaceFirst('Exception: ', '');
      errorMessage.value = error;
      rethrow;
    } finally {
      isDeleting.value = false;
    }
  }

  // ==================== RESTORE ====================

  /// Khôi phục toàn bộ từ backup
  Future<RestoreResult?> restoreFull({
    required String password,
    required String backupId,
  }) async {
    try {
      isRestoring.value = true;
      errorMessage.value = '';

      final result = await _service.restoreFull(
        password: password,
        backupId: backupId,
      );

      if (result != null) {
        await refreshStatistics();
      }

      return result;
    } catch (e) {
      String error = e.toString().replaceFirst('Exception: ', '');
      errorMessage.value = error;
      rethrow;
    } finally {
      isRestoring.value = false;
    }
  }

  /// Khôi phục theo ngày từ backup
  Future<RestoreResult?> restoreByDate({
    required String password,
    required String backupId,
    required DateTime date,
  }) async {
    try {
      isRestoring.value = true;
      errorMessage.value = '';

      final result = await _service.restoreByDate(
        password: password,
        backupId: backupId,
        date: date,
      );

      if (result != null) {
        await refreshStatistics();
      }

      return result;
    } catch (e) {
      String error = e.toString().replaceFirst('Exception: ', '');
      errorMessage.value = error;
      rethrow;
    } finally {
      isRestoring.value = false;
    }
  }

  // ==================== HELPERS ====================

  /// Lấy thống kê phù hợp với chế độ xóa đang chọn
  DataStatistics? getStatisticsForSelectedMode() {
    switch (selectedDeleteMode.value) {
      case DeleteMode.today:
        return todayStatistics.value;
      default:
        return statistics.value;
    }
  }

  /// Reset date selections
  void resetDateSelections() {
    selectedDate.value = null;
    selectedStartDate.value = null;
    selectedEndDate.value = null;
  }

  /// Set depot selection
  void setDepotId(String? depotId) {
    selectedDepotId.value = depotId;
    refreshStatistics();
  }

  /// Clear all selections
  void clearSelections() {
    selectedDeleteMode.value = DeleteMode.today;
    selectedDepotId.value = null;
    resetDateSelections();
    errorMessage.value = '';
  }
}
