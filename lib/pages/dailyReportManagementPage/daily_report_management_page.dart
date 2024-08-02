import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shimmer/shimmer.dart';

import '../../../controllers/daily_summary_controller.dart';
import '../../apps/apps_colors.dart';
import '../../apps/format_vnd.dart';
import 'daily_report_management_detail_page.dart';

class DailyReportManagementPage extends StatefulWidget {
  final String depotId;

  const DailyReportManagementPage({required this.depotId, super.key});

  @override
  _DailyReportManagementPageState createState() =>
      _DailyReportManagementPageState();
}

class _DailyReportManagementPageState extends State<DailyReportManagementPage> {
  final DailySummaryController _controller = Get.put(DailySummaryController());
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _controller.fetchDailySummariesByDepotAndMonth(
      widget.depotId,
      _controller.selectedMonth.value,
      _controller.selectedYear.value,
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      locale: const Locale('vi', 'VN'),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _controller.fetchDailySummariesByDepotAndDate(
          widget.depotId, selectedDate);
    }
  }

  String formatDate(DateTime date) {
    return DateFormat('dd-MM-yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        title: const Text(
          'Quản lí báo cáo cuối ngày',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: AppColors.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () {
              _controller.fetchDailySummariesByDepotAndMonth(
                widget.depotId,
                _controller.selectedMonth.value,
                _controller.selectedYear.value,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Obx(() {
                    return DropdownButton<int>(
                      value: _controller.selectedMonth.value,
                      items: List.generate(12, (index) {
                        return DropdownMenuItem(
                          value: index + 1,
                          child: Text('Tháng ${index + 1}'),
                        );
                      }),
                      onChanged: (value) {
                        if (value != null &&
                            value != _controller.selectedMonth.value) {
                          _controller.selectedMonth.value = value;
                          _controller.fetchDailySummariesByDepotAndMonth(
                            widget.depotId,
                            value,
                            _controller.selectedYear.value,
                          );
                        }
                      },
                    );
                  }),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Obx(() {
                    return DropdownButton<int>(
                      value: _controller.selectedYear.value,
                      items: List.generate(10, (index) {
                        int year = DateTime.now().year - index;
                        return DropdownMenuItem(
                          value: year,
                          child: Text('Năm $year'),
                        );
                      }),
                      onChanged: (value) {
                        if (value != null &&
                            value != _controller.selectedYear.value) {
                          _controller.selectedYear.value = value;
                          _controller.fetchDailySummariesByDepotAndMonth(
                            widget.depotId,
                            _controller.selectedMonth.value,
                            value,
                          );
                        }
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (_controller.isLoading.value) {
                return _buildShimmerEffect();
              }
              if (_controller.errorMessage.isNotEmpty) {
                return Center(child: Text(_controller.errorMessage.value));
              }
              if (_controller.dailySummaries.isEmpty) {
                return const Center(
                    child: Text('Không có báo cáo tổng hợp nào.'));
              }

              return MasonryGridView.count(
                crossAxisCount: 1,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                padding: const EdgeInsets.all(8.0),
                itemCount: _controller.dailySummaries.length,
                itemBuilder: (context, index) {
                  final summary = _controller.dailySummaries[index];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: const BorderSide(color: Colors.grey, width: 1),
                    ),
                    child: ListTile(
                      title: Text(
                        'Ngày: ${formatDate(summary.createdAt)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Tổng tiền mua: ${formatCurrency(summary.totalAmount)}',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(
                              color: AppColors.primaryColor, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 6),
                        ),
                        child: const Text('Truy cập',
                            style: TextStyle(
                                color: AppColors.primaryColor, fontSize: 16)),
                        onPressed: () {
                          _controller.dailySummary.value = summary;
                          Get.to(() =>
                              DailySummaryDetailView(dailySummary: summary));
                        },
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
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
