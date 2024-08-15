import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; // Import để định dạng ngày

import '../../apps/format_vnd.dart';
import '../../controllers/overview_controller.dart';

class DepotOverviewPage extends StatelessWidget {
  final DepotOverviewController controller = Get.put(DepotOverviewController());

  DepotOverviewPage({super.key});

  // Danh sách màu cố định cho các vựa, màu sẫm dễ phân biệt
  final List<Color> depotColors = [
    Colors.deepPurple,
    Colors.deepOrange,
    Colors.indigo,
    Colors.teal,
    Colors.brown,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tổng Quan Tất Cả Vựa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              controller.fetchDepotOverview();
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          EasyLoading.show(status: "Đang tính toán...");
          return _buildShimmerEffect();
        } else {
          EasyLoading.dismiss();
          return _buildContent();
        }
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _selectDate(context),
        child: const Icon(Icons.date_range),
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 200,
              height: 24,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            Container(
              width: 150,
              height: 24,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            Container(
              width: 180,
              height: 24,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ngày Chọn: ${DateFormat('dd/MM/yyyy').format(controller.selectedDate.value)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryCard(
            title: 'Tổng Số Ký Tất Cả Vựa',
            value: '${formatWeight(controller.totalWeight.value)}Kg',
            color: Colors.blueAccent,
          ),
          const SizedBox(height: 16),
          _buildSummaryCard(
            title: 'Tổng Số Tiền Đã Mua Tất Cả Vựa',
            value: '${formatCurrency(controller.totalCost.value)} VNĐ',
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          _buildSummaryCard(
            title: 'Số Thùng Cua Dự Đoán Tất Cả Vựa',
            value: '${controller.estimatedBoxes.value.toInt().round()} thùng',
            color: Colors.deepOrange,
          ),
          const SizedBox(height: 32),
          _buildPieCharts(), // Hiển thị các biểu đồ hình tròn
          const SizedBox(height: 32),
          Center(
            child: ElevatedButton(
              onPressed: () {
                controller.fetchDepotOverview();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 24.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: const BorderSide(color: Colors.deepPurple),
                ),
                backgroundColor: Colors.deepPurpleAccent,
              ),
              child: const Text(
                'Tải Lại Dữ Liệu',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      {required String title, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.7), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieCharts() {
    return Column(
      children: [
        _buildPieChartSection(
          title: 'Phân Bố Số Kí Theo Vựa',
          data: _getWeightData(),
        ),
        const SizedBox(height: 16),
        _buildPieChartSection(
          title: 'Phân Bố Tiền Mua Theo Vựa',
          data: _getCostData(),
        ),
        const SizedBox(height: 16),
        _buildPieChartSection(
          title: 'Phân Bố Số Thùng Cua Dự Đoán',
          data: _getBoxData(),
        ),
      ],
    );
  }

  Widget _buildPieChartSection({
    required String title,
    required List<PieChartSectionData> data,
  }) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 16, bottom: 30),
      decoration: BoxDecoration(
        color: Colors.grey[900], // Nền màu sẫm
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20, // Tăng kích thước chữ
              fontWeight: FontWeight.bold,
              color: Colors.white, // Đổi màu chữ
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 300, // Tăng kích thước vòng tròn
            child: PieChart(
              PieChartData(
                sections: data,
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _getWeightData() {
    if (controller.totalWeight.value == 0) {
      return []; // Trả về một danh sách rỗng nếu không có dữ liệu
    }

    return controller.depotNames.asMap().entries.map((entry) {
      int index = entry.key;
      String depotName = entry.value;
      double value = controller.depotWeights[depotName]!;
      double percentage = (value / controller.totalWeight.value) * 100;
      return PieChartSectionData(
        color: depotColors[index % depotColors.length], // Sử dụng màu cố định
        value: percentage,
        title:
            '$depotName\n${percentage.toStringAsFixed(1)}%\n${formatWeightWithUnit(value)}',
        radius: 120, // Tăng kích thước radius
        titleStyle: const TextStyle(
          fontSize: 13, // Tăng kích thước chữ bên trong
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<PieChartSectionData> _getCostData() {
    if (controller.totalCost.value == 0) {
      return []; // Trả về một danh sách rỗng nếu không có dữ liệu
    }

    return controller.depotNames.asMap().entries.map((entry) {
      int index = entry.key;
      String depotName = entry.value;
      double value = controller.depotCosts[depotName]!;
      double percentage = (value / controller.totalCost.value) * 100;
      return PieChartSectionData(
        color: depotColors[index % depotColors.length], // Sử dụng màu cố định
        value: percentage,
        title:
            '$depotName\n${percentage.toStringAsFixed(1)}%\n${formatCurrency(value)} VND',
        radius: 120, // Tăng kích thước radius
        titleStyle: const TextStyle(
          fontSize: 13, // Tăng kích thước chữ bên trong
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<PieChartSectionData> _getBoxData() {
    if (controller.estimatedBoxes.value == 0) {
      return []; // Trả về một danh sách rỗng nếu không có dữ liệu
    }

    return controller.depotNames.asMap().entries.map((entry) {
      int index = entry.key;
      String depotName = entry.value;
      double value =
          controller.depotWeights[depotName]! / 24; // Tính số thùng cua
      double percentage = (value / controller.estimatedBoxes.value) * 100;
      return PieChartSectionData(
        color: depotColors[index % depotColors.length], // Sử dụng màu cố định
        value: percentage,
        title:
            '$depotName\n${percentage.toStringAsFixed(1)}%\n${value.toInt()} thùng',
        radius: 120, // Tăng kích thước radius
        titleStyle: const TextStyle(
          fontSize: 13, // Tăng kích thước chữ bên trong
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  void _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != controller.selectedDate.value) {
      controller.selectDate(pickedDate);
    }
  }
}
