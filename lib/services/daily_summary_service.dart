import 'package:dio/dio.dart';
import '../models/daily_summary_model.dart';
import 'local_storage_service.dart';

class ApiDailySummaryService {
  static const String baseUrl =
      'https://back-end-app-cua.onrender.com/crabPurchases';
  final Dio _dio;

  ApiDailySummaryService()
      : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        ) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        String? token = await LocalStorageService.getToken();
        options.headers['Authorization'] = 'Bearer $token';
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (DioException error, handler) {
        return handler.next(error);
      },
    ));
  }

  Future<List<DailySummary>> getDailySummariesByDepotAndDate(
      String depotId, DateTime date) async {
    try {
      String formattedDate = date.toIso8601String().split('T')[0];
      Response response =
          await _dio.get('/depot/$depotId/summaries/date/$formattedDate');
      if (response.statusCode == 200) {
        var data = response.data['message']['metadata'];
        if (data != null && data is List) {
          return data.map((e) => DailySummary.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<DailySummary>> getDailySummariesByDepotAndMonth(
      String depotId, int month, int year) async {
    try {
      Response response =
          await _dio.get('/depot/$depotId/summaries/month/$month/year/$year');
      if (response.statusCode == 200) {
        var data = response.data['message']['metadata'];
        if (data != null && data is List) {
          return data.map((e) => DailySummary.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
