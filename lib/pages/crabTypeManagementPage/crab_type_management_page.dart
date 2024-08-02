import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:shimmer/shimmer.dart';

import '../../apps/apps_colors.dart';
import '../../apps/format_vnd.dart';
import '../../controllers/crab_type_controller.dart';

class CrabTypeManagementPage extends StatelessWidget {
  const CrabTypeManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CrabTypeController crabTypeController = Get.put(CrabTypeController());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quản lí loại cua',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () {
              crabTypeController.fetchCrabTypes();
            },
          ),
        ],
        backgroundColor: AppColors.primaryColor,
      ),
      body: Obx(() {
        if (crabTypeController.isLoading.value) {
          return _buildShimmerEffect();
        }
        if (crabTypeController.crabTypes.isEmpty) {
          return const Center(child: Text('Không có loại cua nào'));
        }
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: StickyHeader(
              header: Table(
                border: TableBorder.all(color: Colors.black54, width: 1),
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(2),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey[300]),
                    children: const [
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Tên loại cua',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Giá cua/KG',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              content: Table(
                border: TableBorder.all(color: Colors.black54, width: 1),
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(2),
                },
                children: crabTypeController.crabTypes.map((crabType) {
                  return TableRow(
                    children: [
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(crabType.name,
                              style: const TextStyle(fontSize: 24)),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                              formatNumberWithoutSymbol(crabType.pricePerKg),
                              style: const TextStyle(fontSize: 20)),
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
