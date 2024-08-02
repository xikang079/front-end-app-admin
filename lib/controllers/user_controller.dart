import 'package:get/get.dart';
import '../models/user_model.dart';
import '../services/local_storage_service.dart';
import '../services/user_serivce.dart';

class UserController extends GetxController {
  var users = <User>[].obs;
  var isLoading = true.obs;

  final UserService userService = UserService();

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  void fetchUsers() async {
    try {
      isLoading(true);
      var fetchedUsers = await userService.getAllUsers();
      // Lọc ra tài khoản admin đang đăng nhập
      String? currentUserId = await LocalStorageService.getUserId();
      users.assignAll(
          fetchedUsers.where((user) => user.id != currentUserId).toList());
    } finally {
      isLoading(false);
    }
  }
}
