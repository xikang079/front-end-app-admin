import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';

class NetworkService extends GetxService {
  static NetworkService get to => Get.find();

  final _isConnected = true.obs;
  final _connectionType = 'Unknown'.obs;

  bool get isConnected => _isConnected.value;
  String get connectionType => _connectionType.value;

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _startNetworkMonitoring();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void _startNetworkMonitoring() {
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      _checkConnectivity();
    });
    // Check immediately
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        _isConnected.value = true;
        _connectionType.value = 'Online';
      } else {
        _isConnected.value = false;
        _connectionType.value = 'Offline';
      }
    } catch (e) {
      _isConnected.value = false;
      _connectionType.value = 'Offline';
    }
  }

  Future<bool> checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}

