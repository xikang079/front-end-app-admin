import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../../controllers/user_controller.dart';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../../controllers/user_controller.dart';

class ManagmentUserPage extends StatelessWidget {
  const ManagmentUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.find<UserController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý người dùng'),
      ),
      body: Obx(() {
        if (userController.isLoading.value) {
          EasyLoading.show(status: 'Đang tải dữ liệu...');
          return Container();
        }
        EasyLoading.dismiss();

        // Lọc danh sách người dùng để loại bỏ các admin
        final nonAdminUsers =
            userController.users.where((user) => user.role != 'admin').toList();

        if (nonAdminUsers.isEmpty) {
          return const Center(
            child: Text(
              'Không có người dùng nào để hiển thị.',
              style: TextStyle(fontSize: 18),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: nonAdminUsers.length,
          itemBuilder: (context, index) {
            final user = nonAdminUsers[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Text(
                      user.fullname[0],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    user.fullname,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tên đăng nhập: ${user.username}'),
                        const SizedBox(height: 4),
                        Text('Vai trò: ${user.role}'),
                        const SizedBox(height: 4),
                        Text('Số điện thoại: ${user.phone}'),
                      ],
                    ),
                  ),
                  trailing: const Icon(
                    Icons.person,
                    color: Colors.blue,
                  ),
                  onTap: () {
                    Get.toNamed('/user-management-options', arguments: user);
                  },
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
