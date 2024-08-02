import 'package:flutter/material.dart';
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
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: userController.users.length,
          itemBuilder: (context, index) {
            final user = userController.users[index];
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
                  trailing: Icon(
                    user.role == 'admin'
                        ? Icons.admin_panel_settings
                        : Icons.person,
                    color: user.role == 'admin' ? Colors.red : Colors.blue,
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
