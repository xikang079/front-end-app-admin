import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../../apps/format_vnd.dart' as format_vnd;
import '../../controllers/data_management_controller.dart';
import '../../models/data_management_model.dart';

class BackupHistoryPage extends StatefulWidget {
  const BackupHistoryPage({super.key});

  @override
  State<BackupHistoryPage> createState() => _BackupHistoryPageState();
}

class _BackupHistoryPageState extends State<BackupHistoryPage> {
  final DataManagementController controller = Get.find<DataManagementController>();

  @override
  void initState() {
    super.initState();
    controller.loadBackupList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Lịch sử Backup',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 22),
            onPressed: () => controller.loadBackupList(),
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingBackups.value) {
          return const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }

        if (controller.backupList.isEmpty) {
          return _buildEmptyState();
        }

        return _buildBackupList();
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'Chưa có backup nào',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Backup sẽ được tạo tự động khi xóa dữ liệu',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => controller.loadBackupList(),
              child: const Text('Làm mới'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupList() {
    // Lọc bỏ các sub-chunk, chỉ hiển thị backup chính
    final mainBackups = controller.backupList
        .where((b) => !b.isSubChunk)
        .toList();

    return RefreshIndicator(
      onRefresh: () => controller.loadBackupList(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mainBackups.length,
        itemBuilder: (context, index) {
          final backup = mainBackups[index];
          return _buildBackupCard(backup);
        },
      ),
    );
  }

  // Lấy thông tin loại backup từ tên file
  Map<String, dynamic> _getBackupTypeInfo(BackupInfo backup) {
    final fileName = backup.fileName.toLowerCase();
    
    if (fileName.contains('by_date') || fileName.contains('by-date')) {
      return {
        'label': 'Xóa theo ngày',
        'color': const Color(0xFF9C27B0),
        'icon': Icons.calendar_today,
      };
    } else if (fileName.contains('except_today') || fileName.contains('except-today')) {
      return {
        'label': 'Xóa trừ hôm nay',
        'color': const Color(0xFFFF9800),
        'icon': Icons.today,
      };
    } else if (fileName.contains('today')) {
      return {
        'label': 'Xóa hôm nay',
        'color': const Color(0xFF2196F3),
        'icon': Icons.today,
      };
    } else if (fileName.contains('custom')) {
      return {
        'label': 'Xóa tùy chọn',
        'color': const Color(0xFF00BCD4),
        'icon': Icons.date_range,
      };
    } else {
      return {
        'label': 'Xóa tất cả',
        'color': const Color(0xFFE53935),
        'icon': Icons.delete_sweep,
      };
    }
  }

  Widget _buildBackupCard(BackupInfo backup) {
    final isAllDepots = backup.depotId == null || backup.depotId == 'all';
    final typeInfo = _getBackupTypeInfo(backup);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          // Header với loại backup
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: (typeInfo['color'] as Color).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  typeInfo['icon'] as IconData,
                  size: 18,
                  color: typeInfo['color'] as Color,
                ),
                const SizedBox(width: 8),
                Text(
                  typeInfo['label'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: typeInfo['color'] as Color,
                  ),
                ),
                const Spacer(),
                    Row(
                      children: [
                        // Hiển thị số chunks nếu là backup chunked
                        if (backup.isChunked && backup.totalChunks != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${backup.totalChunks} phần',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        if (backup.size != null)
                          Text(
                            backup.size!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tên file
                Text(
                  backup.fileName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                
                // Thời gian
                Text(
                  backup.createdAt ?? '',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Thông tin chi tiết
                Row(
                  children: [
                    // Phạm vi
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isAllDepots 
                            ? const Color(0xFFFFEBEE) 
                            : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isAllDepots ? 'Tất cả vựa' : 'Vựa cụ thể',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isAllDepots 
                              ? const Color(0xFFE53935) 
                              : Colors.blue.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    
                    // Số lượng
                    if (backup.totalPurchases != null)
                      Text(
                        '${_formatNumber(backup.totalPurchases!)} hóa đơn',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      ),
                    if (backup.totalSummaries != null) ...[
                      Text(
                        '  •  ',
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                      Text(
                        '${_formatNumber(backup.totalSummaries!)} báo cáo',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      ),
                    ],
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showDetailDialog(backup),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                          side: BorderSide(color: Colors.grey.shade300),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Xem chi tiết', style: TextStyle(fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showRestoreDialog(backup),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Khôi phục',
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailDialog(BackupInfo backup) async {
    EasyLoading.show(status: 'Đang tải...');

    final preview = await controller.loadBackupPreview(backup.backupId);

    EasyLoading.dismiss();

    if (preview == null) {
      Get.snackbar(
        'Lỗi',
        'Không thể tải chi tiết backup',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (!mounted) return;

    final typeInfo = _getBackupTypeInfo(backup);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        actionsPadding: const EdgeInsets.all(16),
        title: Row(
          children: [
            Icon(
              typeInfo['icon'] as IconData,
              size: 20,
              color: typeInfo['color'] as Color,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Chi tiết Backup',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Loại backup
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: (typeInfo['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  typeInfo['label'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: typeInfo['color'] as Color,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Thông tin cơ bản
              _buildDetailSection('Thông tin', [
                _buildDetailRow('Tên file', preview.backup.fileName),
                _buildDetailRow('Thời gian', preview.backup.createdAt ?? ''),
                _buildDetailRow('Kích thước', preview.chunkInfo?.totalSize ?? preview.backup.size ?? ''),
                _buildDetailRow(
                  'Phạm vi',
                  preview.metadata.depotId == 'all' ? 'Tất cả vựa' : 'Vựa cụ thể',
                ),
                if (preview.chunkInfo != null && preview.chunkInfo!.isChunked)
                  _buildDetailRow('Số phần', '${preview.chunkInfo!.totalChunks} phần'),
              ]),
              
              const SizedBox(height: 16),
              
              // Nội dung
              _buildDetailSection('Nội dung backup', [
                _buildDetailRow('Hóa đơn', _formatNumber(preview.metadata.totalPurchases)),
                _buildDetailRow('Báo cáo', _formatNumber(preview.metadata.totalSummaries)),
                _buildDetailRow('Doanh thu', format_vnd.formatCurrency(preview.metadata.totalRevenue)),
              ]),
              
              if (preview.dateBreakdown != null && preview.dateBreakdown!.isNotEmpty) ...[
                const SizedBox(height: 16),
                
                const Text(
                  'Chi tiết theo ngày',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 8),
                
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  constraints: const BoxConstraints(maxHeight: 150),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: preview.dateBreakdown!.length > 5 
                        ? 5 
                        : preview.dateBreakdown!.length,
                    itemBuilder: (context, index) {
                      final item = preview.dateBreakdown![index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 85,
                              child: Text(
                                item.date,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '${item.purchases} hóa đơn, ${item.summaries} báo cáo',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                if (preview.dateBreakdown!.length > 5)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Và ${preview.dateBreakdown!.length - 5} ngày khác...',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showRestoreDialog(backup);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              elevation: 0,
            ),
            child: const Text('Khôi phục', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  void _showRestoreDialog(BackupInfo backup) {
    final passwordController = TextEditingController();
    final typeInfo = _getBackupTypeInfo(backup);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        actionsPadding: const EdgeInsets.all(16),
        title: const Text(
          'Khôi phục dữ liệu',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thông tin backup
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Loại backup
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (typeInfo['color'] as Color).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        typeInfo['label'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          color: typeInfo['color'] as Color,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    // Tên file
                    Text(
                      backup.fileName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    
                    // Số liệu
                    Text(
                      '${backup.totalPurchases ?? 0} hóa đơn  •  ${backup.totalSummaries ?? 0} báo cáo',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      backup.createdAt ?? '',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Thông báo
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Toàn bộ dữ liệu trong backup sẽ được khôi phục',
                            style: TextStyle(fontSize: 12, color: Colors.blue.shade800),
                          ),
                        ),
                      ],
                    ),
                    if (backup.isChunked && backup.totalChunks != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Backup gồm ${backup.totalChunks} phần, hệ thống sẽ tự động gộp.',
                        style: TextStyle(fontSize: 11, color: Colors.blue.shade600),
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu',
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
                    borderSide: const BorderSide(color: Color(0xFF4CAF50)),
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
            child: Text('Hủy', style: TextStyle(color: Colors.grey.shade600)),
          ),
          Obx(() => ElevatedButton(
            onPressed: controller.isRestoring.value
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
                    EasyLoading.show(status: 'Đang khôi phục...');

                    try {
                      // Luôn khôi phục toàn bộ
                      final result = await controller.restoreFull(
                        password: passwordController.text,
                        backupId: backup.backupId,
                      );

                      EasyLoading.dismiss();

                      if (result != null) {
                        Get.snackbar(
                          'Thành công',
                          'Đã khôi phục ${result.crabPurchasesRestored} hóa đơn, ${result.dailySummariesRestored} báo cáo',
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
              backgroundColor: const Color(0xFF4CAF50),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: controller.isRestoring.value
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Khôi phục', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          )),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
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
}
