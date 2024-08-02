import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:shimmer/shimmer.dart';

import '../../../controllers/trader_controller.dart';
import '../../../controllers/crab_purchase_controller.dart';
import '../../apps/apps_colors.dart';
import '../../models/trader_model.dart';

class TraderManagementPage extends StatelessWidget {
  const TraderManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TraderController traderController = Get.put(TraderController());
    final CrabPurchaseController crabPurchaseController =
        Get.put(CrabPurchaseController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lí thương lái',
            style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () {
              traderController.fetchTraders();
              crabPurchaseController.fetchCrabPurchasesByDateRange(
                  'depotId', DateTime.now(), DateTime.now());
            },
          ),
        ],
      ),
      body: Obx(() {
        if (traderController.isLoading.value) {
          return _buildShimmerEffect();
        }
        if (traderController.traders.isEmpty) {
          return const Center(child: Text('Không có thương lái nào'));
        }
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: StickyHeader(
              header: Table(
                border: TableBorder.all(color: Colors.black54, width: 1),
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(2.5),
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
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Tên lái',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('SĐT',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              content: Table(
                border: TableBorder.all(color: Colors.black54, width: 1),
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(2.5),
                  2: FlexColumnWidth(1.5),
                  3: FlexColumnWidth(2),
                },
                children: traderController.traders.asMap().entries.map((entry) {
                  int index = entry.key;
                  Trader trader = entry.value;
                  return TableRow(
                    children: [
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text((index + 1).toString(),
                              style: const TextStyle(fontSize: 20)),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(trader.name,
                              style: const TextStyle(fontSize: 18)),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(trader.phone,
                              style: const TextStyle(fontSize: 18)),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        );
      }),
      backgroundColor: AppColors.backgroundColor,
    );
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: const BorderSide(color: Colors.grey, width: 1),
              ),
              child: const ListTile(
                title: Text(''),
                subtitle: Text(''),
              ),
            ),
          );
        },
      ),
    );
  }
}
