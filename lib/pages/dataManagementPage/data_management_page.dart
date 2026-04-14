import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../../apps/format_vnd.dart' as format_vnd;
import '../../controllers/data_management_controller.dart';
import '../../models/data_management_model.dart';

class DataManagementPage extends StatelessWidget {
  DataManagementPage({super.key});

  final DataManagementController controller = Get.find<DataManagementController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Quản lý Dữ liệu',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 22),
            onPressed: () => controller.refreshStatistics(),
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isApiUnavailable.value) {
          return _buildApiUnavailable();
        }
        return _buildContent(context);
      }),
    );
  }

  Widget _buildApiUnavailable() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'Không thể kết nối',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Tính năng này chưa sẵn sàng trên server',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => controller.loadStatistics(),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thống kê
          _buildStatisticsCard(),
          const SizedBox(height: 16),

          // Cảnh báo
          _buildWarningBanner(),
          const SizedBox(height: 16),

          // Chọn chế độ xóa
          _buildDeleteModeCard(context),
          const SizedBox(height: 16),

          // Nút thực hiện xóa
          _buildDeleteButton(context),
          const SizedBox(height: 24),

          // Khôi phục
          _buildRestoreSection(),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final stats = controller.statistics.value;
        if (stats == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Không có dữ liệu',
                style: TextStyle(color: Colors.grey.shade500),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thống kê dữ liệu',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            
            // Grid thống kê
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    label: 'Hóa đơn',
                    value: _formatNumber(stats.crabPurchases),
                    color: const Color(0xFF2196F3),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    label: 'Báo cáo',
                    value: _formatNumber(stats.dailySummaries),
                    color: const Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    label: 'Doanh thu',
                    value: _formatRevenue(stats.totalRevenue),
                    color: const Color(0xFFFF9800),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    label: 'Trọng lượng',
                    value: stats.totalWeight != null 
                        ? '${_formatNumber(stats.totalWeight!.toInt())} kg'
                        : '0 kg',
                    color: const Color(0xFF9C27B0),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            Divider(color: Colors.grey.shade200),
            const SizedBox(height: 12),
            
            // Khoảng thời gian
            Row(
              children: [
                Text(
                  'Thời gian: ',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                Expanded(
                  child: Text(
                    stats.dateRange != null && 
                    stats.dateRange!.oldest.isNotEmpty &&
                    stats.dateRange!.newest.isNotEmpty
                        ? '${stats.dateRange!.oldest} → ${stats.dateRange!.newest}'
                        : 'Chưa có dữ liệu',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFFF57C00), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lưu ý quan trọng',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFFE65100),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Dữ liệu sẽ được backup tự động trước khi xóa. Chỉ xóa hóa đơn và báo cáo, không xóa loại cua, thương lái, vựa.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteModeCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chọn chế độ xóa',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Obx(() => Column(
            children: DeleteMode.values.map((mode) {
              return _buildDeleteModeOption(context, mode);
            }).toList(),
          )),
        ],
      ),
    );
  }

  Widget _buildDeleteModeOption(BuildContext context, DeleteMode mode) {
    final isSelected = controller.selectedDeleteMode.value == mode;

    return Column(
      children: [
        InkWell(
          onTap: () {
            controller.selectedDeleteMode.value = mode;
            controller.resetDateSelections();
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? const Color(0xFFE53935) : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFE53935),
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mode.displayName,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        mode.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Date picker cho các mode cần chọn ngày
        if (isSelected && mode == DeleteMode.byDate) ...[
          const SizedBox(height: 8),
          _buildDatePicker(context, 'Chọn ngày'),
        ],
        if (isSelected && mode == DeleteMode.custom) ...[
          const SizedBox(height: 8),
          _buildDateRangePicker(context),
        ],
        
        if (mode != DeleteMode.values.last)
          Divider(color: Colors.grey.shade200, height: 1),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 32),
      child: GestureDetector(
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: controller.selectedDate.value ?? DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
            locale: const Locale('vi', 'VN'),
          );
          if (date != null) {
            controller.selectedDate.value = date;
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade50,
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today, size: 18, color: Colors.grey.shade600),
              const SizedBox(width: 10),
              Obx(() => Text(
                controller.selectedDate.value != null
                    ? _formatDate(controller.selectedDate.value!)
                    : label,
                style: TextStyle(
                  fontSize: 14,
                  color: controller.selectedDate.value != null
                      ? Colors.black87
                      : Colors.grey.shade500,
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateRangePicker(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 32),
      child: Column(
        children: [
          GestureDetector(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: controller.selectedStartDate.value ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                locale: const Locale('vi', 'VN'),
              );
              if (date != null) {
                controller.selectedStartDate.value = date;
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade50,
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: 18, color: Colors.grey.shade600),
                  const SizedBox(width: 10),
                  Obx(() => Text(
                    controller.selectedStartDate.value != null
                        ? 'Từ: ${_formatDate(controller.selectedStartDate.value!)}'
                        : 'Từ ngày',
                    style: TextStyle(
                      fontSize: 14,
                      color: controller.selectedStartDate.value != null
                          ? Colors.black87
                          : Colors.grey.shade500,
                    ),
                  )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: controller.selectedEndDate.value ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                locale: const Locale('vi', 'VN'),
              );
              if (date != null) {
                controller.selectedEndDate.value = date;
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade50,
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: 18, color: Colors.grey.shade600),
                  const SizedBox(width: 10),
                  Obx(() => Text(
                    controller.selectedEndDate.value != null
                        ? 'Đến: ${_formatDate(controller.selectedEndDate.value!)}'
                        : 'Đến ngày',
                    style: TextStyle(
                      fontSize: 14,
                      color: controller.selectedEndDate.value != null
                          ? Colors.black87
                          : Colors.grey.shade500,
                    ),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _showDeleteConfirmDialog(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE53935),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Xóa dữ liệu',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    final mode = controller.selectedDeleteMode.value;

    // Validate date selections
    if (mode == DeleteMode.byDate && controller.selectedDate.value == null) {
      Get.snackbar(
        'Thiếu thông tin',
        'Vui lòng chọn ngày cần xóa',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (mode == DeleteMode.custom &&
        (controller.selectedStartDate.value == null ||
            controller.selectedEndDate.value == null)) {
      Get.snackbar(
        'Thiếu thông tin',
        'Vui lòng chọn ngày bắt đầu và kết thúc',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    final passwordController = TextEditingController();
    final stats = controller.getStatisticsForSelectedMode();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        actionsPadding: const EdgeInsets.all(16),
        title: const Text(
          'Xác nhận xóa dữ liệu',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thông tin xóa
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildConfirmRow('Chế độ', mode.displayName),
                    if (mode == DeleteMode.byDate && controller.selectedDate.value != null)
                      _buildConfirmRow('Ngày', _formatDate(controller.selectedDate.value!)),
                    if (mode == DeleteMode.custom) ...[
                      _buildConfirmRow('Từ', _formatDate(controller.selectedStartDate.value!)),
                      _buildConfirmRow('Đến', _formatDate(controller.selectedEndDate.value!)),
                    ],
                  ],
                ),
              ),
              
              // Hiển thị thông tin phù hợp với chế độ xóa
              const SizedBox(height: 12),
              if (mode == DeleteMode.byDate) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange.shade700, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tất cả hóa đơn và báo cáo của ngày ${_formatDate(controller.selectedDate.value!)} sẽ bị xóa',
                          style: TextStyle(fontSize: 12, color: Colors.orange.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (mode == DeleteMode.custom) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange.shade700, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tất cả hóa đơn và báo cáo từ ${_formatDate(controller.selectedStartDate.value!)} đến ${_formatDate(controller.selectedEndDate.value!)} sẽ bị xóa',
                          style: TextStyle(fontSize: 12, color: Colors.orange.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (stats != null) ...[
                Text(
                  'Dữ liệu sẽ bị xóa:',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '• ${_formatNumber(stats.crabPurchases)} hóa đơn\n• ${_formatNumber(stats.dailySummaries)} báo cáo',
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
              ],
              
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade600, size: 18),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Dữ liệu sẽ được backup trước khi xóa',
                        style: TextStyle(fontSize: 12, color: Color(0xFF2E7D32)),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu xóa',
                  labelStyle: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  hintText: 'Nhập mật khẩu để xác nhận',
                  hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE53935)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Hủy',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          Obx(() => ElevatedButton(
            onPressed: controller.isDeleting.value
                ? null
                : () async {
                    if (passwordController.text.isEmpty) {
                      Get.snackbar(
                        'Thiếu mật khẩu',
                        'Vui lòng nhập mật khẩu',
                        backgroundColor: Colors.orange,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.TOP,
                      );
                      return;
                    }

                    Navigator.pop(context);
                    EasyLoading.show(status: 'Đang xử lý...');

                    try {
                      final result = await controller.deleteData(
                        password: passwordController.text,
                      );

                      EasyLoading.dismiss();

                      if (result != null) {
                        Get.snackbar(
                          'Thành công',
                          'Đã xóa ${result.crabPurchasesDeleted} hóa đơn, ${result.dailySummariesDeleted} báo cáo',
                          backgroundColor: const Color(0xFF4CAF50),
                          colorText: Colors.white,
                          duration: const Duration(seconds: 3),
                          snackPosition: SnackPosition.TOP,
                        );
                      }
                    } catch (e) {
                      EasyLoading.dismiss();
                      Get.snackbar(
                        'Lỗi',
                        e.toString().replaceFirst('Exception: ', ''),
                        backgroundColor: const Color(0xFFE53935),
                        colorText: Colors.white,
                        duration: const Duration(seconds: 3),
                        snackPosition: SnackPosition.TOP,
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: controller.isDeleting.value
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Xóa',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
          )),
        ],
      ),
    );
  }

  Widget _buildConfirmRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestoreSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Khôi phục dữ liệu',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Khôi phục dữ liệu đã xóa từ các bản backup',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Get.toNamed('/backup-history'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF4CAF50),
                side: const BorderSide(color: Color(0xFF4CAF50)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Xem danh sách backup',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  String _formatRevenue(double revenue) {
    if (revenue >= 1000000000) {
      return '${(revenue / 1000000000).toStringAsFixed(1)} tỷ';
    } else if (revenue >= 1000000) {
      return '${(revenue / 1000000).toStringAsFixed(1)} triệu';
    } else {
      return format_vnd.formatCurrency(revenue);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
