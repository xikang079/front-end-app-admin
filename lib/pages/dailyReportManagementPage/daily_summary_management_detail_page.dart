import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../apps/apps_colors.dart';
import '../../apps/format_vnd.dart';
import '../../controllers/crab_type_controller.dart';
import '../../models/crab_type_model.dart';
import '../../models/daily_summary_model.dart';

class DailySummaryDetailView extends StatelessWidget {
  final DailySummary dailySummary;

  DailySummaryDetailView({super.key, required this.dailySummary}) {
    final depotId = Get.arguments['depotId'] as String;
    Get.put(CrabTypeController(depotId));
  }

  @override
  Widget build(BuildContext context) {
    final CrabTypeController crabTypeController =
        Get.find<CrabTypeController>();
    final depotName = Get.arguments['depotName'] as String;

    double totalWeight = dailySummary.details
        .fold(0.0, (sum, detail) => sum + detail.totalWeight);
    int estimatedCrates = (totalWeight / 24).round();

    // Sort details according to the total weight
    List<SummaryDetail> sortedDetails = List.from(dailySummary.details);
    sortedDetails.sort((a, b) {
      CrabType? crabTypeA = crabTypeController.crabTypes
          .firstWhereOrNull((crabType) => crabType.id == a.crabType);
      CrabType? crabTypeB = crabTypeController.crabTypes
          .firstWhereOrNull((crabType) => crabType.id == b.crabType);

      if (crabTypeA == null || crabTypeB == null) {
        // Nếu không tìm thấy CrabType, đẩy các mục này xuống cuối
        return crabTypeA == null ? 1 : -1;
      }

      return crabTypeA.createdAt.compareTo(crabTypeB.createdAt);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Báo cáo mua $depotName',
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Obx(() {
        if (crabTypeController.isLoading.value) {
          return Center(
            child: Container(),
          );
        }

        // Kiểm tra xem crabTypes đã được tải đầy đủ hay chưa
        if (crabTypeController.crabTypes.isEmpty) {
          return const Center(
            child: Text('Đang tải dữ liệu...'),
          );
        }

        // Sắp xếp sau khi dữ liệu đã sẵn sàng
        List<SummaryDetail> sortedDetails = List.from(dailySummary.details);
        sortedDetails.sort((a, b) {
          CrabType? crabTypeA = crabTypeController.crabTypes
              .firstWhereOrNull((crabType) => crabType.id == a.crabType);
          CrabType? crabTypeB = crabTypeController.crabTypes
              .firstWhereOrNull((crabType) => crabType.id == b.crabType);

          if (crabTypeA == null || crabTypeB == null) {
            return crabTypeA == null ? 1 : -1;
          }

          return crabTypeA.createdAt.compareTo(crabTypeB.createdAt);
        });

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ngày: ${DateFormat('dd/MM/yyyy').format(dailySummary.createdAt)}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Tổng số tiền mua: ${formatCurrency(dailySummary.totalAmount)}VND',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Tổng số kí: ${formatWeight(totalWeight)} kg',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Dự đoán số thùng: $estimatedCrates thùng',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16.0),
                Table(
                  border: TableBorder.all(color: Colors.black54, width: 1),
                  columnWidths: const {
                    0: FlexColumnWidth(0.7),
                    1: FlexColumnWidth(1.4),
                    2: FlexColumnWidth(1.4),
                    3: FlexColumnWidth(2.3),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.grey[300]),
                      children: const [
                        TableCell(
                          child: Padding(
                            padding: EdgeInsets.only(
                                top: 8.0, bottom: 8.0, left: 4.0),
                            child: Text('STT',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Loại cua',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Số kí',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Tổng tiền',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                    ...sortedDetails.asMap().entries.map((entry) {
                      int index = entry.key;
                      var detail = entry.value;
                      final crabTypeName = crabTypeController
                          .getCrabTypeNameById(detail.crabType);
                      return TableRow(
                        children: [
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text((index + 1).toString(),
                                  style: const TextStyle(fontSize: 16)),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  crabTypeName ?? 'Không tìm thấy loại cua',
                                  style: const TextStyle(fontSize: 18)),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(formatWeight(detail.totalWeight),
                                  style: const TextStyle(fontSize: 18)),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(formatCurrency(detail.totalCost),
                                  style: const TextStyle(fontSize: 17)),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
