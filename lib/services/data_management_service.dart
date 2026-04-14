import 'package:dio/dio.dart';
import '../models/data_management_model.dart';
import 'local_storage_service.dart';

class DataManagementService {
  static const String baseUrl =
      'https://back-end-app-cua.onrender.com/data-management';
  final Dio _dio;

  DataManagementService()
      : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            // Tăng timeout cho các thao tác lớn (backup chunking, restore)
            connectTimeout: const Duration(seconds: 120),
            receiveTimeout: const Duration(seconds: 180),
            sendTimeout: const Duration(seconds: 120),
          ),
        ) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        String? token = await LocalStorageService.getToken();
        String? userId = await LocalStorageService.getUserId();
        options.headers['Authorization'] = 'Bearer $token';
        options.headers['x-user-id'] = userId;
        print('Request: ${options.method} ${options.uri}');
        if (options.data != null) {
          print('Body: ${options.data}');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('Response: ${response.statusCode}');
        return handler.next(response);
      },
      onError: (DioException error, handler) {
        print('Error: ${error.response?.statusCode} - ${error.message}');
        return handler.next(error);
      },
    ));
  }

  // ==================== STATISTICS ====================

  /// Lấy thống kê tổng - depotId = null để lấy tất cả vựa
  Future<DataStatistics?> getStatistics({String? depotId}) async {
    try {
      final response = await _dio.get(
        '/statistics',
        queryParameters: depotId != null ? {'depotId': depotId} : null,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final metadata = data['metadata'];
        if (metadata != null) {
          final statistics = metadata['statistics'];
          if (statistics != null) {
            return DataStatistics(
              crabPurchases: statistics['crabPurchases'] ?? 0,
              dailySummaries: statistics['dailySummaries'] ?? 0,
              totalRevenue: (statistics['totalRevenue'] ?? 0).toDouble(),
              totalWeight: statistics['totalWeight']?.toDouble(),
              dateRange: statistics['dateRange'] != null
                  ? DateRange.fromJson(statistics['dateRange'])
                  : null,
              warning: metadata['warning'],
              currentTime: metadata['currentTime'],
            );
          }
        }
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('API_NOT_AVAILABLE_404');
      }
      return null;
    } catch (e) {
      print('Error getting statistics: $e');
      return null;
    }
  }

  /// Lấy thống kê hôm nay
  Future<DataStatistics?> getStatisticsToday({String? depotId}) async {
    try {
      final response = await _dio.get(
        '/statistics/today',
        queryParameters: depotId != null ? {'depotId': depotId} : null,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final metadata = data['metadata'];
        if (metadata != null) {
          final statistics = metadata['statistics'];
          if (statistics != null) {
            return DataStatistics(
              crabPurchases: statistics['crabPurchases'] ?? 0,
              dailySummaries: statistics['dailySummaries'] ?? 0,
              totalRevenue: (statistics['totalRevenue'] ?? 0).toDouble(),
              totalWeight: statistics['totalWeight']?.toDouble(),
              dateRange: statistics['dateRange'] != null
                  ? DateRange.fromJson(statistics['dateRange'])
                  : null,
              warning: metadata['warning'],
              currentTime: metadata['currentTime'],
            );
          }
        }
      }
      return null;
    } catch (e) {
      print('Error getting today statistics: $e');
      return null;
    }
  }

  // ==================== BACKUP ====================

  /// Tạo backup mới
  Future<BackupInfo?> createBackup({String? depotId}) async {
    try {
      final response = await _dio.post(
        '/backup',
        data: depotId != null ? {'depotId': depotId} : {},
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final metadata = response.data['metadata'];
        if (metadata != null && metadata['backup'] != null) {
          return BackupInfo.fromJson(metadata['backup']);
        }
      }
      return null;
    } catch (e) {
      print('Error creating backup: $e');
      rethrow;
    }
  }

  /// Lấy danh sách backup
  Future<List<BackupInfo>> getBackupList(
      {int limit = 20, String? depotId}) async {
    try {
      final response = await _dio.get(
        '/backups',
        queryParameters: {
          'limit': limit,
          if (depotId != null) 'depotId': depotId,
        },
      );

      if (response.statusCode == 200) {
        final metadata = response.data['metadata'];
        if (metadata != null) {
          final backups = metadata['backups'] ?? [];
          return (backups as List)
              .map((item) => BackupInfo.fromJson(item))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error getting backup list: $e');
      return [];
    }
  }

  /// Xem chi tiết backup (Preview)
  Future<BackupPreview?> getBackupPreview(String backupId) async {
    try {
      final response = await _dio.get('/backups/$backupId/preview');

      if (response.statusCode == 200) {
        final metadata = response.data['metadata'];
        if (metadata != null) {
          return BackupPreview.fromJson(metadata);
        }
      }
      return null;
    } catch (e) {
      print('Error getting backup preview: $e');
      return null;
    }
  }

  // ==================== DELETE ====================

  /// Xóa dữ liệu
  /// depotId = null: xóa tất cả vựa
  /// depotId = "xxx": xóa 1 vựa cụ thể
  Future<DeleteResult?> deleteData({
    required DeleteMode mode,
    required String password,
    String? depotId,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? date,
  }) async {
    try {
      Map<String, dynamic> body = {
        'password': password,
        'depotId': depotId, // null = tất cả vựa
      };

      // Thêm các tham số theo chế độ xóa
      if (mode == DeleteMode.custom && startDate != null && endDate != null) {
        body['startDate'] = startDate.toUtc().toIso8601String();
        body['endDate'] = endDate.toUtc().toIso8601String();
      } else if (mode == DeleteMode.byDate && date != null) {
        body['date'] = _formatDateSimple(date);
      }

      print('Delete body: $body');

      final response = await _dio.delete(
        mode.endpoint,
        data: body,
        options: Options(contentType: 'application/json'),
      );

      if (response.statusCode == 200) {
        final metadata = response.data['metadata'];
        if (metadata != null) {
          return DeleteResult.fromJson(metadata);
        }
      }
      return null;
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e);
      throw Exception(errorMessage);
    } catch (e) {
      print('Error deleting data: $e');
      rethrow;
    }
  }

  // ==================== RESTORE ====================

  /// Khôi phục toàn bộ từ backup
  Future<RestoreResult?> restoreFull({
    required String password,
    required String backupId,
  }) async {
    try {
      final response = await _dio.post(
        '/restore/full',
        data: {
          'password': password,
          'backupId': backupId,
        },
      );

      if (response.statusCode == 200) {
        final metadata = response.data['metadata'];
        if (metadata != null) {
          return RestoreResult.fromJson(metadata);
        }
      }
      return null;
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e);
      throw Exception(errorMessage);
    } catch (e) {
      print('Error restoring data: $e');
      rethrow;
    }
  }

  /// Khôi phục theo ngày từ backup
  Future<RestoreResult?> restoreByDate({
    required String password,
    required String backupId,
    required DateTime date,
  }) async {
    try {
      final response = await _dio.post(
        '/restore/by-date',
        data: {
          'password': password,
          'backupId': backupId,
          'date': _formatDateSimple(date),
        },
      );

      if (response.statusCode == 200) {
        final metadata = response.data['metadata'];
        if (metadata != null) {
          return RestoreResult.fromJson(metadata);
        }
      }
      return null;
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e);
      throw Exception(errorMessage);
    } catch (e) {
      print('Error restoring data by date: $e');
      rethrow;
    }
  }

  // ==================== HELPERS ====================

  String _formatDateSimple(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _extractErrorMessage(DioException e) {
    final responseData = e.response?.data;

    if (responseData != null) {
      // Try: {error: {message: "..."}}
      if (responseData['error'] != null &&
          responseData['error']['message'] != null) {
        return responseData['error']['message'];
      }
      // Try: {message: "..."}
      if (responseData['message'] != null) {
        return responseData['message'];
      }
    }

    // Fallback messages theo status code
    switch (e.response?.statusCode) {
      case 400:
        return 'Dữ liệu không hợp lệ';
      case 401:
        return 'Mật khẩu không chính xác';
      case 403:
        return 'Bạn không có quyền thực hiện thao tác này';
      case 404:
        return 'Không tìm thấy dữ liệu';
      default:
        return 'Có lỗi xảy ra';
    }
  }
}
