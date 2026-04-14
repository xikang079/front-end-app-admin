import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/network_service.dart';
import '../apps/apps_colors.dart';

class NetworkStatusWidget extends StatelessWidget {
  const NetworkStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<NetworkService>(
      builder: (networkService) {
        if (networkService.isConnected) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.errorColor.withOpacity(0.1),
            border: Border(
              bottom: BorderSide(
                color: AppColors.errorColor.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.wifi_off,
                color: AppColors.errorColor,
                size: 16,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Không có kết nối mạng. Một số tính năng có thể không hoạt động.',
                  style: TextStyle(
                    color: AppColors.errorColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

