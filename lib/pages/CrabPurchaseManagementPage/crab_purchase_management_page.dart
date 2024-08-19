import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../apps/apps_colors.dart';
import '../../apps/format_vnd.dart';
import '../../controllers/crab_purchase_controller.dart';

class CrabPurchaseManagementPage extends StatefulWidget {
  const CrabPurchaseManagementPage({super.key});

  @override
  _CrabPurchaseManagementPageState createState() =>
      _CrabPurchaseManagementPageState();
}

class _CrabPurchaseManagementPageState
    extends State<CrabPurchaseManagementPage> {
  final CrabPurchaseController _crabPurchaseController =
      Get.put(CrabPurchaseController(Get.arguments['depotId'] as String));
  final String depotName = Get.arguments['depotName'] ?? 'Tên vựa cua';
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _crabPurchaseController.fetchCrabPurchasesByDate(selectedDate);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      locale: const Locale('vi', 'VN'), // Thêm locale để thay đổi ngôn ngữ
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _crabPurchaseController.fetchCrabPurchasesByDate(selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hoá đơn $depotName',
          style: const TextStyle(fontSize: 22, color: Colors.white),
        ),
        backgroundColor: AppColors.primaryColor,
        toolbarHeight: 40,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () {
              _crabPurchaseController.fetchCrabPurchasesByDate(selectedDate);
            },
          ),
        ],
      ),
      body: Obx(
        () {
          if (_crabPurchaseController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_crabPurchaseController.crabPurchases.isEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Hóa đơn ngày ${DateFormat('dd/MM/yyyy').format(selectedDate)}',
                  style: const TextStyle(color: Colors.black, fontSize: 20),
                ),
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    'Không có hóa đơn nào cho ngày này.',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            );
          }

          // Tính toán số liệu tổng quát
          int totalTraders = _crabPurchaseController.crabPurchases.length;
          double totalAmount = _crabPurchaseController.crabPurchases
              .fold(0.0, (sum, item) => sum + item.totalCost);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                    color: Colors.blue.shade200,
                    borderRadius: BorderRadius.circular(16)),
                margin: const EdgeInsets.only(top: 10, left: 10, bottom: 5),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hóa đơn ngày ${DateFormat('dd/MM/yyyy').format(selectedDate)}',
                        style:
                            const TextStyle(color: Colors.black, fontSize: 20),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Số lái đã bán: $totalTraders',
                            style: const TextStyle(
                                color: Colors.black, fontSize: 18),
                          ),
                          Text(
                            'Tổng số tiền hiện tại: ${formatCurrency(totalAmount)}',
                            style: const TextStyle(
                                color: Colors.black, fontSize: 18),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: AnimationLimiter(
                  child: ListView.builder(
                    itemCount: _crabPurchaseController.crabPurchases.length,
                    itemBuilder: (context, index) {
                      final crabPurchase =
                          _crabPurchaseController.crabPurchases[index];
                      double totalWeight = crabPurchase.crabs.fold(
                          0.0, (sum, crabDetail) => sum + crabDetail.weight);
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: Column(
                              children: [
                                Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    side: const BorderSide(
                                        color: Colors.grey, width: 1),
                                  ),
                                  color: index % 2 == 0
                                      ? Colors.white
                                      : Colors.grey[100],
                                  margin: const EdgeInsets.all(8.0),
                                  child: ExpansionTile(
                                    title: RichText(
                                      text: TextSpan(
                                        children: [
                                          const TextSpan(
                                            text: 'Thương lái: ',
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.black,
                                            ),
                                          ),
                                          TextSpan(
                                            text: crabPurchase.trader.name,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    subtitle: RichText(
                                      text: TextSpan(
                                        children: [
                                          const TextSpan(
                                            text: 'Tổng tiền: ',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black),
                                          ),
                                          TextSpan(
                                            text: formatCurrency(
                                                crabPurchase.totalCost),
                                            style: const TextStyle(
                                              fontSize: 15,
                                              color: Colors
                                                  .red, // Màu đỏ cho số tiền
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const TextSpan(
                                            text: '  Tổng kí: ',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black),
                                          ),
                                          TextSpan(
                                            text:
                                                '${formatWeight(totalWeight)} Kg',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              color: Colors
                                                  .red, // Màu đỏ cho số ký
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    children: [
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            DataTable(
                                              headingRowColor:
                                                  WidgetStateColor.resolveWith(
                                                      (states) =>
                                                          Colors.grey[300]!),
                                              columns: const [
                                                DataColumn(
                                                    label: Text(
                                                  'Tên cua',
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                )),
                                                DataColumn(
                                                    label: Text(
                                                  'Số kí (kg)',
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                )),
                                                DataColumn(
                                                    label: Text(
                                                  'Giá VNĐ/kg',
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                )),
                                              ],
                                              rows: crabPurchase.crabs
                                                  .asMap()
                                                  .entries
                                                  .map((entry) {
                                                var crabDetail = entry.value;
                                                return DataRow(cells: [
                                                  DataCell(Text(
                                                    crabDetail.crabType.name,
                                                    style: const TextStyle(
                                                        fontSize: 14),
                                                  )),
                                                  DataCell(Text(
                                                    formatWeight(
                                                        crabDetail.weight),
                                                    style: const TextStyle(
                                                        fontSize: 14),
                                                  )),
                                                  DataCell(Text(
                                                    formatNumberWithoutSymbol(
                                                        crabDetail.pricePerKg),
                                                    style: const TextStyle(
                                                        fontSize: 14),
                                                  )),
                                                ]);
                                              }).toList(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: () => _selectDate(context),
              icon: const Icon(Icons.calendar_today, color: Colors.blue),
              label: const Text(
                'Chọn ngày',
                style: TextStyle(color: Colors.blue, fontSize: 16),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 16.0,
                ),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.grey, width: 3),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
