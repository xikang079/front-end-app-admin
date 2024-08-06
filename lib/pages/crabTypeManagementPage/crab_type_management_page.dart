import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sticky_headers/sticky_headers.dart';

import '../../apps/format_vnd.dart';
import '../../controllers/crab_type_controller.dart';

class CrabTypeManagementPage extends StatelessWidget {
  const CrabTypeManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CrabTypeController crabTypeController =
        Get.find<CrabTypeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quản lý loại cua',
          style: TextStyle(fontSize: 22),
        ),
      ),
      body: Obx(() {
        if (crabTypeController.isLoading.value) {
          return _buildShimmerEffect();
        }

        if (crabTypeController.crabTypes.isEmpty) {
          return const Center(child: Text('Không có loại cua nào'));
        }

        final totalWeight = crabTypeController.crabTypes.fold(
            0.0,
            (sum, crabType) =>
                sum + crabTypeController.getCurrentWeight(crabType.id));
        final estimatedBoxes =
            (totalWeight / 24).toInt() + ((totalWeight % 24) >= 12 ? 1 : 0);

        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tổng số kg hiện tại: ${formatWeightWithUnit(totalWeight)}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Dự đoán số thùng cua: $estimatedBoxes',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                StickyHeader(
                  header: Table(
                    border: TableBorder.all(color: Colors.black54, width: 1),
                    columnWidths: const {
                      0: FlexColumnWidth(0.7),
                      1: FlexColumnWidth(1.5),
                      2: FlexColumnWidth(2),
                      3: FlexColumnWidth(1.5),
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
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Loại cua',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Giá',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Đang có',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  content: Table(
                    border: TableBorder.all(color: Colors.black54, width: 1),
                    columnWidths: const {
                      0: FlexColumnWidth(0.7),
                      1: FlexColumnWidth(1.5),
                      2: FlexColumnWidth(2),
                      3: FlexColumnWidth(1.5),
                    },
                    children: List.generate(
                      crabTypeController.crabTypes.length,
                      (index) {
                        final crabType = crabTypeController.crabTypes[index];
                        final currentWeight =
                            crabTypeController.getCurrentWeight(crabType.id);
                        return TableRow(
                          children: [
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(
                                  (index + 1).toString(),
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(
                                  crabType.name,
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(
                                  formatCurrency(crabType.pricePerKg),
                                  style: const TextStyle(fontSize: 17),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(
                                  formatWeightWithUnit(currentWeight),
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildShimmerEffect() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          border: TableBorder.all(color: Colors.black54, width: 1),
          columnWidths: const {
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(2),
            3: FlexColumnWidth(2),
          },
          children: List.generate(
            10,
            (index) => TableRow(
              children: [
                TableCell(child: _buildShimmerCell(width: 50)),
                TableCell(child: _buildShimmerCell(width: 100)),
                TableCell(child: _buildShimmerCell(width: 100)),
                TableCell(child: _buildShimmerCell(width: 100)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerCell({required double width}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: 16.0,
        color: Colors.white,
      ),
    );
  }
}
