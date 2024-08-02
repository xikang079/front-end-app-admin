import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../apps/apps_colors.dart';
import '../../apps/format_vnd.dart';
import '../../models/daily_summary_model.dart';

class DailySummaryDetailView extends StatelessWidget {
  final DailySummary dailySummary;

  const DailySummaryDetailView({super.key, required this.dailySummary});

  @override
  Widget build(BuildContext context) {
    // final CrabTypeController crabTypeController =
    //     Get.find<CrabTypeController>();

    double totalWeight = dailySummary.details
        .fold(0.0, (sum, detail) => sum + detail.totalWeight);
    int estimatedCrates = (totalWeight / 24).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Báo cáo tổng hợp trong ngày',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ngày: ${dailySummary.createdAt.toLocal().toString().split(' ')[0]}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Tổng số tiền: ${formatCurrency(dailySummary.totalAmount)}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Tổng số ký: ${formatWeight(totalWeight)} kg',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Dự đoán số thùng: $estimatedCrates thùng',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16.0),
              Table(
                border: TableBorder.all(color: Colors.black54, width: 1),
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(2),
                  2: FlexColumnWidth(1.5),
                  3: FlexColumnWidth(2),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey[300]),
                    children: const [
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('STT',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
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
                          child: Text('Số kí (Kg)',
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
                  ...dailySummary.details.asMap().entries.map((entry) {
                    int index = entry.key;
                    var detail = entry.value;
                    // final crabTypeName =
                    //     crabTypeController.getCrabTypeNameById(detail.crabType);
                    return TableRow(
                      children: [
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text((index + 1).toString(),
                                style: const TextStyle(fontSize: 15)),
                          ),
                        ),
                        const TableCell(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            // child: Text(crabTypeName,
                            //     style: const TextStyle(fontSize: 16)),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(formatWeight(detail.totalWeight),
                                style: const TextStyle(fontSize: 16)),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(formatCurrency(detail.totalCost),
                                style: const TextStyle(fontSize: 15)),
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
      ),
    );
  }

  String formatWeight(double weight) {
    if (weight % 1 == 0) {
      return weight.toStringAsFixed(0);
    } else {
      return weight.toStringAsFixed(2);
    }
  }
}