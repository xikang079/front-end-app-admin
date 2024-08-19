import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/user_model.dart';

class UserManagementOptionsPage extends StatelessWidget {
  final User user = Get.arguments as User;

  UserManagementOptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý cho ${user.fullname}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildManagementCard(
              context,
              title: 'Quản lý loại cua đang mua của vựa',
              icon: FontAwesomeIcons.cubes,
              colors: [Colors.blue, Colors.blue.shade700],
              routeName: '/crab-type-management',
              depotId: user.id,
            ),
            _buildManagementCard(
              context,
              title: 'Quản lý hóa đơn theo ngày',
              icon: FontAwesomeIcons.receipt,
              colors: [Colors.blue, Colors.blue.shade700],
              routeName: '/crab-purchase-management',
              depotId: user.id,
            ),
            _buildManagementCard(
              context,
              title: 'Quản lý báo cáo theo ngày',
              icon: FontAwesomeIcons.fileCircleCheck,
              colors: [Colors.blue, Colors.blue.shade700],
              routeName: '/daily-summary-management',
              depotId: user.id,
            ),
            _buildManagementCard(
              context,
              title: 'Quản lý lái cua của vựa',
              icon: FontAwesomeIcons.houseUser,
              colors: [Colors.blue, Colors.blue.shade700],
              routeName: '/trader-management',
              depotId: user.id,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementCard(BuildContext context,
      {required String title,
      required IconData icon,
      required List<Color> colors,
      required String routeName,
      required String depotId}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListTile(
          leading: FaIcon(icon, size: 40, color: Colors.white),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
          onTap: () {
            Get.toNamed(routeName, arguments: {
              'depotId': depotId,
              'depotName': user.fullname,
            });
          },
        ),
      ),
    );
  }
}
